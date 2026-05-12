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
import android.widget.ImageView
import android.widget.TextView
import kotlin.math.min

/**
 * 气泡由右向左展开 + 文字淡入动效
 *
 * Figma 设计参考：
 *   - 背景: linear-gradient(90deg, #FFD1C4, #FFD75F)
 *   - 文字: #62241B, Montserrat 10px Medium
 *   - 箭头: pic_arrow 2 图片, 9x40
 *   - 圆角: 8px
 *   - body 宽度: 120px, 总宽度: 129px (body + arrow)
 *
 * Spring bounce: ζ=0.5, ω=9.0, 650ms — 和 iOS/HTML 一致
 */
class BubbleExpandView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    // ─── Config (Figma dimensions) ───
    private val bodyWidthDp = 120f
    private val arrowWidthDp = 9f
    private val arrowHeightDp = 40f
    private val bubbleRadiusDp = 8f
    private val padTopDp = 6f
    private val padBottomDp = 6f
    private val padLeftDp = 8f
    private val padRightDp = 8f

    var expandDuration = 650L   // 650ms with spring bounce
    var listener: BubbleExpandListener? = null
    /** 阿拉伯语等 RTL 语言设为 true，箭头和展开方向自动镜像 */
    var isRTL: Boolean = false

    // ─── State ───
    enum class Phase { IDLE, EXPANDING, DONE }
    var phase: Phase = Phase.IDLE
        private set

    // ─── Views ───
    private val bodyBg = View(context)
    private val textView = TextView(context)
    private val arrowView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.FIT_XY
        // 开发者需要将 pic-arrow-2.png 放到 res/drawable/
        setImageResource(android.R.drawable.arrow_down_float) // 占位，替换为 R.drawable.pic_arrow_2
    }
    private val textMaskView = View(context)

    // ─── Animation ───
    private val choreographer = Choreographer.getInstance()
    private var phaseStartNanos = 0L
    private var isAnimating = false

    private val Float.dp: Float
        get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, resources.displayMetrics)

    private val bodyWidth get() = bodyWidthDp.dp
    private val arrowWidth get() = arrowWidthDp.dp
    private val arrowHeight get() = arrowHeightDp.dp
    val totalWidth get() = bodyWidth + arrowWidth
    var totalHeight = 40f.dp
        private set

    init {
        clipChildren = false
        clipToPadding = false

        // Body 渐变背景 (Figma: linear-gradient(90deg, #FFD1C4, #FFD75F))
        bodyBg.background = GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            intArrayOf(Color.parseColor("#FFD1C4"), Color.parseColor("#FFD75F"))
        ).apply { cornerRadius = bubbleRadiusDp.dp }
        addView(bodyBg)

        // Text
        textView.setTextColor(Color.parseColor("#62241B"))
        textView.textSize = 10f
        textView.alpha = 0f
        addView(textView)

        // Text mask (covers text during expand, fades out at 70%)
        textMaskView.background = GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            intArrayOf(Color.parseColor("#FFD1C4"), Color.parseColor("#FFD75F"))
        ).apply { cornerRadius = 4f.dp }
        addView(textMaskView)

        // Arrow
        arrowView.alpha = 0f
        addView(arrowView)

        // Initial state
        alpha = 0f
    }

    fun configure(text: String) {
        textView.text = text
        textView.gravity = if (isRTL) Gravity.CENTER_VERTICAL or Gravity.END else Gravity.CENTER_VERTICAL or Gravity.START
        textView.measure(
            MeasureSpec.makeMeasureSpec((bodyWidth - padLeftDp.dp - padRightDp.dp).toInt(), MeasureSpec.AT_MOST),
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        )
        val textH = textView.measuredHeight + padTopDp.dp + padBottomDp.dp
        totalHeight = maxOf(textH, arrowHeight)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        layoutChildren()
    }

    private fun layoutChildren() {
        val h = totalHeight.toInt()
        if (isRTL) {
            // RTL: [arrow(0~9)][body(8~128)] arrow on left, body on right
            arrowView.layout(0, 0, arrowWidth.toInt(), arrowHeight.toInt())
            arrowView.scaleX = -1f
            bodyBg.layout((arrowWidth - 1).toInt(), 0, (arrowWidth - 1 + bodyWidth).toInt(), h)
            val tl = (arrowWidth - 1 + padLeftDp.dp).toInt()
            val tr = (arrowWidth - 1 + bodyWidth - padRightDp.dp).toInt()
            textView.layout(tl, padTopDp.dp.toInt(), tr, (h - padBottomDp.dp).toInt())
            textMaskView.layout((tl - 2), (padTopDp.dp - 2).toInt(), tr + 2, (h - padBottomDp.dp + 2).toInt())
        } else {
            // LTR: [body(0~120)][arrow(119~128)] body on left, arrow on right
            bodyBg.layout(0, 0, bodyWidth.toInt(), h)
            arrowView.layout((bodyWidth - 1).toInt(), 0, (bodyWidth - 1 + arrowWidth).toInt(), arrowHeight.toInt())
            arrowView.scaleX = 1f
            val tl = padLeftDp.dp.toInt()
            val tr = (bodyWidth - padRightDp.dp).toInt()
            textView.layout(tl, padTopDp.dp.toInt(), tr, (h - padBottomDp.dp).toInt())
            textMaskView.layout((tl - 2), (padTopDp.dp - 2).toInt(), tr + 2, (h - padBottomDp.dp + 2).toInt())
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(totalWidth.toInt(), totalHeight.toInt())
    }

    // ─── Public API ───

    fun play() {
        if (phase != Phase.IDLE) return
        phase = Phase.EXPANDING
        alpha = 1f
        textMaskView.alpha = 1f
        textView.alpha = 0f
        arrowView.alpha = 0f
        if (isRTL) {
            pivotX = 0f // RTL: 从左边缘展开
        } else {
            pivotX = totalWidth // LTR: 从右边缘展开
        }
        scaleX = 0.001f
        phaseStartNanos = 0L
        isAnimating = true
        choreographer.postFrameCallback(frameCallback)
    }

    fun reset() {
        stopAnimation()
        phase = Phase.IDLE
        alpha = 0f
        scaleX = 1f
        textView.alpha = 0f
        textMaskView.alpha = 1f
        arrowView.alpha = 0f
    }

    // ─── Animation Engine ───

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (!isAnimating) return
            if (phaseStartNanos == 0L) phaseStartNanos = frameTimeNanos
            val elapsedMs = (frameTimeNanos - phaseStartNanos) / 1_000_000f
            tickExpand(elapsedMs)
            if (isAnimating) choreographer.postFrameCallback(this)
        }
    }

    private fun stopAnimation() {
        isAnimating = false
        choreographer.removeFrameCallback(frameCallback)
    }

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
        scaleX = maxOf(0.001f, s)

        // 文字在 70% 时开始淡入（和 iOS/HTML 一致）
        if (t > 0.7f) {
            val ft = (t - 0.7f) / 0.3f
            textMaskView.alpha = 1f - ft
            textView.alpha = ft
            arrowView.alpha = ft
        }

        if (t >= 1f) {
            scaleX = 1f
            textMaskView.alpha = 0f
            textView.alpha = 1f
            arrowView.alpha = 1f
            phase = Phase.DONE
            stopAnimation()
            listener?.onExpandEnd()
            listener?.onAnimationEnd()
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
    }
}

// ─── Arrow: 使用 Figma 导出的 pic_arrow_2 图片 ───
// 需要将 pic-arrow-2.png (@2x) 放到 res/drawable-xxhdpi/pic_arrow_2.png

// ─── Listener ───
interface BubbleExpandListener {
    fun onExpandEnd() {}
    fun onAnimationEnd() {}
}
