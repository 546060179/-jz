package com.fadeanimation

import android.view.animation.LinearInterpolator
import android.animation.TimeInterpolator

/**
 * 动效意图枚举 — 对齐 Web 端 @fade-animation/core tokens。
 *
 * 每种意图自动推导推荐的 timing 和 interpolator。
 * 使用 CubicBezierInterpolator 精确匹配 Web 端的 cubic-bezier 曲线
 * （纯 Kotlin 实现，无 android.graphics.Path native 依赖）。
 */
enum class MotionIntent(
    val timing: TimingScale,
    val interpolator: TimeInterpolator
) {
    /** 元素进入视图 — cubic-bezier(0, 0, 0.3, 1) */
    ENTER(TimingScale.T3, CubicBezierInterpolator(0f, 0f, 0.3f, 1f)),
    /** 元素离开视图 — cubic-bezier(0.4, 0, 1, 1) */
    EXIT(TimingScale.T2, CubicBezierInterpolator(0.4f, 0f, 1f, 1f)),
    /** 吸引注意力 — cubic-bezier(0.4, 0.14, 0.3, 1) (expressive) */
    FOCUS(TimingScale.T2, CubicBezierInterpolator(0.4f, 0.14f, 0.3f, 1f)),
    /** 操作反馈 — cubic-bezier(0.2, 0, 0.38, 0.9) (productive) */
    FEEDBACK(TimingScale.T1, CubicBezierInterpolator(0.2f, 0f, 0.38f, 0.9f)),
    /** 品牌个性 — cubic-bezier(0.4, 0.14, 0.3, 1) (expressive) */
    DELIGHT(TimingScale.T4, CubicBezierInterpolator(0.4f, 0.14f, 0.3f, 1f))
}

/**
 * 对齐 Web 端缓动曲线的精确插值器集合（纯 Kotlin，无 native 依赖）。
 */
object EasingCurves {
    /** productive: cubic-bezier(0.2, 0, 0.38, 0.9) */
    val PRODUCTIVE: TimeInterpolator = CubicBezierInterpolator(0.2f, 0f, 0.38f, 0.9f)
    /** expressive: cubic-bezier(0.4, 0.14, 0.3, 1) */
    val EXPRESSIVE: TimeInterpolator = CubicBezierInterpolator(0.4f, 0.14f, 0.3f, 1f)
    /** enter: cubic-bezier(0, 0, 0.3, 1) */
    val ENTER: TimeInterpolator = CubicBezierInterpolator(0f, 0f, 0.3f, 1f)
    /** exit: cubic-bezier(0.4, 0, 1, 1) */
    val EXIT: TimeInterpolator = CubicBezierInterpolator(0.4f, 0f, 1f, 1f)
    /** linear */
    val LINEAR: TimeInterpolator = LinearInterpolator()
    /** bounce: cubic-bezier(0.34, 1.56, 0.64, 1) 过冲回落，弹性入场（对齐 Web EASING_CURVES.bounce） */
    val BOUNCE: TimeInterpolator = CubicBezierInterpolator(0.34f, 1.56f, 0.64f, 1f)
}
