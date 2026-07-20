package com.fadeanimation

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

/**
 * 验证 Android 弹簧求解器与 Web 端 @fade-animation/core 数值一致。
 * 断言镜像 core 的 spring.test.ts，保证四端弹簧手感统一。
 */
class SpringTest {

    @Test
    fun `starts at zero`() {
        val solver = SpringSolver()
        assertEquals(0f, solver.current().position, 0.0001f)
        assertFalse(solver.current().atRest)
    }

    @Test
    fun `converges to one`() {
        val solver = SpringSolver(SpringConfig(stiffness = 200f, damping = 20f))
        var state = solver.current()
        repeat(300) { state = solver.step(1f / 60f) }
        assertEquals(1f, state.position, 0.01f)
        assertTrue(state.atRest)
    }

    @Test
    fun `bouncy overshoots past one`() {
        val solver = SpringSolver(SpringPresets.BOUNCY)
        var maxPos = 0f
        repeat(300) {
            val state = solver.step(1f / 60f)
            if (state.position > maxPos) maxPos = state.position
        }
        assertTrue(maxPos > 1.01f, "bouncy should overshoot")
    }

    @Test
    fun `noWobble does not overshoot significantly`() {
        val solver = SpringSolver(SpringPresets.NO_WOBBLE)
        var maxPos = 0f
        repeat(300) {
            val state = solver.step(1f / 60f)
            if (state.position > maxPos) maxPos = state.position
        }
        assertTrue(maxPos < 1.05f, "noWobble should barely overshoot")
    }

    @Test
    fun `reset returns to initial`() {
        val solver = SpringSolver()
        solver.step(1f / 60f)
        solver.step(1f / 60f)
        solver.reset()
        assertEquals(0f, solver.current().position, 0.0001f)
    }

    @Test
    fun `estimate duration is reasonable`() {
        val dur = estimateSpringDuration()
        assertTrue(dur > 200)
        assertTrue(dur < 5000)
    }

    @Test
    fun `snappy is faster than slow`() {
        val snappy = estimateSpringDuration(SpringPresets.SNAPPY)
        val slow = estimateSpringDuration(SpringPresets.SLOW)
        assertTrue(snappy < slow)
    }

    @Test
    fun `all presets converge within 5 seconds`() {
        listOf(
            SpringPresets.GENTLE, SpringPresets.SNAPPY, SpringPresets.BOUNCY,
            SpringPresets.SLOW, SpringPresets.NO_WOBBLE
        ).forEach { config ->
            assertTrue(estimateSpringDuration(config) < 5000)
        }
    }
}
