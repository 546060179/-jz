import UIKit
import ObjectiveC

/// 用于在 UIView 上关联存储 FadeAnimator 实例的 key
private var fadeAnimatorKey: UInt8 = 0

extension UIView {

    /// 当前关联的 FadeAnimator（强引用，防止 ARC 提前释放）
    private var currentFadeAnimator: FadeAnimator? {
        get {
            objc_getAssociatedObject(self, &fadeAnimatorKey) as? FadeAnimator
        }
        set {
            objc_setAssociatedObject(self, &fadeAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func fadeIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        fade(fadeIn: true, options: options, onEnd: onEnd)
    }

    func fadeOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        fade(fadeIn: false, options: options, onEnd: onEnd)
    }

    func fade(fadeIn: Bool = true, options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        let animator = FadeAnimator(targetView: self, options: options)
        // 通过 associated object 持有 animator，防止 ARC 立即释放
        self.currentFadeAnimator = animator
        animator.start(fadeIn: fadeIn, onEnd: { [weak self] in
            // 动画结束后释放 animator
            self?.currentFadeAnimator = nil
            onEnd?()
        })
    }
}
