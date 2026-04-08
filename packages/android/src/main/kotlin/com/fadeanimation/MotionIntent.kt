package com.fadeanimation

import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.animation.TimeInterpolator

/**
 * 动效意图枚举 — 对齐 Web 端 @fade-animation/core tokens。
 *
 * 每种意图自动推导推荐的 timing 和 interpolator。
 */
enum class MotionIntent(
    val timing: TimingScale,
    val interpolator: TimeInterpolator
) {
    /** 元素进入视图 */
    ENTER(TimingScale.T3, DecelerateInterpolator()),
    /** 元素离开视图 */
    EXIT(TimingScale.T2, AccelerateInterpolator()),
    /** 吸引注意力 */
    FOCUS(TimingScale.T2, AccelerateDecelerateInterpolator()),
    /** 操作反馈 */
    FEEDBACK(TimingScale.T1, AccelerateDecelerateInterpolator()),
    /** 品牌个性 */
    DELIGHT(TimingScale.T4, DecelerateInterpolator())
}
