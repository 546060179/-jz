package com.fadeanimation

import android.animation.TimeInterpolator

/**
 * 解析后的动画配置（所有字段已确定，非空）。
 *
 * 由 resolveConfig 生成，所有值已经过校验和默认值合并。
 *
 * @property duration 已校验的动画持续时长（毫秒），非负
 * @property delay 已校验的动画延迟时间（毫秒），非负
 * @property interpolator 已确定的缓动曲线
 * @property reducedMotion 当前平台无障碍减少动效状态
 */
data class FadeConfig(
    val duration: Long,
    val delay: Long,
    val interpolator: TimeInterpolator,
    val reducedMotion: Boolean
)
