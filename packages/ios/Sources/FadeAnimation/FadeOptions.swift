import UIKit

/// 动画配置选项（用户传入）
public struct FadeOptions {
    public var fadeIn: Bool = true
    public var duration: Int? = nil
    public var delay: Int? = nil
    public var curve: UIView.AnimationCurve? = nil
    /// 自定义 cubic-bezier 控制点 (c1x, c1y, c2x, c2y)，优先级高于 curve
    public var timingFunction: CAMediaTimingFunction? = nil
    public var preset: PresetSpeed? = nil
    /// 时间刻度（新 token 体系），优先级高于 preset
    public var timing: TimingScale? = nil
    /// 动效意图，自动推导 timing 和 curve
    public var intent: MotionIntent? = nil
    public var onAnimationEnd: (() -> Void)? = nil

    public init(
        fadeIn: Bool = true,
        duration: Int? = nil,
        delay: Int? = nil,
        curve: UIView.AnimationCurve? = nil,
        timingFunction: CAMediaTimingFunction? = nil,
        preset: PresetSpeed? = nil,
        timing: TimingScale? = nil,
        intent: MotionIntent? = nil,
        onAnimationEnd: (() -> Void)? = nil
    ) {
        self.fadeIn = fadeIn
        self.duration = duration
        self.delay = delay
        self.curve = curve
        self.timingFunction = timingFunction
        self.preset = preset
        self.timing = timing
        self.intent = intent
        self.onAnimationEnd = onAnimationEnd
    }
}

/// 解析后的配置（所有字段已确定）
struct FadeConfig {
    let duration: TimeInterval
    let delay: TimeInterval
    let curve: UIView.AnimationCurve
    /// 精确的 CAMediaTimingFunction（如设置，优先于 curve）
    let timingFunction: CAMediaTimingFunction?
    let reducedMotion: Bool
}

/// 对齐 Web 端缓动曲线的精确 CAMediaTimingFunction
enum EasingCurves {
    /// productive: cubic-bezier(0.2, 0, 0.38, 0.9)
    static let productive = CAMediaTimingFunction(controlPoints: 0.2, 0, 0.38, 0.9)
    /// expressive: cubic-bezier(0.4, 0.14, 0.3, 1)
    static let expressive = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1)
    /// enter: cubic-bezier(0, 0, 0.3, 1)
    static let enter = CAMediaTimingFunction(controlPoints: 0, 0, 0.3, 1)
    /// exit: cubic-bezier(0.4, 0, 1, 1)
    static let exit = CAMediaTimingFunction(controlPoints: 0.4, 0, 1, 1)
    /// linear
    static let linear = CAMediaTimingFunction(name: .linear)
    /// 默认 ease: cubic-bezier(0.25, 0.1, 0.25, 1)（对齐 Web 端 DEFAULTS.easing）
    static let ease = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
    /// bounce: cubic-bezier(0.34, 1.56, 0.64, 1) 过冲回落，弹性入场（对齐 Web EASING_CURVES.bounce）
    static let bounce = CAMediaTimingFunction(controlPoints: 0.34, 1.56, 0.64, 1)
}
