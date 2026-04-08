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
}
