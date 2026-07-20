import Foundation

/// 编排方向 —— 对齐 Web 端 StaggerOptions.direction。
public enum StaggerDirection {
    case forward
    case reverse
    case center
}

/// 编排配置 —— 对齐 Web 端 @fade-animation/core 的 StaggerOptions。
public struct StaggerOptions {
    /// 每个子元素之间的延迟间隔（ms）
    public var interval: Int
    /// 起始延迟（ms），默认 0
    public var baseDelay: Int = 0
    /// 编排方向，默认 forward
    public var direction: StaggerDirection = .forward

    public init(interval: Int, baseDelay: Int = 0, direction: StaggerDirection = .forward) {
        self.interval = interval
        self.baseDelay = baseDelay
        self.direction = direction
    }
}

/// 编排工具：计算每个子元素的延迟时间（ms）。
///
/// 与 Web 端 stagger() 数值完全一致，用于多元素协同动画时创造有节奏的视觉流。
///
/// - Parameters:
///   - count: 子元素总数
///   - options: 编排配置
/// - Returns: 每个子元素的延迟时间数组（ms）
///
/// ```swift
/// // 5 个卡片依次入场，间隔 50ms
/// stagger(5, options: StaggerOptions(interval: 50))
/// // → [0, 50, 100, 150, 200]
///
/// let delays = stagger(items.count, options: StaggerOptions(interval: 60))
/// for (i, view) in itemViews.enumerated() {
///   MotionAnimator(targetView: view,
///     options: FadeOptions(delay: delays[i], intent: .enter))
///     .start(entering: true, effects: EffectPresets.scaleFadeIn)
/// }
/// ```
public func stagger(_ count: Int, options: StaggerOptions) -> [Int] {
    if count <= 0 { return [] }

    let safeInterval = max(0, options.interval)
    let safeBase = max(0, options.baseDelay)

    var delays: [Int] = []
    delays.reserveCapacity(count)

    switch options.direction {
    case .reverse:
        for i in 0..<count {
            delays.append(safeBase + (count - 1 - i) * safeInterval)
        }
    case .center:
        let center = Double(count - 1) / 2.0
        for i in 0..<count {
            let offset = (abs(Double(i) - center) * Double(safeInterval)).rounded()
            delays.append(safeBase + Int(offset))
        }
    case .forward:
        for i in 0..<count {
            delays.append(safeBase + i * safeInterval)
        }
    }

    return delays
}
