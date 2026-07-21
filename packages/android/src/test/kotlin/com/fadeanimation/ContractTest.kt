package com.fadeanimation

import android.animation.TimeInterpolator
import org.json.JSONObject
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test
import java.io.File

/**
 * 跨端一致性契约测试（Android 侧）。
 *
 * 读取仓库根 `contract/motion-contract.json`（与 core / iOS 同一份黄金值），
 * 断言 Android 的设计令牌与之一致，防止某端漂移（例如新增 easing 时必须四端同步）。
 *
 * 缓动曲线的控制点在 CubicBezierInterpolator 中为私有字段，改用「曲线采样等价」比对：
 * 若两条曲线在多个 t 点上的插值输出一致，则视为等价。
 */
class ContractTest {

    private fun loadContract(): JSONObject {
        // gradle Test 的工作目录为模块目录 packages/android → ../../ 为仓库根
        val file = File("../../contract/motion-contract.json")
        assertNotNull(file.takeIf { it.exists() }, "找不到契约文件: ${file.absolutePath}")
        return JSONObject(file.readText())
    }

    private fun easingByName(name: String): TimeInterpolator? = when (name) {
        "productive" -> EasingCurves.PRODUCTIVE
        "expressive" -> EasingCurves.EXPRESSIVE
        "enter" -> EasingCurves.ENTER
        "exit" -> EasingCurves.EXIT
        "bounce" -> EasingCurves.BOUNCE
        else -> null
    }

    private fun springByName(name: String): SpringConfig? = when (name) {
        "gentle" -> SpringPresets.GENTLE
        "snappy" -> SpringPresets.SNAPPY
        "bouncy" -> SpringPresets.BOUNCY
        "slow" -> SpringPresets.SLOW
        "noWobble" -> SpringPresets.NO_WOBBLE
        else -> null
    }

    /** 曲线采样等价：多个 t 点插值输出一致即视为同一条缓动曲线 */
    private fun assertCurveEquals(actual: TimeInterpolator, expected: TimeInterpolator, msg: String) {
        for (t in floatArrayOf(0f, 0.1f, 0.25f, 0.5f, 0.75f, 0.9f, 1f)) {
            assertEquals(
                expected.getInterpolation(t).toDouble(),
                actual.getInterpolation(t).toDouble(),
                1e-3,
                "$msg @t=$t"
            )
        }
    }

    @Test
    fun `timing scales match contract`() {
        val timings = loadContract().getJSONObject("timings")
        for (key in timings.keys()) {
            val expected = timings.getInt(key).toLong()
            val scale = TimingScale.valueOf(key.uppercase())
            assertEquals(expected, scale.durationMs, "TimingScale.$key 时长不一致")
        }
    }

    @Test
    fun `easing curves match contract`() {
        val easings = loadContract().getJSONObject("easings")
        for (name in easings.keys()) {
            val pts = easings.getJSONArray(name)
            val ref = CubicBezierInterpolator(
                pts.getDouble(0).toFloat(), pts.getDouble(1).toFloat(),
                pts.getDouble(2).toFloat(), pts.getDouble(3).toFloat()
            )
            val actual = easingByName(name)
            assertNotNull(actual, "Android 缺少 easing $name")
            assertCurveEquals(actual!!, ref, "easing $name")
        }
    }

    @Test
    fun `spring presets match contract`() {
        val springs = loadContract().getJSONObject("springs")
        for (name in springs.keys()) {
            val def = springs.getJSONObject(name)
            val cfg = springByName(name)
            assertNotNull(cfg, "Android 缺少 SpringPreset $name")
            assertEquals(def.getDouble("stiffness"), cfg!!.stiffness.toDouble(), 1e-6, "$name stiffness")
            assertEquals(def.getDouble("damping"), cfg.damping.toDouble(), 1e-6, "$name damping")
            assertEquals(def.getDouble("mass"), cfg.mass.toDouble(), 1e-6, "$name mass")
        }
    }

    @Test
    fun `blur-fade-in preset matches contract`() {
        val bp = loadContract().getJSONObject("effectPresets").getJSONObject("blurFadeIn")
        var opFrom: Float? = null
        var opTo: Float? = null
        var blFrom: Float? = null
        var blTo: Float? = null
        for (e in EffectPresets.BLUR_FADE_IN) {
            when (e) {
                is MotionEffect.Fade -> { opFrom = e.from; opTo = e.to }
                is MotionEffect.Blur -> { blFrom = e.from; blTo = e.to }
                else -> {}
            }
        }
        assertEquals(bp.getDouble("opacityFrom"), opFrom!!.toDouble(), 1e-6, "blur-in opacityFrom")
        assertEquals(bp.getDouble("opacityTo"), opTo!!.toDouble(), 1e-6, "blur-in opacityTo")
        assertEquals(bp.getDouble("blurFrom"), blFrom!!.toDouble(), 1e-6, "blur-in blurFrom")
        assertEquals(bp.getDouble("blurTo"), blTo!!.toDouble(), 1e-6, "blur-in blurTo")
    }

    @Test
    fun `intent defaults match contract`() {
        val contract = loadContract()
        val intents = contract.getJSONObject("intentDefaults")
        val timings = contract.getJSONObject("timings")
        for (name in intents.keys()) {
            val def = intents.getJSONObject(name)
            val intent = MotionIntent.valueOf(name.uppercase())
            // timing 一致
            assertEquals(
                timings.getInt(def.getString("timing")).toLong(),
                intent.timing.durationMs,
                "$name 默认 timing 不一致"
            )
            // easing 一致（采样等价）
            val expectedEasing = easingByName(def.getString("easing"))
            assertNotNull(expectedEasing, "契约引用了未知 easing ${def.getString("easing")}")
            assertCurveEquals(intent.interpolator, expectedEasing!!, "$name 默认 easing")
        }
    }
}
