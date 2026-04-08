package com.fadeanimation

import android.content.Context

fun resolveConfig(options: FadeOptions, context: Context): FadeConfig {
    val reducedMotion = ReducedMotionHelper.isReducedMotionEnabled(context)
    return resolveConfigInternal(options, reducedMotion)
}

fun resolveConfigInternal(options: FadeOptions, reducedMotion: Boolean): FadeConfig {
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

    return if (reducedMotion) {
        FadeConfig(
            duration = 0L,
            delay = 0L,
            interpolator = resolvedInterpolator,
            reducedMotion = true
        )
    } else {
        FadeConfig(
            duration = resolvedDuration,
            delay = resolvedDelay,
            interpolator = resolvedInterpolator,
            reducedMotion = false
        )
    }
}
