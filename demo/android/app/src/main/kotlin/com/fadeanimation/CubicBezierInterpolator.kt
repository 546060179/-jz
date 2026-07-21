package com.fadeanimation

import android.animation.TimeInterpolator

/**
 * 与 CSS / WebKit `cubic-bezier()` 完全相同算法的三次贝塞尔插值器。
 *
 * 控制点固定为 P0=(0,0)、P3=(1,1)，仅 P1(c1)、P2(c2) 可配置，
 * 与 Web 端 `EASING_CURVES` 及 iOS 端 `CubicBezierCurve` 一一对应。
 *
 * 相比 `android.view.animation.PathInterpolator`，本实现为纯 Kotlin 数值计算，
 * **不依赖 android.graphics.Path 的 native 方法**，因此可在纯 JVM 单元测试中直接使用，
 * 同时运行时曲线与 PathInterpolator(a,b,c,d) 完全等价。
 */
class CubicBezierInterpolator(
    private val x1: Float,
    private val y1: Float,
    private val x2: Float,
    private val y2: Float
) : TimeInterpolator {

    // x(u) = ((ax*u + bx)*u + cx)*u ；y(u) 同理
    private val cx = 3f * x1
    private val bx = 3f * (x2 - x1) - cx
    private val ax = 1f - cx - bx
    private val cy = 3f * y1
    private val by = 3f * (y2 - y1) - cy
    private val ay = 1f - cy - by

    private fun sampleX(u: Float): Float = ((ax * u + bx) * u + cx) * u
    private fun sampleY(u: Float): Float = ((ay * u + by) * u + cy) * u
    private fun sampleDerivativeX(u: Float): Float = (3f * ax * u + 2f * bx) * u + cx

    override fun getInterpolation(input: Float): Float {
        val x = input.coerceIn(0f, 1f)
        return sampleY(solveForU(x))
    }

    /** 用 Newton-Raphson 求解 x(u)=x 的参数 u，失败时回退二分。 */
    private fun solveForU(x: Float): Float {
        var u = x
        repeat(8) {
            val dx = sampleX(u) - x
            if (kotlin.math.abs(dx) < 1e-6f) return u
            val d = sampleDerivativeX(u)
            if (kotlin.math.abs(d) < 1e-6f) return@repeat
            u -= dx / d
        }
        // 二分兜底
        var lo = 0f
        var hi = 1f
        u = x
        while (lo < hi) {
            val xu = sampleX(u)
            if (kotlin.math.abs(xu - x) < 1e-6f) return u
            if (x > xu) lo = u else hi = u
            u = (lo + hi) / 2f
            if (hi - lo < 1e-6f) break
        }
        return u
    }
}
