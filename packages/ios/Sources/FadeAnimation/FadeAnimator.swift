import UIKit

/// 核心淡入淡出动画控制器。
///
/// 使用 UIView.animate 驱动 alpha 动画，支持：
/// - fadeIn（不透明度 0→1）和 fadeOut（不透明度 1→0）
/// - 自定义 duration、delay、curve
/// - 预设速度方案（fast/normal/slow）
/// - 动画结束回调（保证仅调用一次）
/// - 安全网定时器，确保回调在异常情况下也能触发
/// - deinit 中自动取消动画并清理资源
///
/// - Note: targetView 使用 strong 引用，FadeAnimator 不会被 view 反向持有，
///   因此不会产生循环引用。调用方释放 animator 时 deinit 自动清理。
public class FadeAnimator {

    /// 动画目标视图。
    /// 使用 strong 引用确保动画执行期间视图不会被意外释放。
    /// FadeAnimator 本身应由调用方持有，调用方释放 animator 时
    /// deinit 会自动取消动画并清理资源，不会造成循环引用。
    private let targetView: UIView

    /// 用户传入的动画配置选项
    private let options: FadeOptions

    /// 确保 onEnd 回调仅调用一次的标志
    private var callbackInvoked: Bool = false

    /// 安全网定时器的 DispatchWorkItem
    private var safetyTimer: DispatchWorkItem?

    /// 初始化 FadeAnimator。
    ///
    /// - Parameters:
    ///   - targetView: 动画目标 UIView
    ///   - options: 动画配置选项，默认使用 FadeOptions 默认值
    public init(targetView: UIView, options: FadeOptions = FadeOptions()) {
        self.targetView = targetView
        self.options = options
    }

    /// 启动淡入或淡出动画。
    ///
    /// 如果有正在进行的动画，会先取消再启动新动画。
    ///
    /// - Parameters:
    ///   - fadeIn: true 执行淡入（alpha 0→1），false 执行淡出（alpha 1→0）。默认 true。
    ///   - onEnd: 动画结束时的回调，保证仅调用一次；nil 表示不需要回调。
    public func start(fadeIn: Bool = true, onEnd: (() -> Void)? = nil) {
        // 取消之前的动画（不触发旧回调）
        cancelInternal()

        // 重置回调标志
        callbackInvoked = false

        let view = targetView

        // 解析配置
        let config = resolveConfig(options: options)

        // 确定目标 alpha 和初始 alpha
        let targetAlpha: CGFloat = fadeIn ? 1.0 : 0.0
        let initialAlpha: CGFloat = fadeIn ? 0.0 : 1.0

        // 设置初始不透明度
        view.alpha = initialAlpha

        // 合并回调：options.onAnimationEnd 和 start 参数的 onEnd
        let combinedOnEnd: (() -> Void)?
        if let optionsEnd = options.onAnimationEnd, let paramEnd = onEnd {
            combinedOnEnd = {
                optionsEnd()
                paramEnd()
            }
        } else if let optionsEnd = options.onAnimationEnd {
            combinedOnEnd = optionsEnd
        } else {
            combinedOnEnd = onEnd
        }

        // 安全触发回调的辅助闭包（确保仅调用一次）
        let invokeOnEnd: () -> Void = { [weak self] in
            guard let self = self else { return }
            guard !self.callbackInvoked else { return }
            self.callbackInvoked = true
            self.cleanupSafetyTimer()
            combinedOnEnd?()
        }

        // 使用精确的 cubic-bezier 控制点驱动动画，逐帧对齐 Web 端缓动。
        // 若 duration 为 0（reduced/none 或用户显式设置），直接跳到终态并回调。
        if config.duration <= 0 {
            view.alpha = targetAlpha
            invokeOnEnd()
        } else {
            let bezier = CubicBezierCurve(
                timingFunction: config.timingFunction
                    ?? CubicBezierCurve(animationCurve: config.curve).timingFunction
            )
            let propertyAnimator = UIViewPropertyAnimator(
                duration: config.duration,
                controlPoint1: bezier.c1,
                controlPoint2: bezier.c2,
                animations: {
                    view.alpha = targetAlpha
                }
            )
            propertyAnimator.addCompletion { _ in
                invokeOnEnd()
            }
            propertyAnimator.startAnimation(afterDelay: config.delay)
        }

        // 设置安全网定时器：duration + delay + 0.05s
        if combinedOnEnd != nil {
            let safetyDelay = config.duration + config.delay + 0.05
            let workItem = DispatchWorkItem { [weak self] in
                guard self != nil else { return }
                invokeOnEnd()
            }
            safetyTimer = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + safetyDelay, execute: workItem)
        }
    }

    /// 取消当前正在进行的动画并清理所有资源。
    ///
    /// 取消后不会触发 onEnd 回调。
    public func cancel() {
        cancelInternal()
    }

    deinit {
        cancelInternal()
    }

    // MARK: - Private

    /// 内部取消方法：移除所有动画、标记回调已处理、清理定时器。
    private func cancelInternal() {
        // 标记回调已处理（防止后续触发）
        callbackInvoked = true

        // 移除目标视图上的所有动画
        targetView.layer.removeAllAnimations()

        // 清理安全网定时器
        cleanupSafetyTimer()
    }

    /// 取消并清理安全网定时器。
    private func cleanupSafetyTimer() {
        safetyTimer?.cancel()
        safetyTimer = nil
    }
}
