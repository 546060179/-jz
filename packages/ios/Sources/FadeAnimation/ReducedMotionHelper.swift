import UIKit

public enum ReducedMotionHelper {
    /// 动效级别 — 对齐 Web 端 MotionLevel
    public enum MotionLevel {
        case full
        case reduced
        case none
    }

    /// reduced 模式下的最大时长（ms）— 对齐 Web 端 REDUCED_MAX_DURATION
    public static let reducedMaxDurationMs: Int = TimingScale.t1.durationMs // 100ms

    /// 全局动效级别覆盖，nil 表示跟随系统偏好
    private static var globalMotionLevel: MotionLevel?

    /// 设置全局动效级别，传入 nil 恢复为跟随系统偏好
    public static func setMotionLevel(_ level: MotionLevel?) {
        globalMotionLevel = level
    }

    /// 获取当前全局动效级别设置
    public static func getMotionLevel() -> MotionLevel? {
        return globalMotionLevel
    }

    /// 解析当前生效的动效级别
    /// 优先级：全局设置 > 系统偏好 > full
    public static func resolveMotionLevel() -> MotionLevel {
        if let level = globalMotionLevel {
            return level
        }
        return UIAccessibility.isReduceMotionEnabled ? .none : .full
    }

    /// 向后兼容：检测是否启用了减少动效
    public static func isReducedMotionEnabled() -> Bool {
        return resolveMotionLevel() != .full
    }
}
