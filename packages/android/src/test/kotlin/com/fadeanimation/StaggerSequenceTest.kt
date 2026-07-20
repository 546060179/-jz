package com.fadeanimation

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

/**
 * 验证 Android stagger / planSequence 与 Web 端 @fade-animation/core 数值一致。
 * 断言镜像 core 的 stagger.test.ts 与 sequence.test.ts。
 */
class StaggerSequenceTest {

    // --- stagger ---

    @Test fun `empty for zero count`() {
        assertEquals(emptyList<Long>(), stagger(0, StaggerOptions(interval = 50L)))
    }

    @Test fun `empty for negative count`() {
        assertEquals(emptyList<Long>(), stagger(-1, StaggerOptions(interval = 50L)))
    }

    @Test fun `single element`() {
        assertEquals(listOf(0L), stagger(1, StaggerOptions(interval = 50L)))
    }

    @Test fun `forward`() {
        assertEquals(listOf(0L, 50L, 100L, 150L, 200L), stagger(5, StaggerOptions(interval = 50L)))
    }

    @Test fun `forward with baseDelay`() {
        assertEquals(listOf(100L, 150L, 200L), stagger(3, StaggerOptions(interval = 50L, baseDelay = 100L)))
    }

    @Test fun `reverse`() {
        assertEquals(
            listOf(200L, 150L, 100L, 50L, 0L),
            stagger(5, StaggerOptions(interval = 50L, direction = StaggerDirection.REVERSE))
        )
    }

    @Test fun `center odd`() {
        assertEquals(
            listOf(100L, 50L, 0L, 50L, 100L),
            stagger(5, StaggerOptions(interval = 50L, direction = StaggerDirection.CENTER))
        )
    }

    @Test fun `center even`() {
        assertEquals(
            listOf(75L, 25L, 25L, 75L),
            stagger(4, StaggerOptions(interval = 50L, direction = StaggerDirection.CENTER))
        )
    }

    @Test fun `center with baseDelay`() {
        assertEquals(
            listOf(250L, 200L, 250L),
            stagger(3, StaggerOptions(interval = 50L, baseDelay = 200L, direction = StaggerDirection.CENTER))
        )
    }

    @Test fun `negative interval treated as zero`() {
        assertEquals(listOf(0L, 0L, 0L), stagger(3, StaggerOptions(interval = -10L)))
    }

    @Test fun `negative baseDelay treated as zero`() {
        assertEquals(listOf(0L, 50L, 100L), stagger(3, StaggerOptions(interval = 50L, baseDelay = -100L)))
    }

    // --- planSequence ---

    @Test fun `single step`() {
        val plan = planSequence(listOf(SequenceStep(effects = EffectPresets.FADE_IN)))
        assertEquals(listOf(0L), plan.stepDelays)
        assertEquals(listOf(300L), plan.stepDurations)
        assertEquals(300L, plan.totalDuration)
    }

    @Test fun `sequential steps default duration`() {
        val plan = planSequence(
            listOf(
                SequenceStep(effects = EffectPresets.FADE_IN),
                SequenceStep(effects = EffectPresets.SCALE_FADE_IN),
                SequenceStep(effects = EffectPresets.SLIDE_UP_IN)
            )
        )
        assertEquals(listOf(0L, 300L, 600L), plan.stepDelays)
        assertEquals(900L, plan.totalDuration)
    }

    @Test fun `custom durations`() {
        val plan = planSequence(
            listOf(
                SequenceStep(effects = EffectPresets.FADE_IN, duration = 200L),
                SequenceStep(effects = EffectPresets.SCALE_FADE_IN, duration = 100L)
            )
        )
        assertEquals(listOf(0L, 200L), plan.stepDelays)
        assertEquals(listOf(200L, 100L), plan.stepDurations)
        assertEquals(300L, plan.totalDuration)
    }

    @Test fun `step delays gap between steps`() {
        val plan = planSequence(
            listOf(
                SequenceStep(effects = EffectPresets.FADE_IN, duration = 200L),
                SequenceStep(effects = EffectPresets.SCALE_FADE_IN, duration = 100L, delay = 50L)
            )
        )
        assertEquals(listOf(0L, 250L), plan.stepDelays)
        assertEquals(350L, plan.totalDuration)
    }

    @Test fun `custom default duration`() {
        val plan = planSequence(listOf(SequenceStep(effects = EffectPresets.FADE_IN)), 500L)
        assertEquals(listOf(500L), plan.stepDurations)
        assertEquals(500L, plan.totalDuration)
    }

    @Test fun `empty steps`() {
        val plan = planSequence(emptyList())
        assertEquals(emptyList<Long>(), plan.stepDelays)
        assertEquals(0L, plan.totalDuration)
    }
}
