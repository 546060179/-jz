package com.kineticui.demo

import com.fadeanimation.MotionEffect

/**
 * 单个动效演示项
 */
data class EffectDemoItem(
    val name: String,
    val subtitle: String,
    val effects: List<MotionEffect>,
    val entering: Boolean
)

/**
 * 动效分组
 */
data class EffectSection(
    val title: String,
    val items: List<EffectDemoItem>
)
