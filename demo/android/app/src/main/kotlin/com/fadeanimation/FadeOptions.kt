package com.fadeanimation

import android.animation.TimeInterpolator

/**
 * 动画配置选项（用户传入）。
 *
 * @property fadeIn 是否为淡入动画，默认 true
 * @property duration 动画持续时长（毫秒），null 使用默认值
 * @property delay 动画延迟时间（毫秒），null 使用默认值
 * @property interpolator 缓动曲线，null 使用平台默认
 * @property preset 预设速度方案（向后兼容），null 不使用预设
 * @property timing 时间刻度（新 token 体系），优先级高于 preset
 * @property intent 动效意图，自动推导 timing 和 interpolator
 * @property onAnimationEnd 动画结束回调，null 不触发回调
 */
data class FadeOptions(
    val fadeIn: Boolean = true,
    val duration: Long? = null,
    val delay: Long? = null,
    val interpolator: TimeInterpolator? = null,
    val preset: PresetSpeed? = null,
    val timing: TimingScale? = null,
    val intent: MotionIntent? = null,
    val onAnimationEnd: (() -> Unit)? = null
)
