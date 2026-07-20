import UIKit
import QuartzCore

/// 弹簧物理配置 —— 对齐 Web 端 @fade-animation/core 的 SpringConfig。
///
/// 基于阻尼谐振子模型（Damped Harmonic Oscillator），四端使用完全相同的
/// 参数与数值积分，保证 iOS / Android / React / Vue 弹簧手感一致。
///
/// - stiffness: 刚度，越大弹簧越硬、振动越快（默认 100）
/// - damping: 阻尼系数，越大衰减越快、弹跳越少（默认 10）
/// - mass: 质量，越大惯性越大、运动越慢（默认 1）
/// - velocity: 初始速度（默认 0）
/// - restThreshold: 静止阈值，位移和速度都小于此值时视为静止（默认 0.001）
public struct SpringConfig {
    public var stiffness: CGFloat = 100
    public var damping: CGFloat = 10
    public var mass: CGFloat = 1
    public var velocity: CGFloat = 0
    public var restThreshold: CGFloat = 0.001

    public init(
        stiffness: CGFloat = 100,
        damping: CGFloat = 10,
        mass: CGFloat = 1,
        velocity: CGFloat = 0,
        restThreshold: CGFloat = 0.001
    ) {
        self.stiffness = stiffness
        self.damping = damping
        self.mass = mass
        self.velocity = velocity
        self.restThreshold = restThreshold
    }
}

/// 预设弹簧配置 —— 与 Web 端 SPRING_PRESETS 数值完全一致。
public enum SpringPresets {
    /// 轻柔弹跳，适合 UI 元素进入
    public static let gentle = SpringConfig(stiffness: 120, damping: 14, mass: 1)
    /// 快速响应，适合按钮反馈
    public static let snappy = SpringConfig(stiffness: 300, damping: 20, mass: 1)
    /// 明显弹跳，适合品牌个性动效
    public static let bouncy = SpringConfig(stiffness: 200, damping: 10, mass: 1)
    /// 缓慢柔和，适合大面积过渡
    public static let slow = SpringConfig(stiffness: 80, damping: 12, mass: 1.5)
    /// 无弹跳，临界阻尼
    public static let noWobble = SpringConfig(stiffness: 170, damping: 26, mass: 1)
}

/// 单帧弹簧状态
public struct SpringState {
    /// 当前位置（0 = 起点，1 = 终点）
    public let position: CGFloat
    /// 当前速度
    public let velocity: CGFloat
    /// 是否已到达静止状态
    public let atRest: Bool

    public init(position: CGFloat, velocity: CGFloat, atRest: Bool) {
        self.position = position
        self.velocity = velocity
        self.atRest = atRest
    }
}

/// 弹簧求解器 —— 移植自 Web 端 createSpring，使用相同的半隐式欧拉积分。
///
/// 目标位置固定为 1，起点为 0。每次 step 传入时间步长（秒）推进一帧。
public final class SpringSolver {
    private let stiffness: CGFloat
    private let damping: CGFloat
    private let mass: CGFloat
    private let restThreshold: CGFloat
    private let initialVelocity: CGFloat

    private var position: CGFloat = 0
    private var velocity: CGFloat

    public init(config: SpringConfig = SpringConfig()) {
        self.stiffness = config.stiffness
        self.damping = config.damping
        self.mass = config.mass
        self.restThreshold = config.restThreshold
        self.initialVelocity = config.velocity
        self.velocity = config.velocity
    }

    /// 推进一帧。dt 单位为秒。
    @discardableResult
    public func step(_ dt: CGFloat) -> SpringState {
        let target: CGFloat = 1
        let displacement = position - target
        let springForce = -stiffness * displacement
        let dampingForce = -damping * velocity
        let acceleration = (springForce + dampingForce) / mass

        velocity += acceleration * dt
        position += velocity * dt

        let atRest =
            abs(velocity) < restThreshold &&
            abs(position - target) < restThreshold

        if atRest {
            position = target
            velocity = 0
        }

        return SpringState(position: position, velocity: velocity, atRest: atRest)
    }

    /// 重置到初始状态
    public func reset() {
        position = 0
        velocity = initialVelocity
    }

    /// 获取当前状态（不推进时间）
    public func current() -> SpringState {
        let target: CGFloat = 1
        let atRest =
            abs(velocity) < restThreshold &&
            abs(position - target) < restThreshold
        return SpringState(position: position, velocity: velocity, atRest: atRest)
    }
}

/// 预计算弹簧动画总时长（秒），通过模拟求解直到静止来估算。
public func estimateSpringDuration(config: SpringConfig = SpringConfig()) -> TimeInterval {
    let solver = SpringSolver(config: config)
    let dt: CGFloat = 1.0 / 60.0
    var frames = 0
    let maxFrames = 600 // 最多 10 秒
    while frames < maxFrames {
        let state = solver.step(dt)
        frames += 1
        if state.atRest { break }
    }
    return TimeInterval(frames) / 60.0
}

/// 弹簧动画驱动器 —— 用 CADisplayLink 逐帧驱动弹簧求解，输出 0→1 进度。
///
/// 使用固定步长累加器：物理步长恒定 1/60s（与 Web 端及 Android 端数值一致、
/// 保持确定性），每帧执行的步数按真实经过时间自适应，因此与屏幕刷新率无关
/// （120Hz ProMotion / 60Hz 表现一致）。
///
/// - Note: 调用方需持有 SpringAnimator 实例，释放时 deinit 自动停止。
public final class SpringAnimator {
    private let solver: SpringSolver
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var accumulator: CFTimeInterval = 0
    private var onUpdate: ((CGFloat) -> Void)?
    private var onRest: (() -> Void)?

    /// 固定物理步长（秒）
    private let fixedStep: CFTimeInterval = 1.0 / 60.0
    /// 单帧最大经过时间，防止后台恢复时时间跳变导致发散
    private let maxFrameTime: CFTimeInterval = 0.25

    public init(config: SpringConfig = SpringPresets.gentle) {
        self.solver = SpringSolver(config: config)
    }

    /// 启动弹簧动画。
    ///
    /// - Parameters:
    ///   - onUpdate: 每帧回调，参数为当前进度（0→1，可能因弹跳略超过 1）
    ///   - onRest: 到达静止时回调一次
    public func start(onUpdate: @escaping (CGFloat) -> Void, onRest: (() -> Void)? = nil) {
        stop()
        solver.reset()
        self.onUpdate = onUpdate
        self.onRest = onRest
        lastTimestamp = 0
        accumulator = 0

        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        // 解锁 ProMotion 高刷：CADisplayLink 在 120Hz 设备上默认仅 60fps，
        // 需显式设置 preferredFrameRateRange（iOS 15+）才能跑满帧。
        // 固定步长累加器保证物理不受帧率影响，高刷只带来更平滑的插值。
        if #available(iOS 15.0, *) {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        }
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// 停止动画并清理。
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            // 首帧输出初始位置
            onUpdate?(solver.current().position)
            return
        }

        var frameTime = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        if frameTime > maxFrameTime { frameTime = maxFrameTime }
        accumulator += frameTime

        var state = solver.current()
        while accumulator >= fixedStep {
            state = solver.step(CGFloat(fixedStep))
            accumulator -= fixedStep
            if state.atRest { break }
        }

        onUpdate?(state.position)

        if state.atRest {
            stop()
            onRest?()
        }
    }
}
