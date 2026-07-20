import UIKit

/// 时间刻度枚举 — 对齐 Web 端 @fade-animation/core tokens
public enum TimingScale: String {
    case t1, t2, t3, t4, t5

    public var durationMs: Int {
        switch self {
        case .t1: return 100
        case .t2: return 150
        case .t3: return 300
        case .t4: return 500
        case .t5: return 700
        }
    }
}

/// 预设速度枚举（向后兼容）
/// 新代码建议使用 TimingScale 替代
public enum PresetSpeed: String {
    case fast
    case normal
    case slow

    public var durationMs: Int {
        switch self {
        case .fast: return TimingScale.t2.durationMs    // 150ms
        case .normal: return TimingScale.t3.durationMs  // 300ms
        case .slow: return TimingScale.t4.durationMs    // 500ms
        }
    }
}

/// 动效意图枚举 — 对齐 Web 端 @fade-animation/core tokens
public enum MotionIntent: String {
    case enter
    case exit
    case focus
    case feedback
    case delight

    public var timing: TimingScale {
        switch self {
        case .enter: return .t3
        case .exit: return .t2
        case .focus: return .t2
        case .feedback: return .t1
        case .delight: return .t4
        }
    }

    public var curve: UIView.AnimationCurve {
        switch self {
        case .enter: return .easeOut
        case .exit: return .easeIn
        case .focus: return .easeInOut
        case .feedback: return .easeInOut
        case .delight: return .easeOut
        }
    }

    /// 精确的 CAMediaTimingFunction，对齐 Web 端 cubic-bezier
    var timingFunction: CAMediaTimingFunction {
        switch self {
        case .enter: return EasingCurves.enter
        case .exit: return EasingCurves.exit
        case .focus: return EasingCurves.expressive
        case .feedback: return EasingCurves.productive
        case .delight: return EasingCurves.expressive
        }
    }
}

/// 默认值常量
enum Defaults {
    static let duration: Int = TimingScale.t3.durationMs  // 300ms
    static let delay: Int = 0
    static let curve: UIView.AnimationCurve = .easeInOut
    static let preset: PresetSpeed = .normal
}
