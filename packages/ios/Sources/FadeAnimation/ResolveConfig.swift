import UIKit

/// 解析用户传入的 FadeOptions，返回所有字段已确定的 FadeConfig。
///
/// 优先级规则（duration）：
/// 1. 自定义 duration（最高优先级）
/// 2. timing token (TimingScale)
/// 3. preset（向后兼容）
/// 4. intent 推导的默认 timing
/// 5. 全局默认值 300ms
///
/// 优先级规则（curve）：
/// 1. 自定义 curve
/// 2. intent 推导的默认 curve
/// 3. 全局默认值 .easeInOut
func resolveConfig(options: FadeOptions) -> FadeConfig {
    let reducedMotion = ReducedMotionHelper.isReducedMotionEnabled()
    return resolveConfigInternal(options: options, isReducedMotion: reducedMotion)
}

/// 内部可测试版本，不依赖 UIAccessibility。
func resolveConfigInternal(options: FadeOptions, isReducedMotion: Bool) -> FadeConfig {
    // --- resolve duration (ms) ---
    let resolvedDurationMs: Int
    if let duration = options.duration {
        resolvedDurationMs = duration >= 0 ? duration : Defaults.duration
    } else if let timing = options.timing {
        resolvedDurationMs = timing.durationMs
    } else if let preset = options.preset {
        resolvedDurationMs = preset.durationMs
    } else if let intent = options.intent {
        resolvedDurationMs = intent.timing.durationMs
    } else {
        resolvedDurationMs = Defaults.duration
    }

    // --- resolve delay (ms) ---
    let resolvedDelayMs: Int
    if let delay = options.delay {
        resolvedDelayMs = delay >= 0 ? delay : Defaults.delay
    } else {
        resolvedDelayMs = Defaults.delay
    }

    // --- resolve curve ---
    let resolvedCurve = options.curve
        ?? options.intent?.curve
        ?? Defaults.curve

    // --- apply motion level ---
    let motionLevel = ReducedMotionHelper.resolveMotionLevel()

    switch motionLevel {
    case .none:
        return FadeConfig(
            duration: 0,
            delay: 0,
            curve: resolvedCurve,
            reducedMotion: true
        )
    case .reduced:
        let clampedDuration = min(resolvedDurationMs, ReducedMotionHelper.reducedMaxDurationMs)
        return FadeConfig(
            duration: TimeInterval(clampedDuration) / 1000.0,
            delay: 0,
            curve: resolvedCurve,
            reducedMotion: true
        )
    case .full:
        return FadeConfig(
            duration: TimeInterval(resolvedDurationMs) / 1000.0,
            delay: TimeInterval(resolvedDelayMs) / 1000.0,
            curve: resolvedCurve,
            reducedMotion: false
        )
    }
}
