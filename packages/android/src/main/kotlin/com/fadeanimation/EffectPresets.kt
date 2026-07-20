package com.fadeanimation

/**
 * 效果预设 — 对齐 Web 端 EFFECT_PRESETS
 */
object EffectPresets {
    val FADE_IN = listOf(MotionEffect.Fade(from = 0f, to = 1f))
    val FADE_OUT = listOf(MotionEffect.Fade(from = 1f, to = 0f))

    val SCALE_FADE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Scale(from = 0.95f, to = 1f)
    )
    val SCALE_FADE_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Scale(from = 1f, to = 0.95f)
    )

    val SLIDE_UP_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Slide(direction = SlideDirection.UP, distance = 16f)
    )
    val SLIDE_DOWN_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Slide(direction = SlideDirection.DOWN, distance = 16f)
    )
    val SLIDE_LEFT_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Slide(direction = SlideDirection.LEFT, distance = 16f)
    )
    val SLIDE_RIGHT_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Slide(direction = SlideDirection.RIGHT, distance = 16f)
    )

    val FLIP_X_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Flip(axis = FlipAxis.X, from = 90f, to = 0f)
    )
    val FLIP_X_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Flip(axis = FlipAxis.X, from = 0f, to = 90f)
    )
    val FLIP_Y_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Flip(axis = FlipAxis.Y, from = 90f, to = 0f)
    )
    val FLIP_Y_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Flip(axis = FlipAxis.Y, from = 0f, to = 90f)
    )

    val COLLAPSE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Collapse(collapsedHeight = CollapseHeight.Fixed(0f))
    )
    val COLLAPSE_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Collapse(collapsedHeight = CollapseHeight.Fixed(0f))
    )

    // --- Rotate + Fade presets ---
    val ROTATE_FADE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Rotate(from = -10f, to = 0f)
    )
    val ROTATE_FADE_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Rotate(from = 0f, to = 10f)
    )

    // --- Blur + Fade presets ---
    val BLUR_FADE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Blur(from = 8f, to = 0f)
    )
    val BLUR_FADE_OUT = listOf(
        MotionEffect.Fade(from = 1f, to = 0f),
        MotionEffect.Blur(from = 0f, to = 8f)
    )

    // --- 新增：弹性/缩放/旋转进入（对齐 Web EFFECT_PRESETS）---
    /** 弹性缩放进入（scale 0.3→1，建议配 EasingCurves.BOUNCE 出过冲弹入） */
    val BOUNCE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Scale(from = 0.3f, to = 1f)
    )
    /** 缩放进入（scale 0.5→1，图片/卡片聚焦入场） */
    val ZOOM_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Scale(from = 0.5f, to = 1f)
    )
    /** 缩放上滑进入（scale 0.9→1 + 上滑 32） */
    val ZOOM_SLIDE_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Scale(from = 0.9f, to = 1f),
        MotionEffect.Slide(direction = SlideDirection.UP, distance = 32f)
    )
    /** 旋转进入（rotate -180→0 + 淡入） */
    val SPIN_IN = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Rotate(from = -180f, to = 0f)
    )
}
