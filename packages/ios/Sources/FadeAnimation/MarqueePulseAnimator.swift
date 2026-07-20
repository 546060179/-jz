import UIKit

/// 跑马灯脉冲动画配置
public struct MarqueePulseConfig {
    /// 单个元素动画周期（ms），默认 800（t4 + stagger）
    public var cycleDurationMs: Int = 800
    /// 元素间交错延迟（ms），默认 150
    public var staggerIntervalMs: Int = 150
    /// 最小 opacity，默认 0.4
    public var minOpacity: Float = 0.4
    /// 最大 opacity，默认 1.0
    public var maxOpacity: Float = 1.0
    /// 最小 scale，默认 1.0
    public var minScale: CGFloat = 1.0
    /// 最大 scale，默认 1.15
    public var maxScale: CGFloat = 1.15

    public init(
        cycleDurationMs: Int = 800,
        staggerIntervalMs: Int = 150,
        minOpacity: Float = 0.4,
        maxOpacity: Float = 1.0,
        minScale: CGFloat = 1.0,
        maxScale: CGFloat = 1.15
    ) {
        self.cycleDurationMs = cycleDurationMs
        self.staggerIntervalMs = staggerIntervalMs
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
        self.minScale = minScale
        self.maxScale = maxScale
    }
}

/// MarqueePulseAnimator — 纯动效工具
///
/// 给任意一组 CALayer 添加交错脉冲动画（opacity + scale），
/// 形成跑马灯式的波浪效果。
///
/// 不包含任何 UI 布局，只负责动画逻辑。
///
/// ```swift
/// let animator = MarqueePulseAnimator()
/// animator.apply(to: [dot1.layer, dot2.layer, dot3.layer])
/// // 停止
/// animator.remove(from: [dot1.layer, dot2.layer, dot3.layer])
/// ```
public class MarqueePulseAnimator {

    private let config: MarqueePulseConfig
    static let animationKey = "marqueePulse"

    public init(config: MarqueePulseConfig = MarqueePulseConfig()) {
        self.config = config
    }

    /// 给一组 layer 添加跑马灯脉冲动画
    public func apply(to layers: [CALayer]) {
        let count = layers.count
        guard count > 0 else { return }

        let totalDuration = CFTimeInterval(config.cycleDurationMs) / 1000.0

        for (i, layer) in layers.enumerated() {
            let delay = CFTimeInterval(i * config.staggerIntervalMs) / 1000.0

            let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim.values = [config.minOpacity, config.maxOpacity, config.minOpacity]
            opacityAnim.keyTimes = [0, 0.5, 1.0]

            let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnim.values = [config.minScale, config.maxScale, config.minScale]
            scaleAnim.keyTimes = [0, 0.5, 1.0]

            let group = CAAnimationGroup()
            group.animations = [opacityAnim, scaleAnim]
            group.duration = totalDuration
            group.beginTime = CACurrentMediaTime() + delay
            group.repeatCount = .infinity
            group.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1.0)

            layer.add(group, forKey: MarqueePulseAnimator.animationKey)
        }
    }

    /// 移除动画
    public func remove(from layers: [CALayer]) {
        for layer in layers {
            layer.removeAnimation(forKey: MarqueePulseAnimator.animationKey)
        }
    }
}
