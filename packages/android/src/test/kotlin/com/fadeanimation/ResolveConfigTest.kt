package com.fadeanimation

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class ResolveConfigTest {

    // --- 默认值 ---
    @Test fun `default values`() {
        val c = resolveConfigInternal(FadeOptions(), false)
        assertEquals(300L, c.duration)
        assertEquals(0L, c.delay)
        assertFalse(c.reducedMotion)
    }

    // --- 自定义值 ---
    @Test fun `custom duration`() {
        assertEquals(500L, resolveConfigInternal(FadeOptions(duration = 500L), false).duration)
    }
    @Test fun `custom delay`() {
        assertEquals(100L, resolveConfigInternal(FadeOptions(delay = 100L), false).delay)
    }
    @Test fun `zero duration`() {
        assertEquals(0L, resolveConfigInternal(FadeOptions(duration = 0L), false).duration)
    }
    @Test fun `zero delay`() {
        assertEquals(0L, resolveConfigInternal(FadeOptions(delay = 0L), false).delay)
    }

    // --- 负数回退 ---
    @Test fun `negative duration fallback`() {
        assertEquals(300L, resolveConfigInternal(FadeOptions(duration = -100L), false).duration)
    }
    @Test fun `negative delay fallback`() {
        assertEquals(0L, resolveConfigInternal(FadeOptions(delay = -50L), false).delay)
    }

    // --- Preset ---
    @Test fun `preset FAST = 150`() {
        assertEquals(150L, resolveConfigInternal(FadeOptions(preset = PresetSpeed.FAST), false).duration)
    }
    @Test fun `preset NORMAL = 300`() {
        assertEquals(300L, resolveConfigInternal(FadeOptions(preset = PresetSpeed.NORMAL), false).duration)
    }
    @Test fun `preset SLOW = 500`() {
        assertEquals(500L, resolveConfigInternal(FadeOptions(preset = PresetSpeed.SLOW), false).duration)
    }
    @Test fun `duration overrides preset`() {
        assertEquals(200L, resolveConfigInternal(FadeOptions(duration = 200L, preset = PresetSpeed.SLOW), false).duration)
    }

    // --- Timing Scale ---
    @Test fun `timing T1 = 100`() {
        assertEquals(100L, resolveConfigInternal(FadeOptions(timing = TimingScale.T1), false).duration)
    }
    @Test fun `timing T3 = 300`() {
        assertEquals(300L, resolveConfigInternal(FadeOptions(timing = TimingScale.T3), false).duration)
    }
    @Test fun `timing T5 = 700`() {
        assertEquals(700L, resolveConfigInternal(FadeOptions(timing = TimingScale.T5), false).duration)
    }
    @Test fun `duration overrides timing`() {
        assertEquals(200L, resolveConfigInternal(FadeOptions(duration = 200L, timing = TimingScale.T5), false).duration)
    }
    @Test fun `timing overrides preset`() {
        assertEquals(100L, resolveConfigInternal(FadeOptions(preset = PresetSpeed.SLOW, timing = TimingScale.T1), false).duration)
    }

    // --- Motion Intent ---
    @Test fun `intent ENTER = 300`() {
        assertEquals(300L, resolveConfigInternal(FadeOptions(intent = MotionIntent.ENTER), false).duration)
    }
    @Test fun `intent EXIT = 150`() {
        assertEquals(150L, resolveConfigInternal(FadeOptions(intent = MotionIntent.EXIT), false).duration)
    }
    @Test fun `intent FEEDBACK = 100`() {
        assertEquals(100L, resolveConfigInternal(FadeOptions(intent = MotionIntent.FEEDBACK), false).duration)
    }
    @Test fun `intent DELIGHT = 500`() {
        assertEquals(500L, resolveConfigInternal(FadeOptions(intent = MotionIntent.DELIGHT), false).duration)
    }
    @Test fun `duration overrides intent`() {
        assertEquals(200L, resolveConfigInternal(FadeOptions(duration = 200L, intent = MotionIntent.DELIGHT), false).duration)
    }
    @Test fun `timing overrides intent`() {
        assertEquals(100L, resolveConfigInternal(FadeOptions(timing = TimingScale.T1, intent = MotionIntent.DELIGHT), false).duration)
    }
    @Test fun `intent sets interpolator`() {
        val c = resolveConfigInternal(FadeOptions(intent = MotionIntent.ENTER), false)
        assertEquals(MotionIntent.ENTER.interpolator, c.interpolator)
    }

    // --- Reduced Motion ---
    @Test fun `reduced motion zeros duration and delay`() {
        val c = resolveConfigInternal(FadeOptions(duration = 500L, delay = 200L), true)
        assertEquals(0L, c.duration)
        assertEquals(0L, c.delay)
        assertTrue(c.reducedMotion)
    }
    @Test fun `reduced motion with intent`() {
        val c = resolveConfigInternal(FadeOptions(intent = MotionIntent.DELIGHT), true)
        assertEquals(0L, c.duration)
        assertTrue(c.reducedMotion)
    }
}
