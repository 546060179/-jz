package com.fadeanimation

import android.animation.TimeInterpolator

/**
 * 动画默认值常量。
 */
object Defaults {
    val DURATION: Long = TimingScale.T3.durationMs  // 300ms
    const val DELAY: Long = 0L
    // 默认 ease: cubic-bezier(0.25, 0.1, 0.25, 1)，对齐 Web 端 DEFAULTS.easing。
    // 使用纯 Kotlin 的 CubicBezierInterpolator，避免 PathInterpolator 的 native 依赖。
    val INTERPOLATOR: TimeInterpolator = CubicBezierInterpolator(0.25f, 0.1f, 0.25f, 1f)
    val PRESET: PresetSpeed = PresetSpeed.NORMAL
}
