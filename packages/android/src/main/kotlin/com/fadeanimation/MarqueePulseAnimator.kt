package com.fadeanimation

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.view.View
import android.view.animation.PathInterpolator

/**
 * 跑马灯脉冲动画配置
 */
data class MarqueePulseConfig(
    /** 单个元素动画周期（ms），默认 800 */
    val cycleDurationMs: Long = 800L,
    /** 元素间交错延迟（ms），默认 150 */
    val staggerIntervalMs: Long = 150L,
    /** 最小 opacity，默认 0.4 */
    val minAlpha: Float = 0.4f,
    /** 最大 opacity，默认 1.0 */
    val maxAlpha: Float = 1.0f,
    /** 最小 scale，默认 1.0 */
    val minScale: Float = 1.0f,
    /** 最大 scale，默认 1.15 */
    val maxScale: Float = 1.15f
)

/**
 * MarqueePulseAnimator — 纯动效工具
 *
 * 给任意一组 View 添加交错脉冲动画（alpha + scaleX/Y），
 * 形成跑马灯式的波浪效果。
 *
 * 不包含任何 UI 布局，只负责动画逻辑。
 *
 * ```kotlin
 * val animator = MarqueePulseAnimator()
 * animator.apply(listOf(dot1, dot2, dot3))
 * // 停止
 * animator.cancel()
 * ```
 */
class MarqueePulseAnimator(
    private val config: MarqueePulseConfig = MarqueePulseConfig()
) {
    private var animatorSet: AnimatorSet? = null

    // expressive 缓动曲线 — 对齐 EASING_CURVES.expressive
    private val expressiveInterpolator = PathInterpolator(0.4f, 0.14f, 0.3f, 1.0f)

    /**
     * 给一组 View 添加跑马灯脉冲动画
     */
    fun apply(views: List<View>) {
        cancel()
        if (views.isEmpty()) return

        val animators = mutableListOf<android.animation.Animator>()

        for ((i, view) in views.withIndex()) {
            val delay = i * config.staggerIntervalMs

            val alphaAnim = ObjectAnimator.ofFloat(
                view, View.ALPHA,
                config.minAlpha, config.maxAlpha, config.minAlpha
            ).apply {
                duration = config.cycleDurationMs
                startDelay = delay
                repeatCount = ObjectAnimator.INFINITE
                interpolator = expressiveInterpolator
            }

            val scaleXAnim = ObjectAnimator.ofFloat(
                view, View.SCALE_X,
                config.minScale, config.maxScale, config.minScale
            ).apply {
                duration = config.cycleDurationMs
                startDelay = delay
                repeatCount = ObjectAnimator.INFINITE
                interpolator = expressiveInterpolator
            }

            val scaleYAnim = ObjectAnimator.ofFloat(
                view, View.SCALE_Y,
                config.minScale, config.maxScale, config.minScale
            ).apply {
                duration = config.cycleDurationMs
                startDelay = delay
                repeatCount = ObjectAnimator.INFINITE
                interpolator = expressiveInterpolator
            }

            animators.add(alphaAnim)
            animators.add(scaleXAnim)
            animators.add(scaleYAnim)
        }

        animatorSet = AnimatorSet().apply {
            playTogether(animators)
            start()
        }
    }

    /** 停止并清除动画 */
    fun cancel() {
        animatorSet?.cancel()
        animatorSet = null
    }
}
