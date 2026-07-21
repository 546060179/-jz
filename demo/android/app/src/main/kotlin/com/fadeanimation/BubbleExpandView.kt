package com.fadeanimation

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.View
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * BubbleExpandView — 气泡展开动效组件
 *
 * 从窄条向左(或向右)弹性展开为带文字的气泡,文字在展开动画后段淡入。展开曲线为
 * 阻尼谐振子(zeta=0.5, omega=9.0),带轻微过冲回弹,与 Web/iOS 端同款参数。
 * 与 iOS 端 `BubbleExpandView` 对齐。
 *
 * ```kotlin
 * val bubble = BubbleExpandView(context)
 * bubble.text = "限时免费"
 * bubble.expandDurationMs = 650L
 * bubble.play()
 * ```
 */
class BubbleExpandView constructor(
    context: Context
) : View(context) {

    enum class ArrowDirection { LEFT, RIGHT }

    /** 气泡文字 */
    var text: String = ""
        set(value) { field = value; requestLayout(); invalidate() }
    /** 展开时长(ms),默认 650 */
    var expandDurationMs: Long = DEFAULT_EXPAND_DURATION_MS
    /** 文字淡入时长(ms),默认 300 */
    var textFadeDurationMs: Long = DEFAULT_TEXT_FADE_DURATION_MS
    /** 展开方向锚点,默认 RIGHT(右对齐向左展开) */
    var arrowDirection: ArrowDirection = ArrowDirection.RIGHT
    /** 是否显示箭头(预留) */
    var showArrow: Boolean = false
    /** 收起态宽度(dp),默认 20 */
    var collapsedWidthDp: Float = 20f
    /** 气泡高度(dp),默认 22 */
    var heightDp: Float = 22f
    /** 填充色,默认品牌蓝 #186CE5 */
    var fillColor: Int = 0xFF186CE5.toInt()
    /** 阻尼比 zeta,默认 0.5 */
    var zeta: Double = DEFAULT_ZETA
    /** 角频率 omega,默认 9.0 */
    var omega: Double = DEFAULT_OMEGA

    companion object {
        // 默认参数（单一事实源，跨端契约 contract/motion-contract.json 保护）
        const val DEFAULT_ZETA: Double = 0.5
        const val DEFAULT_OMEGA: Double = 9.0
        const val DEFAULT_EXPAND_DURATION_MS: Long = 650L
        const val DEFAULT_TEXT_FADE_DURATION_MS: Long = 300L
    }

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        isFakeBoldText = true
    }

    private var progress = 0f    // 展开进度(经 springBounce)
    private var textAlpha = 0f
    private var animator: ValueAnimator? = null

    private val density: Float get() = resources.displayMetrics.density

    private fun springBounce(t: Double): Double {
        if (t <= 0) return 0.0
        if (t >= 1) return 1.0
        val wd = omega * sqrt(1 - zeta * zeta)
        val env = exp(-zeta * omega * t)
        return 1 - env * (cos(wd * t) + (zeta / sqrt(1 - zeta * zeta)) * sin(wd * t))
    }

    private fun fullWidthPx(): Float {
        textPaint.textSize = 12f * density
        val textW = textPaint.measureText(text)
        return maxOf(collapsedWidthDp * density, textW + 24f * density)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val w = fullWidthPx().toInt()
        val h = (heightDp * density).toInt()
        setMeasuredDimension(
            resolveSize(w, widthMeasureSpec),
            resolveSize(h, heightMeasureSpec)
        )
    }

    /** 从收起态弹性展开,文字后段淡入 */
    fun play() {
        animator?.cancel()
        progress = 0f
        textAlpha = 0f
        val fadeStart = 1f - textFadeDurationMs.toFloat() / expandDurationMs.toFloat()
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = expandDurationMs
            addUpdateListener {
                val p = it.animatedValue as Float
                progress = springBounce(p.toDouble()).toFloat()
                textAlpha = if (p > fadeStart) ((p - fadeStart) / (1f - fadeStart)).coerceIn(0f, 1f) else 0f
                invalidate()
            }
            start()
        }
    }

    /** 停止动画 */
    fun stop() {
        animator?.cancel()
        animator = null
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stop()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val h = height.toFloat()
        val collapsedW = collapsedWidthDp * density
        val fullW = fullWidthPx()
        val w = collapsedW + (fullW - collapsedW) * progress
        val left = if (arrowDirection == ArrowDirection.RIGHT) width - w else 0f
        val rect = RectF(left, 0f, left + w, h)
        val r = h / 2f

        bgPaint.color = fillColor
        canvas.drawRoundRect(rect, r, r, bgPaint)

        if (textAlpha > 0f && text.isNotEmpty()) {
            textPaint.textSize = 12f * density
            textPaint.alpha = (textAlpha * 255).toInt()
            val ty = h / 2f - (textPaint.descent() + textPaint.ascent()) / 2f
            canvas.drawText(text, rect.centerX(), ty, textPaint)
        }
    }
}
