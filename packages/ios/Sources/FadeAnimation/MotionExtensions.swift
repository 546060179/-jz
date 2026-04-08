import UIKit
import ObjectiveC

/// 用于在 UIView 上关联存储 MotionAnimator 实例的 key
private var motionAnimatorKey: UInt8 = 0

extension UIView {

    /// 当前关联的 MotionAnimator
    private var currentMotionAnimator: MotionAnimator? {
        get {
            objc_getAssociatedObject(self, &motionAnimatorKey) as? MotionAnimator
        }
        set {
            objc_setAssociatedObject(self, &motionAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 通用动效入口
    func motion(
        entering: Bool = true,
        effects: [MotionEffect] = EffectPresets.fadeIn,
        options: FadeOptions = FadeOptions(),
        onEnd: (() -> Void)? = nil
    ) {
        let animator = MotionAnimator(targetView: self, options: options)
        self.currentMotionAnimator = animator
        animator.start(entering: entering, effects: effects, onEnd: { [weak self] in
            self?.currentMotionAnimator = nil
            onEnd?()
        })
    }

    /// 缩放淡入
    func scaleFadeIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: true, effects: EffectPresets.scaleFadeIn, options: options, onEnd: onEnd)
    }

    /// 缩放淡出
    func scaleFadeOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: false, effects: EffectPresets.scaleFadeOut, options: options, onEnd: onEnd)
    }

    /// 从下方滑入 + 淡入
    func slideUpIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: true, effects: EffectPresets.slideUpIn, options: options, onEnd: onEnd)
    }

    /// 向下滑出 + 淡出
    func slideDownOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: false, effects: EffectPresets.slideDownOut, options: options, onEnd: onEnd)
    }

    /// 从左侧滑入 + 淡入
    func slideLeftIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: true, effects: EffectPresets.slideLeftIn, options: options, onEnd: onEnd)
    }

    /// 从右侧滑入 + 淡入
    func slideRightIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Void)? = nil) {
        motion(entering: true, effects: EffectPresets.slideRightIn, options: options, onEnd: onEnd)
    }
}
