package com.fadeanimation

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class ResolveConfigTest {

    private fun resolve(options: FadeOptions, motionLevel: ReducedMotionHelper.MotionLevel = ReducedMotionHelper.MotionLevel.FULL) =
        resolveConfigInternal(options, motionLevel)

    // --- 默认值 ---
    @Test fun `default values`() {
        val c = resolve(FadeOptions())
        assertEquals(300L, c.duration)
        assertEquals(0L, c.delay)
        assertFalse(c.reducedMotion)
    }

    // --- 自定义值 ---
    @Test fun `custom duration`() {
        assertEquals(500L, resolve(FadeOptions(duration = 500L)).duration)
    }
    @Test fun `custom delay`() {
        assertEquals(100L, resolve(FadeOptions(delay = 100L)).delay)
    }
    @Test fun `zero duration`() {
        assertEquals(0L, resolve(FadeOptions(duration = 0L)).duration)
    }
    @Test fun `zero delay`() {
        assertEquals(0L, resolve(FadeOptions(delay = 0L)).delay)
    }

    // --- 负数回退 ---
    @Test fun `negative duration fallback`() {
        assertEquals(300L, resolve(FadeOptions(duration = -100L)).duration)
    }
    @Test fun `negative delay fallback`() {
        assertEquals(0L, resolve(FadeOptions(delay = -50L)).delay)
    }

    // --- Preset ---
    @Test fun `preset FAST = 150`() {
        assertEquals(150L, resolve(FadeOptions(preset = PresetSpeed.FAST)).duration)
    }
    @Test fun `preset NORMAL = 300`() {
        assertEquals(300L, resolve(FadeOptions(preset = PresetSpeed.NORMAL)).duration)
    }
    @Test fun `preset SLOW = 500`() {
        assertEquals(500L, resolve(FadeOptions(preset = PresetSpeed.SLOW)).duration)
    }
    @Test fun `duration overrides preset`() {
        assertEquals(200L, resolve(FadeOptions(duration = 200L, preset = PresetSpeed.SLOW)).duration)
    }

    // --- Timing Scale ---
    @Test fun `timing T1 = 100`() {
        assertEquals(100L, resolve(FadeOptions(timing = TimingScale.T1)).duration)
    }
    @Test fun `timing T3 = 300`() {
        assertEquals(300L, resolve(FadeOptions(timing = TimingScale.T3)).duration)
    }
    @Test fun `timing T5 = 700`() {
        assertEquals(700L, resolve(FadeOptions(timing = TimingScale.T5)).duration)
    }
    @Test fun `duration overrides timing`() {
        assertEquals(200L, resolve(FadeOptions(duration = 200L, timing = TimingScale.T5)).duration)
    }
    @Test fun `timing overrides preset`() {
        assertEquals(100L, resolve(FadeOptions(preset = PresetSpeed.SLOW, timing = TimingScale.T1)).duration)
    }

    // --- Motion Intent ---
    @Test fun `intent ENTER = 300`() {
        assertEquals(300L, resolve(FadeOptions(intent = MotionIntent.ENTER)).duration)
    }
    @Test fun `intent EXIT = 150`() {
        assertEquals(150L, resolve(FadeOptions(intent = MotionIntent.EXIT)).duration)
    }
    @Test fun `intent FEEDBACK = 100`() {
        assertEquals(100L, resolve(FadeOptions(intent = MotionIntent.FEEDBACK)).duration)
    }
    @Test fun `intent DELIGHT = 500`() {
        assertEquals(500L, resolve(FadeOptions(intent = MotionIntent.DELIGHT)).duration)
    }
    @Test fun `duration overrides intent`() {
        assertEquals(200L, resolve(FadeOptions(duration = 200L, intent = MotionIntent.DELIGHT)).duration)
    }
    @Test fun `timing overrides intent`() {
        assertEquals(100L, resolve(FadeOptions(timing = TimingScale.T1, intent = MotionIntent.DELIGHT)).duration)
    }
    @Test fun `intent sets interpolator`() {
        val c = resolve(FadeOptions(intent = MotionIntent.ENTER))
        assertEquals(MotionIntent.ENTER.interpolator, c.interpolator)
    }

    // --- Reduced Motion: NONE level ---
    @Test fun `motion level NONE zeros duration and delay`() {
        val c = resolve(FadeOptions(duration = 500L, delay = 200L), ReducedMotionHelper.MotionLevel.NONE)
        assertEquals(0L, c.duration)
        assertEquals(0L, c.delay)
        assertTrue(c.reducedMotion)
    }
    @Test fun `motion level NONE with intent`() {
        val c = resolve(FadeOptions(intent = MotionIntent.DELIGHT), ReducedMotionHelper.MotionLevel.NONE)
        assertEquals(0L, c.duration)
        assertTrue(c.reducedMotion)
    }

    // --- Reduced Motion: REDUCED level ---
    @Test fun `motion level REDUCED clamps duration to 100ms`() {
        val c = resolve(FadeOptions(duration = 500L, delay = 200L), ReducedMotionHelper.MotionLevel.REDUCED)
        assertEquals(100L, c.duration)
        assertEquals(0L, c.delay)
        assertTrue(c.reducedMotion)
    }
    @Test fun `motion level REDUCED keeps short duration`() {
        val c = resolve(FadeOptions(duration = 50L), ReducedMotionHelper.MotionLevel.REDUCED)
        assertEquals(50L, c.duration)
        assertTrue(c.reducedMotion)
    }
    @Test fun `motion level REDUCED with intent`() {
        val c = resolve(FadeOptions(intent = MotionIntent.DELIGHT), ReducedMotionHelper.MotionLevel.REDUCED)
        assertEquals(100L, c.duration) // 500ms clamped to 100ms
        assertTrue(c.reducedMotion)
    }
}
