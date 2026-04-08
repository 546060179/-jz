import UIKit

/// 动画配置选项（用户传入）
struct FadeOptions {
    var fadeIn: Bool = true
    var duration: Int? = nil
    var delay: Int? = nil
    var curve: UIView.AnimationCurve? = nil
    var preset: PresetSpeed? = nil
    /// 时间刻度（新 token 体系），优先级高于 preset
    var timing: TimingScale? = nil
    /// 动效意图，自动推导 timing 和 curve
    var intent: MotionIntent? = nil
    var onAnimationEnd: (() -> Void)? = nil
}

/// 解析后的配置（所有字段已确定）
struct FadeConfig {
    let duration: TimeInterval
    let delay: TimeInterval
    let curve: UIView.AnimationCurve
    let reducedMotion: Bool
}
