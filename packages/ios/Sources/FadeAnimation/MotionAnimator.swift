import UIKit

/// 通用动效控制器 — 对齐 Web 端 <Motion> 组件。
///
/// 支持 fade、scale、slide、flip、collapse 及其任意组合，使用 UIView.animate 驱动。
/// FadeAnimator 保留作为向后兼容的特化版本。
class MotionAnimator {

    private let targetView: UIView
    private let options: FadeOptions
    private var callbackInvoked: Bool = false
    private var safetyTimer: DispatchWorkItem?
    /// 动态创建的高度约束（collapse 动画使用）
    private var dynamicHeightConstraint: NSLayoutConstraint?
    /// DisplayLink 用于驱动 flip 动画
    private var flipDisplayLink: CADisplayLink?
    private var flipStartTime: CFTimeInterval = 0
    private var flipDuration: CFTimeInterval = 0
    private var flipFromAngle: CGFloat = 0
    private var flipToAngle: CGFloat = 0
    private var flipAxis: FlipAxis = .y
    private var flipPerspective: CGFloat = 800
    private var flipBackfaceHidden: Bool = true
    private var flipInterpolator: UIView.AnimationCurve = .easeInOut

    init(targetView: UIView, options: FadeOptions = FadeOptions()) {
        self.targetView = targetView
        self.options = options
    }

    /// 启动动画。
    ///
    /// - Parameters:
    ///   - entering: true 为进入动画，false 为退出动画
    ///   - effects: 效果列表，支持 fade、scale、slide、flip、collapse 的任意组合
    ///   - onEnd: 动画结束回调，保证仅调用一次
    func start(
        entering: Bool = true,
        effects: [MotionEffect] = EffectPresets.fadeIn,
        onEnd: (() -> Void)? = nil
    ) {
        cancelInternal()
        callbackInvoked = false

        let view = targetView
        let config = resolveConfig(options: options)

        // Flip + Rotate 冲突检测：优先 Flip，忽略 Rotate
        let hasFlip = effects.contains { if case .flip = $0 { return true }; return false }
        let hasRotate = effects.contains { if case .rotate = $0 { return true }; return false }
        let resolvedEffects: [MotionEffect]
        if hasFlip && hasRotate {
            print("[FadeAnimation] FlipEffect and RotateEffect cannot be used together. RotateEffect will be ignored.")
            resolvedEffects = effects.filter { if case .rotate = $0 { return false }; return true }
        } else {
            resolvedEffects = effects
        }

        // 合并回调
        let combinedOnEnd: (() -> Void)?
        if let optionsEnd = options.onAnimationEnd, let paramEnd = onEnd {
            combinedOnEnd = { optionsEnd(); paramEnd() }
        } else if let optionsEnd = options.onAnimationEnd {
            combinedOnEnd = optionsEnd
        } else {
            combinedOnEnd = onEnd
        }

        let invokeOnEnd: () -> Void = { [weak self] in
            guard let self = self, !self.callbackInvoked else { return }
            self.callbackInvoked = true
            self.cleanupSafetyTimer()
            combinedOnEnd?()
        }

        // 设置初始状态
        for effect in resolvedEffects {
            switch effect {
            case .fade(let from, _):
                view.alpha = from ?? (entering ? 0 : 1)
            case .scale(let from, _):
                let s = from ?? (entering ? 0.95 : 1)
                view.transform = view.transform.scaledBy(x: s, y: s)
            case .slide(let direction, let distance):
                switch direction {
                case .up:    view.transform = view.transform.translatedBy(x: 0, y: distance)
                case .down:  view.transform = view.transform.translatedBy(x: 0, y: -distance)
                case .left:  view.transform = view.transform.translatedBy(x: distance, y: 0)
                case .right: view.transform = view.transform.translatedBy(x: -distance, y: 0)
                }
            case .rotate(let from, _):
                let angle = from ?? (entering ? -10 : 0)
                let radians = angle * .pi / 180
                view.transform = view.transform.rotated(by: radians)
            case .blur:
                break
            case .flip(let axis, let from, let to, let perspective, let backfaceVisibility):
                let startAngle = entering ? from : to
                applyFlipTransform(angle: startAngle, axis: axis, perspective: perspective)
                view.layer.isDoubleSided = (backfaceVisibility != "hidden")
            case .collapse(let collapsedHeight):
                let contentHeight = measureContentHeight()
                let collapsedPx = resolveCollapsedHeight(collapsedHeight)
                let startHeight = entering ? collapsedPx : contentHeight
                view.clipsToBounds = true
                applyHeightConstraint(height: startHeight)
            }
        }

        let curveOption = animationOptions(from: config.curve)

        // 启动 flip 动画（使用 CATransform3D，独立于 UIView.animate 的 2D transform）
        let flipEffect = resolvedEffects.compactMap { effect -> (FlipAxis, CGFloat, CGFloat, CGFloat, String)? in
            if case .flip(let axis, let from, let to, let perspective, let bfv) = effect {
                return (axis, from, to, perspective, bfv)
            }
            return nil
        }.first

        if let (axis, from, to, perspective, backfaceVisibility) = flipEffect {
            let startAngle = entering ? from : to
            let endAngle = entering ? to : from
            startFlipAnimation(
                startAngle: startAngle,
                endAngle: endAngle,
                axis: axis,
                perspective: perspective,
                backfaceHidden: backfaceVisibility == "hidden",
                duration: config.duration,
                delay: config.delay,
                curve: config.curve
            )
        }

        // 启动 collapse 动画
        let collapseEffect = resolvedEffects.compactMap { effect -> CollapseHeight? in
            if case .collapse(let ch) = effect { return ch }
            return nil
        }.first

        if let collapsedHeight = collapseEffect {
            let contentHeight = measureContentHeight()
            let collapsedPx = resolveCollapsedHeight(collapsedHeight)
            let startHeight = entering ? collapsedPx : contentHeight
            let endHeight = entering ? contentHeight : collapsedPx
            startCollapseAnimation(
                startHeight: startHeight,
                endHeight: endHeight,
                entering: entering,
                duration: config.duration,
                delay: config.delay,
                curve: config.curve,
                onEnd: nil // completion handled by main animation
            )
        }

        UIView.animate(
            withDuration: config.duration,
            delay: config.delay,
            options: curveOption,
            animations: {
                for effect in resolvedEffects {
                    switch effect {
                    case .fade(_, let to):
                        view.alpha = to ?? (entering ? 1 : 0)
                    case .scale, .slide, .rotate:
                        break // handled by transform reset below
                    case .blur:
                        break
                    case .flip:
                        break // driven by CADisplayLink
                    case .collapse:
                        break // driven by separate UIView.animate
                    }
                }
                // Reset transform to identity for scale + slide targets
                let hasTransformEffect = resolvedEffects.contains { effect in
                    switch effect {
                    case .scale, .slide, .rotate: return true
                    default: return false
                    }
                }
                if hasTransformEffect {
                    view.transform = .identity
                }
            },
            completion: { _ in invokeOnEnd() }
        )

        // 安全网定时器
        if combinedOnEnd != nil {
            let workItem = DispatchWorkItem { [weak self] in
                guard self != nil else { return }
                invokeOnEnd()
            }
            safetyTimer = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + config.duration + config.delay + 0.05,
                execute: workItem
            )
        }
    }

    func cancel() { cancelInternal() }

    deinit { cancelInternal() }

    // MARK: - Flip Animation (CATransform3D)

    /// 将 3D 翻转变换应用到目标 view 的 layer。
    ///
    /// - Parameters:
    ///   - angle: 旋转角度（度）
    ///   - axis: 翻转轴 (.x 或 .y)
    ///   - perspective: 透视距离（px）
    private func applyFlipTransform(angle: CGFloat, axis: FlipAxis, perspective: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / perspective
        let radians = angle * .pi / 180
        switch axis {
        case .x:
            transform = CATransform3DRotate(transform, radians, 1, 0, 0)
        case .y:
            transform = CATransform3DRotate(transform, radians, 0, 1, 0)
        }
        targetView.layer.transform = transform
    }

    /// 启动 flip 动画，使用 CADisplayLink 驱动帧更新。
    private func startFlipAnimation(
        startAngle: CGFloat,
        endAngle: CGFloat,
        axis: FlipAxis,
        perspective: CGFloat,
        backfaceHidden: Bool,
        duration: TimeInterval,
        delay: TimeInterval,
        curve: UIView.AnimationCurve
    ) {
        stopFlipDisplayLink()

        flipFromAngle = startAngle
        flipToAngle = endAngle
        flipAxis = axis
        flipPerspective = perspective
        flipBackfaceHidden = backfaceHidden
        flipDuration = duration
        flipInterpolator = curve
        flipStartTime = 0 // will be set on first tick

        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.createAndStartFlipDisplayLink()
            }
        } else {
            createAndStartFlipDisplayLink()
        }
    }

    private func createAndStartFlipDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(flipDisplayLinkTick(_:)))
        displayLink.add(to: .main, forMode: .common)
        flipDisplayLink = displayLink
    }

    @objc private func flipDisplayLinkTick(_ displayLink: CADisplayLink) {
        if flipStartTime == 0 {
            flipStartTime = displayLink.timestamp
        }

        let elapsed = displayLink.timestamp - flipStartTime
        var progress = flipDuration > 0 ? CGFloat(elapsed / flipDuration) : 1.0
        progress = min(max(progress, 0), 1)

        // Apply easing curve
        let easedProgress = applyEasing(progress, curve: flipInterpolator)

        let currentAngle = flipFromAngle + (flipToAngle - flipFromAngle) * easedProgress
        applyFlipTransform(angle: currentAngle, axis: flipAxis, perspective: flipPerspective)

        // Handle backface visibility
        if flipBackfaceHidden {
            let normalizedAngle = ((currentAngle.truncatingRemainder(dividingBy: 360)) + 360)
                .truncatingRemainder(dividingBy: 360)
            targetView.isHidden = (normalizedAngle > 90 && normalizedAngle < 270)
        }

        if progress >= 1.0 {
            stopFlipDisplayLink()
            // Ensure final state is exact
            applyFlipTransform(angle: flipToAngle, axis: flipAxis, perspective: flipPerspective)
            if flipBackfaceHidden {
                let normalizedAngle = ((flipToAngle.truncatingRemainder(dividingBy: 360)) + 360)
                    .truncatingRemainder(dividingBy: 360)
                targetView.isHidden = (normalizedAngle > 90 && normalizedAngle < 270)
            }
        }
    }

    /// 简单的缓动函数近似
    private func applyEasing(_ t: CGFloat, curve: UIView.AnimationCurve) -> CGFloat {
        switch curve {
        case .linear:
            return t
        case .easeIn:
            return t * t
        case .easeOut:
            return 1 - (1 - t) * (1 - t)
        case .easeInOut:
            return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
        @unknown default:
            return t
        }
    }

    private func stopFlipDisplayLink() {
        flipDisplayLink?.invalidate()
        flipDisplayLink = nil
    }

    // MARK: - Collapse Animation (Height Constraint)

    /// 测量目标 view 子内容的实际高度。
    private func measureContentHeight() -> CGFloat {
        let view = targetView
        if view.translatesAutoresizingMaskIntoConstraints {
            // Frame-based layout: use sizeToFit
            view.sizeToFit()
            return view.bounds.height
        } else {
            // Auto Layout: use systemLayoutSizeFitting
            let fittingSize = CGSize(width: view.bounds.width, height: 0)
            let size = view.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return size.height
        }
    }

    /// 解析 collapsedHeight 枚举为具体像素值。
    private func resolveCollapsedHeight(_ collapsedHeight: CollapseHeight) -> CGFloat {
        switch collapsedHeight {
        case .fixed(let value):
            return value
        case .auto:
            return targetView.bounds.height
        }
    }

    /// 查找或创建目标 view 上的高度约束。
    private func findOrCreateHeightConstraint() -> NSLayoutConstraint {
        // 查找已有的高度约束
        for constraint in targetView.constraints {
            if constraint.firstAttribute == .height
                && constraint.secondItem == nil
                && constraint.firstItem === targetView {
                return constraint
            }
        }
        // 动态创建高度约束，优先级 999 避免冲突
        let constraint = NSLayoutConstraint(
            item: targetView as Any,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: targetView.bounds.height
        )
        constraint.priority = UILayoutPriority(999)
        targetView.addConstraint(constraint)
        dynamicHeightConstraint = constraint
        return constraint
    }

    /// 应用高度约束值。
    private func applyHeightConstraint(height: CGFloat) {
        if targetView.translatesAutoresizingMaskIntoConstraints {
            // Frame-based layout: directly set frame height
            var frame = targetView.frame
            frame.size.height = height
            targetView.frame = frame
        } else {
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = height
            targetView.superview?.layoutIfNeeded()
        }
    }

    /// 启动 collapse 动画。
    private func startCollapseAnimation(
        startHeight: CGFloat,
        endHeight: CGFloat,
        entering: Bool,
        duration: TimeInterval,
        delay: TimeInterval,
        curve: UIView.AnimationCurve,
        onEnd: (() -> Void)?
    ) {
        let view = targetView
        view.clipsToBounds = true

        if view.translatesAutoresizingMaskIntoConstraints {
            // Frame-based: animate frame height
            var frame = view.frame
            frame.size.height = startHeight
            view.frame = frame

            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: animationOptions(from: curve),
                animations: {
                    var frame = view.frame
                    frame.size.height = endHeight
                    view.frame = frame
                },
                completion: { _ in
                    if entering {
                        // Expand complete: restore natural size
                        view.sizeToFit()
                    }
                    onEnd?()
                }
            )
        } else {
            // Auto Layout: animate height constraint
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = startHeight
            view.superview?.layoutIfNeeded()

            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: animationOptions(from: curve),
                animations: {
                    constraint.constant = endHeight
                    view.superview?.layoutIfNeeded()
                },
                completion: { [weak self] _ in
                    if entering {
                        // Expand complete: remove dynamic constraint to allow free sizing
                        if let dynamicConstraint = self?.dynamicHeightConstraint {
                            view.removeConstraint(dynamicConstraint)
                            self?.dynamicHeightConstraint = nil
                        }
                    }
                    // Collapse complete: keep constraint to maintain collapsed state
                    onEnd?()
                }
            )
        }
    }

    // MARK: - Private

    private func cancelInternal() {
        callbackInvoked = true
        targetView.layer.removeAllAnimations()
        stopFlipDisplayLink()
        // Clean up dynamic height constraint if collapse animation was in progress
        if let constraint = dynamicHeightConstraint {
            targetView.removeConstraint(constraint)
            dynamicHeightConstraint = nil
        }
        cleanupSafetyTimer()
    }

    private func cleanupSafetyTimer() {
        safetyTimer?.cancel()
        safetyTimer = nil
    }

    private func animationOptions(from curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch curve {
        case .easeInOut: return .curveEaseInOut
        case .easeIn:    return .curveEaseIn
        case .easeOut:   return .curveEaseOut
        case .linear:    return .curveLinear
        @unknown default: return .curveEaseInOut
        }
    }
}
