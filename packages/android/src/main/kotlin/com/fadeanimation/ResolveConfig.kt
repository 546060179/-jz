package com.fadeanimation

import android.content.Context

fun resolveConfig(options: FadeOptions, context: Context): FadeConfig {
    val motionLevel = ReducedMotionHelper.resolveMotionLevel(context)
    return resolveConfigInternal(options, motionLevel)
}

fun resolveConfigInternal(options: FadeOptions, motionLevel: ReducedMotionHelper.MotionLevel): FadeConfig {
    val intentDefaults = options.intent

    val resolvedDuration: Long = when {
        options.duration != null -> {
            if (options.duration >= 0) options.duration else Defaults.DURATION
        }
        options.timing != null -> options.timing.durationMs
        options.preset != null -> options.preset.durationMs
        intentDefaults != null -> intentDefaults.timing.durationMs
        else -> Defaults.DURATION
    }

    val resolvedDelay: Long = when {
        options.delay != null -> {
            if (options.delay >= 0) options.delay else Defaults.DELAY
        }
        else -> Defaults.DELAY
    }

    val resolvedInterpolator = options.interpolator
        ?: intentDefaults?.interpolator
        ?: Defaults.INTERPOLATOR

    return when (motionLevel) {
        ReducedMotionHelper.MotionLevel.NONE -> FadeConfig(
            duration = 0L,
            delay = 0L,
            interpolator = resolvedInterpolator,
            reducedMotion = true
        )
        ReducedMotionHelper.MotionLevel.REDUCED -> FadeConfig(
            duration = minOf(resolvedDuration, ReducedMotionHelper.REDUCED_MAX_DURATION),
            delay = 0L,
            interpolator = resolvedInterpolator,
            reducedMotion = true
        )
        ReducedMotionHelper.MotionLevel.FULL -> FadeConfig(
            duration = resolvedDuration,
            delay = resolvedDelay,
            interpolator = resolvedInterpolator,
            reducedMotion = false
        )
    }
}
