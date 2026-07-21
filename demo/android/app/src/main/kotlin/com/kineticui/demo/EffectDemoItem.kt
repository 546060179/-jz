package com.kineticui.demo

import android.animation.TimeInterpolator
import com.fadeanimation.MotionEffect

/**
 * 单个动效演示项
 *
 * @property interpolator 可选缓动（如 bounce-in 需要过冲缓动），null 走库默认
 */
data class EffectDemoItem(
    val name: String,
    val subtitle: String,
    val effects: List<MotionEffect>,
    val entering: Boolean,
    val interpolator: TimeInterpolator? = null,
    /**
     * 业务组件标识（非 null 时详情页渲染对应自定义 View 而非通用预设盒子）。
     * 取值：bubble / continue / toast / notification / spotlight
     */
    val component: String? = null
)

/**
 * 动效分组
 */
data class EffectSection(
    val title: String,
    val items: List<EffectDemoItem>
)
