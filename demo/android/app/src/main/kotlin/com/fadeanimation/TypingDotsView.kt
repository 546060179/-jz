package com.fadeanimation

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.View

/**
 * TypingDotsView — 聊天"正在输入"跑马灯动效视图
 *
 * 基于 Figma ShortMax 对话框加载效果：多个圆点以交错节奏
 * 依次脉冲（opacity + scale），形成跑马灯式的波浪动画。
 *
 * 使用库内 design tokens：
 * - TimingScale.T4 作为默认周期
 * - expressive 缓动曲线 (0.4, 0.14, 0.3, 1.0)
 *
 * ```kotlin
 * val dots = TypingDotsView(context)
 * container.addView(dots)
 * dots.startAnimating()
 * ```
 */
class TypingDotsView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
    private val config: TypingDotsConfig = TypingDotsConfig()
) : View(context, attrs, defStyleAttr) {

    private val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = config.dimColor
        style = Paint.Style.FILL
    }

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = config.backgroundColor
        style = Paint.Style.FILL
    }

    /** 每个圆点的当前 opacity (0..1) */
    private val dotOpacities = FloatArray(config.count) { 0.4f }
    /** 每个圆点的当前 scale */
    private val dotScales = FloatArray(config.count) { 1f }

    private var animatorSet: AnimatorSet? = null
    private var isAnimating = false

    // expressive 缓动曲线 — 对齐 Web 端 EASING_CURVES.expressive（纯 Kotlin，无 native 依赖）
    private val expressiveInterpolator = CubicBezierInterpolator(0.4f, 0.14f, 0.3f, 1.0f)

    private val bgRect = RectF()
    private val cornerRadii = floatArrayOf(
        0f, 0f,                                     // top-left
        config.cornerRadius, config.cornerRadius,    // top-right
        config.cornerRadius, config.cornerRadius,    // bottom-right
        config.cornerRadius, config.cornerRadius     // bottom-left
    )

    init {
        contentDescription = "Loading"
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    // MARK: - Measure

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val density = resources.displayMetrics.density
        val dotsWidth = config.count * config.dotSizeDp + (config.count - 1) * config.gapDp
        val totalWidth = (dotsWidth + config.paddingDp * 2) * density
        val totalHeight = config.heightDp * density
        setMeasuredDimension(
            resolveSize(totalWidth.toInt(), widthMeasureSpec),
            resolveSize(totalHeight.toInt(), heightMeasureSpec)
        )
    }

    // MARK: - Draw

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val density = resources.displayMetrics.density

        // 绘制背景（带圆角）
        bgRect.set(0f, 0f, width.toFloat(), height.toFloat())
        val path = android.graphics.Path()
        path.addRoundRect(bgRect, cornerRadii, android.graphics.Path.Direction.CW)
        canvas.drawPath(path, bgPaint)

        // 绘制圆点
        val dotSizePx = config.dotSizeDp * density
        val gapPx = config.gapDp * density
        val dotsWidth = config.count * dotSizePx + (config.count - 1) * gapPx
        val startX = (width - dotsWidth) / 2f
        val centerY = height / 2f

        for (i in 0 until config.count) {
            val cx = startX + i * (dotSizePx + gapPx) + dotSizePx / 2f
            val cy = centerY
            val radius = (dotSizePx / 2f) * dotScales[i]

            // 在 dim 和 bright 之间插值颜色
            val alpha = dotOpacities[i]
            val blendedColor = blendColors(config.dimColor, config.brightColor, alpha)
            dotPaint.color = blendedColor
            dotPaint.alpha = (alpha * 255).toInt()

            canvas.drawCircle(cx, cy, radius, dotPaint)
        }
    }

    // MARK: - Animation

    /** 启动跑马灯脉冲动画 */
    fun startAnimating() {
        if (isAnimating) return
        isAnimating = true

        val totalDurationMs = (config.cycleDurationMs + (config.count - 1) * config.staggerIntervalMs).toLong()
        val animators = mutableListOf<android.animation.Animator>()

        for (i in 0 until config.count) {
            val delayMs = (i * config.staggerIntervalMs).toLong()

            // Opacity: 0.4 → 1.0 → 0.4
            val opacityAnim = ObjectAnimator.ofFloat(this, DotOpacityProperty(i), 0.4f, 1.0f, 0.4f).apply {
                duration = totalDurationMs
                startDelay = delayMs
                repeatCount = ObjectAnimator.INFINITE
                interpolator = expressiveInterpolator
            }

            // Scale: 1.0 → 1.15 → 1.0
            val scaleAnim = ObjectAnimator.ofFloat(this, DotScaleProperty(i), 1.0f, 1.15f, 1.0f).apply {
                duration = totalDurationMs
                startDelay = delayMs
                repeatCount = ObjectAnimator.INFINITE
                interpolator = expressiveInterpolator
            }

            animators.add(opacityAnim)
            animators.add(scaleAnim)
        }

        animatorSet = AnimatorSet().apply {
            playTogether(animators)
            start()
        }
    }

    /** 停止动画 */
    fun stopAnimating() {
        if (!isAnimating) return
        isAnimating = false
        animatorSet?.cancel()
        animatorSet = null
        // 重置状态
        for (i in 0 until config.count) {
            dotOpacities[i] = 0.4f
            dotScales[i] = 1f
        }
        invalidate()
    }

    // MARK: - Lifecycle

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        if (isAnimating) startAnimating()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        animatorSet?.cancel()
    }

    // MARK: - Custom Properties for ObjectAnimator

    private inner class DotOpacityProperty(private val index: Int) :
        android.util.Property<TypingDotsView, Float>(Float::class.java, "dotOpacity$index") {
        override fun get(view: TypingDotsView): Float = view.dotOpacities[index]
        override fun set(view: TypingDotsView, value: Float) {
            view.dotOpacities[index] = value
            view.invalidate()
        }
    }

    private inner class DotScaleProperty(private val index: Int) :
        android.util.Property<TypingDotsView, Float>(Float::class.java, "dotScale$index") {
        override fun get(view: TypingDotsView): Float = view.dotScales[index]
        override fun set(view: TypingDotsView, value: Float) {
            view.dotScales[index] = value
            view.invalidate()
        }
    }

    // MARK: - Helpers

    private fun blendColors(from: Int, to: Int, ratio: Float): Int {
        val t = ratio.coerceIn(0f, 1f)
        val fromA = (from shr 24) and 0xFF
        val fromR = (from shr 16) and 0xFF
        val fromG = (from shr 8) and 0xFF
        val fromB = from and 0xFF
        val toA = (to shr 24) and 0xFF
        val toR = (to shr 16) and 0xFF
        val toG = (to shr 8) and 0xFF
        val toB = to and 0xFF
        val a = (fromA + (toA - fromA) * t).toInt()
        val r = (fromR + (toR - fromR) * t).toInt()
        val g = (fromG + (toG - fromG) * t).toInt()
        val b = (fromB + (toB - fromB) * t).toInt()
        return (a shl 24) or (r shl 16) or (g shl 8) or b
    }
}

/**
 * TypingDots 配置 — 对齐 Web 端 TypingDotsProps 和 Figma 设计稿
 */
data class TypingDotsConfig(
    /** 圆点数量，默认 3 */
    val count: Int = 3,
    /** 圆点直径（dp），默认 8 */
    val dotSizeDp: Float = 8f,
    /** 圆点间距（dp），默认 6 */
    val gapDp: Float = 6f,
    /** 暗态颜色，默认 Neutral/T-b31 (#4C4B50) */
    val dimColor: Int = 0xFF4C4B50.toInt(),
    /** 亮态颜色，默认 Neutral/T-b53 (#828386) */
    val brightColor: Int = 0xFF828386.toInt(),
    /** 容器背景色，默认 Neutral/T-b16 (#23252A) */
    val backgroundColor: Int = 0xFF23252A.toInt(),
    /** 单个圆点动画周期（ms），默认 TimingScale.T4 (500) */
    val cycleDurationMs: Int = TimingScale.T4.durationMs.toInt(),
    /** 圆点间交错延迟（ms），默认 150 */
    val staggerIntervalMs: Int = 150,
    /** 容器圆角半径（dp），默认 12 */
    val cornerRadius: Float = 12f,
    /** 容器内边距（dp），默认 12 */
    val paddingDp: Float = 12f,
    /** 容器高度（dp），默认 44 */
    val heightDp: Float = 44f
)
