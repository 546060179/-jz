package com.fadeanimation

import android.animation.TimeInterpolator
import android.view.animation.AccelerateDecelerateInterpolator

/**
 * 动画默认值常量。
 */
object Defaults {
    val DURATION: Long = TimingScale.T3.durationMs  // 300ms
    const val DELAY: Long = 0L
    val INTERPOLATOR: TimeInterpolator = AccelerateDecelerateInterpolator()
    val PRESET: PresetSpeed = PresetSpeed.NORMAL
}
