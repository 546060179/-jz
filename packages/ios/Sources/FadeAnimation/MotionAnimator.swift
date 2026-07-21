import UIKit
import CoreImage

/// 通用动效控制器 — 对齐 Web 端 <Motion> 组件。
///
/// 支持 fade、scale、slide、flip、collapse 及其任意组合，使用 UIView.animate 驱动。
/// FadeAnimator 保留作为向后兼容的特化版本。
public class MotionAnimator {

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
    private var flipBezier: CubicBezierCurve = CubicBezierCurve(0.42, 0, 0.58, 1)

    public init(targetView: UIView, options: FadeOptions = FadeOptions()) {
        self.targetView = targetView
        self.options = options
    }

    /// 启动动画。
    ///
    /// - Parameters:
    ///   - entering: true 为进入动画，false 为退出动画
    ///   - effects: 效果列表，支持 fade、scale、slide、flip、collapse、blur 的任意组合
    ///   - onEnd: 动画结束回调，保证仅调用一次
    public func start(
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

        // 构建初始 transform 和目标 transform
        // entering=true:  初始=变换状态(偏移/缩小/旋转), 目标=identity
        // entering=false: 初始=identity, 目标=变换状态(偏移/缩小/旋转)
        var initialTransform: CGAffineTransform = .identity
        var targetTransform: CGAffineTransform = .identity

        for effect in resolvedEffects {
            switch effect {
            case .scale(let from, let to):
                let scaleFrom = from ?? (entering ? 0.95 : 1)
                let scaleTo = to ?? (entering ? 1 : 0.95)
                initialTransform = initialTransform.scaledBy(x: scaleFrom, y: scaleFrom)
                targetTransform = targetTransform.scaledBy(x: scaleTo, y: scaleTo)
            case .slide(let direction, let distance):
                // entering=true:  初始偏移 → 目标原位
                // entering=false: 初始原位 → 目标偏移
                let dx: CGFloat
                let dy: CGFloat
                switch direction {
                case .up:    dx = 0; dy = distance
                case .down:  dx = 0; dy = -distance
                case .left:  dx = distance; dy = 0
                case .right: dx = -distance; dy = 0
                }
                if entering {
                    initialTransform = initialTransform.translatedBy(x: dx, y: dy)
                    // targetTransform 保持不变（identity 部分）
                } else {
                    // initialTransform 保持不变（identity 部分）
                    targetTransform = targetTransform.translatedBy(x: dx, y: dy)
                }
            case .rotate(let from, let to):
                let rotFrom = from ?? (entering ? -10 : 0)
                let rotTo = to ?? (entering ? 0 : 10)
                initialTransform = initialTransform.rotated(by: rotFrom * .pi / 180)
                targetTransform = targetTransform.rotated(by: rotTo * .pi / 180)
            default:
                break
            }
        }

        // 设置初始状态
        view.transform = initialTransform

        for effect in resolvedEffects {
            switch effect {
            case .fade(let from, _):
                view.alpha = from ?? (entering ? 0 : 1)
            case .blur(let from, let to):
                let blurFrom = from ?? (entering ? 8 : 0)
                let blurTo = to ?? (entering ? 0 : 8)
                installBlurOverlay(fromRadius: blurFrom, toRadius: blurTo, entering: entering)
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
            default:
                break
            }
        }

        // 解析精确 cubic-bezier 曲线，供主动画、collapse、flip 共用，逐帧对齐 Web 端
        let bezier = CubicBezierCurve(
            timingFunction: config.timingFunction
                ?? CubicBezierCurve(animationCurve: config.curve).timingFunction
        )

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
                bezier: bezier
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
                bezier: bezier,
                onEnd: nil // completion handled by main animation
            )
        }

        // 主动画：fade / blur / scale / slide / rotate 的目标态
        let mainAnimations = {
            for effect in resolvedEffects {
                switch effect {
                case .fade(_, let to):
                    view.alpha = to ?? (entering ? 1 : 0)
                case .blur:
                    // 进入：模糊截图叠加层淡出，露出下方清晰内容(由糊变清)
                    // 退出：模糊截图叠加层淡入(由清变糊)
                    self.blurOverlay?.alpha = entering ? 0 : 1
                case .scale, .slide, .rotate, .flip, .collapse:
                    break
                }
            }
            // 设置目标 transform
            view.transform = targetTransform
        }

        if config.duration <= 0 {
            // reduced/none 或零时长：直接落到终态
            mainAnimations()
            removeBlurOverlay()
            invokeOnEnd()
        } else {
            let propertyAnimator = UIViewPropertyAnimator(
                duration: config.duration,
                controlPoint1: bezier.c1,
                controlPoint2: bezier.c2,
                animations: mainAnimations
            )
            propertyAnimator.addCompletion { [weak self] _ in
                self?.removeBlurOverlay()
                invokeOnEnd()
            }
            propertyAnimator.startAnimation(afterDelay: config.delay)
        }

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

    /// 模糊截图叠加层（覆盖在目标上，用于"由糊变清/由清变糊"交叉淡化）
    private var blurOverlay: UIImageView?

    public func cancel() { cancelInternal() }

    deinit { cancelInternal() }

    // MARK: - Blur Animation（截图 + CIGaussianBlur 交叉淡化）

    /// 安装模糊截图叠加层。
    ///
    /// iOS 无公开 API 直接高斯模糊“控件自身内容”（`layer.filters` 在 iOS 上无效，
    /// `UIBlurEffect` 只模糊背后的背景并叠加磨砂材质）。这里对控件当前内容截图，
    /// 用 CIGaussianBlur 生成模糊图叠加在控件上，通过叠加层透明度做“由糊变清/由清变糊”。
    private func installBlurOverlay(fromRadius: CGFloat, toRadius: CGFloat, entering: Bool) {
        let view = targetView
        guard view.bounds.width > 1, view.bounds.height > 1 else { return }
        let maxRadius = max(fromRadius, toRadius)
        guard maxRadius > 0 else { return }

        // 截图（强制满透明度，避免捕捉到 fade 已设置的中间透明度）
        let savedOpacity = view.layer.opacity
        view.layer.opacity = 1
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds, format: format)
        let snapshot = renderer.image { ctx in view.layer.render(in: ctx.cgContext) }
        view.layer.opacity = savedOpacity

        guard let blurred = gaussianBlur(snapshot, radius: maxRadius) else { return }
        let iv = UIImageView(image: blurred)
        iv.frame = view.bounds
        iv.contentMode = .scaleToFill
        iv.isUserInteractionEnabled = false
        // 进入：先满模糊(alpha 1)再淡出露出清晰内容；退出：先清晰(alpha 0)再淡入模糊
        iv.alpha = entering ? 1 : 0
        view.addSubview(iv)
        blurOverlay = iv
    }

    /// 对图片做高斯模糊（边缘 clamp 避免透明扩散），失败时返回原图。
    private func gaussianBlur(_ image: UIImage, radius: CGFloat) -> UIImage? {
        guard radius > 0, let cg = image.cgImage else { return image }
        let ci = CIImage(cgImage: cg)
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return image }
        filter.setValue(ci.clampedToExtent(), forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = filter.outputImage else { return image }
        let ctx = CIContext(options: nil)
        guard let out = ctx.createCGImage(output, from: ci.extent) else { return image }
        return UIImage(cgImage: out, scale: image.scale, orientation: .up)
    }

    /// 移除模糊叠加层。
    private func removeBlurOverlay() {
        blurOverlay?.removeFromSuperview()
        blurOverlay = nil
    }

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
        bezier: CubicBezierCurve
    ) {
        stopFlipDisplayLink()

        flipFromAngle = startAngle
        flipToAngle = endAngle
        flipAxis = axis
        flipPerspective = perspective
        flipBackfaceHidden = backfaceHidden
        flipDuration = duration
        flipBezier = bezier
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
        // 解锁 ProMotion 高刷（iOS 15+），让 3D 翻转在 120Hz 设备上更顺滑
        if #available(iOS 15.0, *) {
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        }
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

        // Apply easing curve（与 Web 端 cubic-bezier 逐帧一致）
        let easedProgress = flipBezier.value(at: progress)

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

    private func stopFlipDisplayLink() {
        flipDisplayLink?.invalidate()
        flipDisplayLink = nil
    }

    // MARK: - Layout Mode Detection

    /// 检测目标 view 是否实际参与 Auto Layout。
    ///
    /// 不能单纯依赖 `translatesAutoresizingMaskIntoConstraints`，因为：
    /// - SnapKit 等库会自动设置该属性为 false
    /// - 但一个 view 即使 `translatesAutoresizingMaskIntoConstraints == true`，
    ///   也可能被父 view 的 Auto Layout 约束间接管理
    /// - 反之，一个 view 可能 `translatesAutoresizingMaskIntoConstraints == false`
    ///   但实际没有任何约束（手动设置后忘记加约束）
    ///
    /// 判断策略：
    /// 1. 如果 `translatesAutoresizingMaskIntoConstraints == false`，认为使用 Auto Layout
    /// 2. 如果 `translatesAutoresizingMaskIntoConstraints == true`，检查是否有外部约束
    ///    影响该 view 的高度（来自 superview 的约束），如果有则也走 Auto Layout 路径
    private var isUsingAutoLayout: Bool {
        let view = targetView

        // SnapKit / 手动 Auto Layout 都会设为 false
        if !view.translatesAutoresizingMaskIntoConstraints {
            return true
        }

        // translatesAutoresizingMaskIntoConstraints == true，
        // 但检查 superview 是否有约束引用了该 view 的高度相关属性
        // （top+bottom、height、centerY+height 等组合都可能控制高度）
        if let superview = view.superview {
            let heightAttributes: Set<NSLayoutConstraint.Attribute> = [
                .height, .top, .bottom, .centerY
            ]
            for constraint in superview.constraints {
                let involvesView = (constraint.firstItem as? UIView === view)
                    || (constraint.secondItem as? UIView === view)
                if involvesView {
                    if heightAttributes.contains(constraint.firstAttribute)
                        || heightAttributes.contains(constraint.secondAttribute) {
                        return true
                    }
                }
            }
        }

        return false
    }

    // MARK: - Collapse Animation (Height Constraint)

    /// 测量目标 view 子内容的实际高度。
    private func measureContentHeight() -> CGFloat {
        let view = targetView
        if isUsingAutoLayout {
            // Auto Layout: use systemLayoutSizeFitting
            let fittingSize = CGSize(width: view.bounds.width, height: 0)
            let size = view.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            // systemLayoutSizeFitting 可能返回 0（无内在约束），回退到 bounds
            return size.height > 0 ? size.height : view.bounds.height
        } else {
            // 纯 Frame-based layout: use sizeToFit
            view.sizeToFit()
            return view.bounds.height
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

    /// 查找已有的高度约束，或创建一个动态高度约束。
    ///
    /// 查找范围包括 view 自身的 constraints 和 superview 的 constraints，
    /// 以兼容 SnapKit 等库将约束安装在 superview 上的情况。
    private func findOrCreateHeightConstraint() -> NSLayoutConstraint {
        // 1. 查找 view 自身 constraints 中的高度约束（NSLayoutConstraint 或手动添加的）
        for constraint in targetView.constraints {
            if constraint.firstAttribute == .height
                && constraint.secondItem == nil
                && constraint.firstItem === targetView
                && constraint.isActive {
                return constraint
            }
        }

        // 2. 查找 superview constraints 中引用该 view 高度的约束
        //    SnapKit 的 height 约束可能安装在 superview 上
        if let superview = targetView.superview {
            for constraint in superview.constraints {
                if constraint.firstAttribute == .height
                    && constraint.firstItem === targetView
                    && constraint.secondItem == nil
                    && constraint.isActive {
                    return constraint
                }
            }
        }

        // 3. 没有找到已有约束，动态创建一个
        //    确保 translatesAutoresizingMaskIntoConstraints 为 false 以避免冲突
        if targetView.translatesAutoresizingMaskIntoConstraints {
            targetView.translatesAutoresizingMaskIntoConstraints = false
        }
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
        if isUsingAutoLayout {
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = height
            targetView.superview?.layoutIfNeeded()
        } else {
            // 纯 Frame-based layout: directly set frame height
            var frame = targetView.frame
            frame.size.height = height
            targetView.frame = frame
        }
    }

    /// 启动 collapse 动画。
    private func startCollapseAnimation(
        startHeight: CGFloat,
        endHeight: CGFloat,
        entering: Bool,
        duration: TimeInterval,
        delay: TimeInterval,
        bezier: CubicBezierCurve,
        onEnd: (() -> Void)?
    ) {
        let view = targetView
        view.clipsToBounds = true

        // 零时长：直接落到终态
        guard duration > 0 else {
            applyHeightConstraint(height: endHeight)
            if entering, isUsingAutoLayout, let dynamicConstraint = dynamicHeightConstraint {
                view.removeConstraint(dynamicConstraint)
                dynamicHeightConstraint = nil
            } else if entering {
                view.sizeToFit()
            }
            onEnd?()
            return
        }

        if isUsingAutoLayout {
            // Auto Layout: animate height constraint
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = startHeight
            view.superview?.layoutIfNeeded()

            let animator = UIViewPropertyAnimator(
                duration: duration,
                controlPoint1: bezier.c1,
                controlPoint2: bezier.c2,
                animations: {
                    constraint.constant = endHeight
                    view.superview?.layoutIfNeeded()
                }
            )
            animator.addCompletion { [weak self] _ in
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
            animator.startAnimation(afterDelay: delay)
        } else {
            // 纯 Frame-based: animate frame height
            var frame = view.frame
            frame.size.height = startHeight
            view.frame = frame

            let animator = UIViewPropertyAnimator(
                duration: duration,
                controlPoint1: bezier.c1,
                controlPoint2: bezier.c2,
                animations: {
                    var frame = view.frame
                    frame.size.height = endHeight
                    view.frame = frame
                }
            )
            animator.addCompletion { _ in
                if entering {
                    // Expand complete: restore natural size
                    view.sizeToFit()
                }
                onEnd?()
            }
            animator.startAnimation(afterDelay: delay)
        }
    }

    // MARK: - Private

    private func cancelInternal() {
        callbackInvoked = true
        targetView.layer.removeAllAnimations()
        stopFlipDisplayLink()
        // Clean up blur overlay
        blurOverlay?.removeFromSuperview()
        blurOverlay = nil
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
}
