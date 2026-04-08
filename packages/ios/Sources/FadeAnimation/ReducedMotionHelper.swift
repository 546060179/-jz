import UIKit

enum ReducedMotionHelper {
    static func isReducedMotionEnabled() -> Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
}
