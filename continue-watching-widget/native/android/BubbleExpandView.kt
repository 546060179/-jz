package com.example.continuewatching

import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Choreographer
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.pow

/**
 * 气泡由左向右展开 + 文字淡入动效
 *
 * 使用 FadeAnimation 库的 motion tokens：
 *   - expandDuration: t4 (500ms), easing: expressive
 *   - textFadeDuration: t3 (300ms), easing: enter
 *
 * Figma 设计参考：
 *   - 背景: linear-gradient(90deg, #FFD1C4, #FFD75F)
 *   - 文字: #62241B, Montserrat 10px Medium
 *   - 箭头: #FFD65A, 三角形指向右侧
 *   - 圆角: 8px
 *   - 高度: 28px, 展开宽度: ~145px
 */
class BubbleExpandView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    // ─── Config ───
    var bubbleHeight = 28f.dp
    var bubbleRadius = 8f.dp
    var expandedWidth = 145f.dp

    // Motion tokens from @fade-animation/core
    var expandDuration = 650L   // 650ms with bounce
    var textFadeDuration = 300L // t3
    var textFadeDelay = 0L

    var listener: BubbleExpandListener? = null

    // ─── State ───
    enum class Phase { IDLE, EXPANDING, TEXT_FADING, DONE }
    var phase: Phase = Phase.IDLE
        private set

    // ─── Views ───
    private val textView = TextView(context)
    private val arrowView = ArrowView(context)
    private val collapsedWidth = 28f.dp

    // ─── Animation ───
    private val choreographer = Choreographer.getInstance()
    private var animPhase = ""
    private var phaseStartNanos = 0L
    private var isAnimating = false

    private val Float.dp: Float
        get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, resources.displayMetrics)

    init {
        clipChildren = false
        clipToPadding = false

        // Gradient background (Figma: linear-gradient(90deg, #FFD1C4, #FFD75F))
        background = GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            intArrayOf(Color.parseColor("#FFD1C4"), Color.parseColor("#FFD75F"))
        ).apply { cornerRadius = bubbleRadius }

        // Text
        textView.setTextColor(Color.parseColor("#62241B"))
        textView.textSize = 10f
        textView.alpha = 0f
        textView.translationX = 8f.dp
        textView.setPadding(8f.dp.toInt(), 0, 8f.dp.toInt(), 0)
        textView.gravity = Gravity.CENTER_VERTICAL
        addView(textView, LayoutParams(LayoutParams.WRAP_CONTENT, bubbleHeight.toInt()))

        // Arrow
        arrowView.alpha = 0f
        addView(arrowView, LayoutParams(9f.dp.toInt(), 16f.dp.toInt()))

        // Initial state
        alpha = 0f
        layoutParams = LayoutParams(collapsedWidth.toInt(), bubbleHeight.toInt())
    }

    fun configure(text: String) {
        textView.text = text
        textView.measure(
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
            MeasureSpec.makeMeasureSpec(bubbleHeight.toInt(), MeasureSpec.EXACTLY)
        )
        expandedWidth = textView.measuredWidth + 4f.dp
    }

    // ─── Public API ───

    fun play() {
        if (phase != Phase.IDLE) return
        phase = Phase.EXPANDING
        alpha = 1f
        val lp = layoutParams
        lp.width = expandedWidth.toInt()
        layoutParams = lp
        scaleX = 0f
        pivotX = expandedWidth
        textView.alpha = 0f
        textView.translationX = 8f.dp
        arrowView.alpha = 0f
        startAnimation("expand")
    }

    fun reset() {
        stopAnimation()
        phase = Phase.IDLE
        alpha = 0f
        scaleX = 0f
        textView.alpha = 0f
        textView.translationX = 8f.dp
        arrowView.alpha = 0f
    }

    // ─── Animation Engine ───

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (!isAnimating) return
            if (phaseStartNanos == 0L) phaseStartNanos = frameTimeNanos
            val elapsedMs = (frameTimeNanos - phaseStartNanos) / 1_000_000f

            when (animPhase) {
                "expand" -> tickExpand(elapsedMs)
                "text-fade" -> tickTextFade(elapsedMs)
            }

            if (isAnimating) choreographer.postFrameCallback(this)
        }
    }

    private fun startAnimation(startPhase: String) {
        animPhase = startPhase
        phaseStartNanos = 0L
        isAnimating = true
        choreographer.postFrameCallback(frameCallback)
    }

    private fun stopAnimation() {
        isAnimating = false
        choreographer.removeFrameCallback(frameCallback)
    }

    // Easing: expressive = cubic-bezier(0.4, 0.14, 0.3, 1)
    private fun easeExpressive(t: Float) = cubicBezier(t, 0.4f, 0.14f, 0.3f, 1f)
    // Easing: enter = cubic-bezier(0, 0, 0.3, 1)
    private fun easeEnter(t: Float) = cubicBezier(t, 0f, 0f, 0.3f, 1f)
    // Spring bounce (ζ=0.5, ω=9.0) — matches iOS and HTML
    private fun springBounce(t: Float): Float {
        if (t <= 0f) return 0f
        if (t >= 1f) return 1f
        val zeta = 0.5f
        val omega = 9.0f
        val omegaD = omega * kotlin.math.sqrt(1f - zeta * zeta)
        val env = kotlin.math.exp(-zeta * omega * t)
        return 1f - env * (kotlin.math.cos(omegaD * t) + (zeta / kotlin.math.sqrt(1f - zeta * zeta)) * kotlin.math.sin(omegaD * t))
    }

    private fun tickExpand(elapsed: Float) {
        val t = min(elapsed / expandDuration, 1f)
        val s = springBounce(t)
        scaleX = maxOf(0f, s)
        pivotX = width.toFloat() // anchor right edge

        if (t >= 1f) {
            scaleX = 1f
            listener?.onExpandEnd()
            phase = Phase.TEXT_FADING
            stopAnimation()
            postDelayed({ startAnimation("text-fade") }, textFadeDelay)
        }
    }

    private fun tickTextFade(elapsed: Float) {
        val t = min(elapsed / textFadeDuration, 1f)
        val e = easeEnter(t)
        textView.alpha = e
        textView.translationX = lerp(8f.dp, 0f, e)
        arrowView.alpha = e

        if (t >= 1f) {
            textView.alpha = 1f
            textView.translationX = 0f
            arrowView.alpha = 1f
            phase = Phase.DONE
            stopAnimation()
            listener?.onAnimationEnd()
        }
    }

    private fun layoutArrow() {
        val lp = arrowView.layoutParams as LayoutParams
        lp.leftMargin = (layoutParams.width)
        lp.topMargin = ((bubbleHeight - 16f.dp) / 2).toInt()
        arrowView.layoutParams = lp
    }

    // ─── Math ───
    private fun lerp(a: Float, b: Float, t: Float) = a + (b - a) * t

    private fun cubicBezier(t: Float, p1x: Float, p1y: Float, p2x: Float, p2y: Float): Float {
        val cx = 3 * p1x; val bx = 3 * (p2x - p1x) - cx; val ax = 1 - cx - bx
        val cy = 3 * p1y; val by = 3 * (p2y - p1y) - cy; val ay = 1 - cy - by
        fun sX(tt: Float) = ((ax * tt + bx) * tt + cx) * tt
        fun sY(tt: Float) = ((ay * tt + by) * tt + cy) * tt
        fun dX(tt: Float) = (3 * ax * tt + 2 * bx) * tt + cx
        var x = t
        repeat(8) {
            val err = sX(x) - t
            if (abs(err) < 1e-6f) return@repeat
            val d = dX(x)
            if (abs(d) < 1e-6f) return@repeat
            x -= err / d
        }
        return sY(x)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
    }
}

// ─── Arrow View (triangle pointing right, Figma: Polygon 32, #FFD65A) ───
private class ArrowView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#FFD65A")
        style = Paint.Style.FILL
    }
    private val path = Path()

    override fun onDraw(canvas: Canvas) {
        path.reset()
        path.moveTo(0f, 0f)
        path.lineTo(width.toFloat(), height / 2f)
        path.lineTo(0f, height.toFloat())
        path.close()
        canvas.drawPath(path, paint)
    }
}

// ─── Listener ───
interface BubbleExpandListener {
    fun onExpandEnd() {}
    fun onAnimationEnd() {}
}
