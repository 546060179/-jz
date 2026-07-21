package com.fadeanimation

import android.view.Choreographer
import androidx.annotation.MainThread

/**
 * 弹簧物理配置 —— 对齐 Web 端 @fade-animation/core 的 SpringConfig。
 *
 * 基于阻尼谐振子模型（Damped Harmonic Oscillator），四端使用完全相同的
 * 参数与数值积分，保证 iOS / Android / React / Vue 弹簧手感一致。
 *
 * @property stiffness 刚度，越大弹簧越硬、振动越快（默认 100）
 * @property damping 阻尼系数，越大衰减越快、弹跳越少（默认 10）
 * @property mass 质量，越大惯性越大、运动越慢（默认 1）
 * @property velocity 初始速度（默认 0）
 * @property restThreshold 静止阈值，位移和速度都小于此值时视为静止（默认 0.001）
 */
data class SpringConfig(
    val stiffness: Float = 100f,
    val damping: Float = 10f,
    val mass: Float = 1f,
    val velocity: Float = 0f,
    val restThreshold: Float = 0.001f
)

/**
 * 预设弹簧配置 —— 与 Web 端 SPRING_PRESETS 数值完全一致。
 */
object SpringPresets {
    /** 轻柔弹跳，适合 UI 元素进入 */
    val GENTLE = SpringConfig(stiffness = 120f, damping = 14f, mass = 1f)
    /** 快速响应，适合按钮反馈 */
    val SNAPPY = SpringConfig(stiffness = 300f, damping = 20f, mass = 1f)
    /** 明显弹跳，适合品牌个性动效 */
    val BOUNCY = SpringConfig(stiffness = 200f, damping = 10f, mass = 1f)
    /** 缓慢柔和，适合大面积过渡 */
    val SLOW = SpringConfig(stiffness = 80f, damping = 12f, mass = 1.5f)
    /** 无弹跳，临界阻尼 */
    val NO_WOBBLE = SpringConfig(stiffness = 170f, damping = 26f, mass = 1f)
}

/** 单帧弹簧状态 */
data class SpringState(
    /** 当前位置（0 = 起点，1 = 终点） */
    val position: Float,
    /** 当前速度 */
    val velocity: Float,
    /** 是否已到达静止状态 */
    val atRest: Boolean
)

/**
 * 弹簧求解器 —— 移植自 Web 端 createSpring，使用相同的半隐式欧拉积分。
 *
 * 目标位置固定为 1，起点为 0。每次 step 传入时间步长（秒）推进一帧。
 */
class SpringSolver(private val config: SpringConfig = SpringConfig()) {
    private var position = 0f
    private var velocity = config.velocity

    /** 推进一帧。dt 单位为秒。 */
    fun step(dt: Float): SpringState {
        val target = 1f
        val displacement = position - target
        val springForce = -config.stiffness * displacement
        val dampingForce = -config.damping * velocity
        val acceleration = (springForce + dampingForce) / config.mass

        velocity += acceleration * dt
        position += velocity * dt

        val atRest =
            kotlin.math.abs(velocity) < config.restThreshold &&
            kotlin.math.abs(position - target) < config.restThreshold

        if (atRest) {
            position = target
            velocity = 0f
        }

        return SpringState(position, velocity, atRest)
    }

    /** 重置到初始状态 */
    fun reset() {
        position = 0f
        velocity = config.velocity
    }

    /** 获取当前状态（不推进时间） */
    fun current(): SpringState {
        val target = 1f
        val atRest =
            kotlin.math.abs(velocity) < config.restThreshold &&
            kotlin.math.abs(position - target) < config.restThreshold
        return SpringState(position, velocity, atRest)
    }
}

/**
 * 预计算弹簧动画总时长（毫秒），通过模拟求解直到静止来估算。
 */
fun estimateSpringDuration(config: SpringConfig = SpringConfig()): Long {
    val solver = SpringSolver(config)
    val dt = 1f / 60f
    var frames = 0
    val maxFrames = 600 // 最多 10 秒
    while (frames < maxFrames) {
        val state = solver.step(dt)
        frames++
        if (state.atRest) break
    }
    return Math.round(frames * (1000.0 / 60.0))
}

/**
 * 弹簧动画驱动器 —— 用 Choreographer 逐帧驱动弹簧求解，输出 0→1 进度。
 *
 * 使用固定步长累加器：物理步长恒定 1/60s（与 Web 端及 iOS 端数值一致、
 * 保持确定性），每帧执行的步数按真实经过时间自适应，因此与屏幕刷新率无关
 * （90Hz / 120Hz 高刷 / 60Hz 表现一致）。
 *
 * @param config 弹簧配置，默认 GENTLE
 */
class SpringAnimator(config: SpringConfig = SpringPresets.GENTLE) {
    private val solver = SpringSolver(config)
    private val choreographer = Choreographer.getInstance()
    private var running = false
    private var lastFrameNanos = 0L
    private var accumulator = 0.0
    private var onUpdate: ((Float) -> Unit)? = null
    private var onRest: (() -> Unit)? = null

    /** 固定物理步长（秒） */
    private val fixedStep = 1.0 / 60.0
    /** 单帧最大经过时间（秒），防止后台恢复时时间跳变导致发散 */
    private val maxFrameTime = 0.25

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (!running) return

            if (lastFrameNanos == 0L) {
                lastFrameNanos = frameTimeNanos
                onUpdate?.invoke(solver.current().position)
                choreographer.postFrameCallback(this)
                return
            }

            var frameTime = (frameTimeNanos - lastFrameNanos) / 1_000_000_000.0
            lastFrameNanos = frameTimeNanos
            if (frameTime > maxFrameTime) frameTime = maxFrameTime
            accumulator += frameTime

            var state = solver.current()
            while (accumulator >= fixedStep) {
                state = solver.step(fixedStep.toFloat())
                accumulator -= fixedStep
                if (state.atRest) break
            }

            onUpdate?.invoke(state.position)

            if (state.atRest) {
                stop()
                onRest?.invoke()
            } else {
                choreographer.postFrameCallback(this)
            }
        }
    }

    /**
     * 启动弹簧动画。
     *
     * @param onUpdate 每帧回调，参数为当前进度（0→1，可能因弹跳略超过 1）
     * @param onRest 到达静止时回调一次
     */
    @MainThread
    fun start(onUpdate: (Float) -> Unit, onRest: (() -> Unit)? = null) {
        stop()
        solver.reset()
        this.onUpdate = onUpdate
        this.onRest = onRest
        lastFrameNanos = 0L
        accumulator = 0.0
        running = true
        choreographer.postFrameCallback(frameCallback)
    }

    /** 停止动画并清理。 */
    @MainThread
    fun stop() {
        running = false
        choreographer.removeFrameCallback(frameCallback)
    }
}
