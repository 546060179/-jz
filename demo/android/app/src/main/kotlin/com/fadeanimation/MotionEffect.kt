package com.fadeanimation

/**
 * 动效效果类型 — 对齐 Web 端 @fade-animation/core effects.ts
 */

/** 效果基类 */
sealed class MotionEffect {

    /** 淡入淡出效果 */
    data class Fade(
        val from: Float? = null,
        val to: Float? = null
    ) : MotionEffect()

    /** 缩放效果 */
    data class Scale(
        val from: Float? = null,
        val to: Float? = null
    ) : MotionEffect()

    /** 滑动效果 */
    data class Slide(
        val direction: SlideDirection = SlideDirection.UP,
        val distance: Float = 16f
    ) : MotionEffect()

    /** 旋转效果 */
    data class Rotate(
        val from: Float? = null,
        val to: Float? = null
    ) : MotionEffect()

    /** 模糊效果（API 31+，低版本降级为仅 fade） */
    data class Blur(
        val from: Float? = null,
        val to: Float? = null
    ) : MotionEffect()

    /** 3D 翻转效果 */
    data class Flip(
        val axis: FlipAxis = FlipAxis.Y,
        val from: Float = 0f,
        val to: Float = 180f,
        val perspective: Float = 800f,
        val backfaceVisibility: String = "hidden"
    ) : MotionEffect()

    /** 折叠展开效果 */
    data class Collapse(
        val collapsedHeight: CollapseHeight = CollapseHeight.Fixed(0f)
    ) : MotionEffect()
}

/** 滑动方向 */
enum class SlideDirection {
    UP, DOWN, LEFT, RIGHT
}

/** 翻转轴方向 */
enum class FlipAxis {
    X, Y
}

/** 折叠目标高度 */
sealed class CollapseHeight {
    /** 固定高度值 */
    data class Fixed(val value: Float) : CollapseHeight()
    /** 自动测量当前高度 */
    object Auto : CollapseHeight()
}
