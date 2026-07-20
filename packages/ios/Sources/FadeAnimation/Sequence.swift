import Foundation

/// 序列动画步骤 —— 对齐 Web 端 @fade-animation/core 的 SequenceStep。
public struct SequenceStep {
    /// 效果列表
    public var effects: [MotionEffect]
    /// 该步骤的持续时长（ms），不设则使用全局 defaultDuration
    public var duration: Int?
    /// 该步骤相对上一步结束的延迟（ms）
    public var delay: Int?

    public init(effects: [MotionEffect] = [], duration: Int? = nil, delay: Int? = nil) {
        self.effects = effects
        self.duration = duration
        self.delay = delay
    }
}

/// 序列计划 —— 与 Web 端 SequencePlan 数值一致。
public struct SequencePlan {
    /// 每步的累计延迟（ms），用于设置每步的 delay
    public let stepDelays: [Int]
    /// 每步的实际时长（ms）
    public let stepDurations: [Int]
    /// 整个序列的总时长（ms）
    public let totalDuration: Int

    public init(stepDelays: [Int], stepDurations: [Int], totalDuration: Int) {
        self.stepDelays = stepDelays
        self.stepDurations = stepDurations
        self.totalDuration = totalDuration
    }
}

/// 计算序列动画的编排计划。
///
/// 按顺序累计每步的 delay + duration，返回每步应使用的累计延迟。
/// 与 Web 端 planSequence() 数值完全一致。
///
/// - Parameters:
///   - steps: 动画步骤数组
///   - defaultDuration: 步骤未指定时长时的默认值（ms），默认 t3=300
/// - Returns: 包含 stepDelays / stepDurations / totalDuration 的计划
///
/// ```swift
/// let plan = planSequence([
///   SequenceStep(effects: EffectPresets.fadeIn, duration: 350),
///   SequenceStep(effects: EffectPresets.scaleFadeIn, delay: 50, duration: 700),
/// ])
/// for (i, step) in steps.enumerated() {
///   MotionAnimator(targetView: views[i],
///     options: FadeOptions(duration: plan.stepDurations[i], delay: plan.stepDelays[i]))
///     .start(entering: true, effects: step.effects)
/// }
/// ```
public func planSequence(
    _ steps: [SequenceStep],
    defaultDuration: Int = TimingScale.t3.durationMs
) -> SequencePlan {
    var stepDelays: [Int] = []
    var stepDurations: [Int] = []
    var cumulative = 0

    for step in steps {
        let stepDelay = step.delay ?? 0
        cumulative += stepDelay
        stepDelays.append(cumulative)

        let dur = step.duration ?? defaultDuration
        stepDurations.append(dur)
        cumulative += dur
    }

    return SequencePlan(
        stepDelays: stepDelays,
        stepDurations: stepDurations,
        totalDuration: cumulative
    )
}
