package com.fadeanimation

/**
 * 序列动画步骤 —— 对齐 Web 端 @fade-animation/core 的 SequenceStep。
 *
 * @property effects 效果列表
 * @property duration 该步骤的持续时长（ms），不设则使用全局 defaultDuration
 * @property delay 该步骤相对上一步结束的延迟（ms）
 */
data class SequenceStep(
    val effects: List<MotionEffect> = emptyList(),
    val duration: Long? = null,
    val delay: Long? = null
)

/**
 * 序列计划 —— 与 Web 端 SequencePlan 数值一致。
 *
 * @property stepDelays 每步的累计延迟（ms），用于设置每步的 delay
 * @property stepDurations 每步的实际时长（ms）
 * @property totalDuration 整个序列的总时长（ms）
 */
data class SequencePlan(
    val stepDelays: List<Long>,
    val stepDurations: List<Long>,
    val totalDuration: Long
)

/**
 * 计算序列动画的编排计划。
 *
 * 按顺序累计每步的 delay + duration，返回每步应使用的累计延迟。
 * 与 Web 端 planSequence() 数值完全一致。
 *
 * @param steps 动画步骤数组
 * @param defaultDuration 步骤未指定时长时的默认值（ms），默认 T3=300
 * @return 包含 stepDelays / stepDurations / totalDuration 的计划
 *
 * ```kotlin
 * val steps = listOf(
 *   SequenceStep(effects = EffectPresets.FADE_IN, duration = 350L),
 *   SequenceStep(effects = EffectPresets.SCALE_FADE_IN, delay = 50L, duration = 700L),
 * )
 * val plan = planSequence(steps)
 * steps.forEachIndexed { i, step ->
 *   MotionAnimator(views[i],
 *     FadeOptions(duration = plan.stepDurations[i], delay = plan.stepDelays[i]))
 *     .start(entering = true, effects = step.effects)
 * }
 * ```
 */
fun planSequence(
    steps: List<SequenceStep>,
    defaultDuration: Long = TimingScale.T3.durationMs
): SequencePlan {
    val stepDelays = mutableListOf<Long>()
    val stepDurations = mutableListOf<Long>()
    var cumulative = 0L

    for (step in steps) {
        val stepDelay = step.delay ?: 0L
        cumulative += stepDelay
        stepDelays.add(cumulative)

        val dur = step.duration ?: defaultDuration
        stepDurations.add(dur)
        cumulative += dur
    }

    return SequencePlan(
        stepDelays = stepDelays,
        stepDurations = stepDurations,
        totalDuration = cumulative
    )
}
