import UIKit
import QuartzCore

// ============================================================================
// 本文件把真实动效库 FadeAnimation 的引擎整体内联进 Demo target，
// 使 Demo 播放的动效与发布库 100% 一致（精确 cubic-bezier / UIViewPropertyAnimator /
// CADisplayLink 翻转 / collapse 高度约束等）。
// MotionEffect / EffectPresets / 枚举定义在 MotionEffect.swift，本文件不重复定义。
// 底部 DemoAnimator 为薄封装，保持画廊 VC 的调用方式不变。
// ============================================================================

// MARK: - 设计令牌（PresetSpeed.swift）

enum TimingScale: String {
    case t1, t2, t3, t4, t5
    var durationMs: Int {
        switch self {
        case .t1: return 100
        case .t2: return 150
        case .t3: return 300
        case .t4: return 500
        case .t5: return 700
        }
    }
}

enum PresetSpeed: String {
    case fast, normal, slow
    var durationMs: Int {
        switch self {
        case .fast: return TimingScale.t2.durationMs
        case .normal: return TimingScale.t3.durationMs
        case .slow: return TimingScale.t4.durationMs
        }
    }
}

enum MotionIntent: String {
    case enter, exit, focus, feedback, delight
    var timing: TimingScale {
        switch self {
        case .enter: return .t3
        case .exit: return .t2
        case .focus: return .t2
        case .feedback: return .t1
        case .delight: return .t4
        }
    }
    var curve: UIView.AnimationCurve {
        switch self {
        case .enter: return .easeOut
        case .exit: return .easeIn
        case .focus: return .easeInOut
        case .feedback: return .easeInOut
        case .delight: return .easeOut
        }
    }
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

enum Defaults {
    static let duration: Int = TimingScale.t3.durationMs
    static let delay: Int = 0
    static let curve: UIView.AnimationCurve = .easeInOut
    static let preset: PresetSpeed = .normal
}

// MARK: - 配置与缓动（FadeOptions.swift）

struct FadeOptions {
    var fadeIn: Bool = true
    var duration: Int? = nil
    var delay: Int? = nil
    var curve: UIView.AnimationCurve? = nil
    var timingFunction: CAMediaTimingFunction? = nil
    var preset: PresetSpeed? = nil
    var timing: TimingScale? = nil
    var intent: MotionIntent? = nil
    var onAnimationEnd: (() -> Void)? = nil

    init(
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

struct FadeConfig {
    let duration: TimeInterval
    let delay: TimeInterval
    let curve: UIView.AnimationCurve
    let timingFunction: CAMediaTimingFunction?
    let reducedMotion: Bool
}

enum EasingCurves {
    static let productive = CAMediaTimingFunction(controlPoints: 0.2, 0, 0.38, 0.9)
    static let expressive = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1)
    static let enter = CAMediaTimingFunction(controlPoints: 0, 0, 0.3, 1)
    static let exit = CAMediaTimingFunction(controlPoints: 0.4, 0, 1, 1)
    static let linear = CAMediaTimingFunction(name: .linear)
    static let ease = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
    static let bounce = CAMediaTimingFunction(controlPoints: 0.34, 1.56, 0.64, 1)
}

// MARK: - 三次贝塞尔求值器（CubicBezier.swift）

struct CubicBezierCurve {
    let c1: CGPoint
    let c2: CGPoint

    init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        self.c1 = CGPoint(x: x1, y: y1)
        self.c2 = CGPoint(x: x2, y: y2)
    }

    init(timingFunction: CAMediaTimingFunction) {
        var p1 = [Float](repeating: 0, count: 2)
        var p2 = [Float](repeating: 0, count: 2)
        timingFunction.getControlPoint(at: 1, values: &p1)
        timingFunction.getControlPoint(at: 2, values: &p2)
        self.c1 = CGPoint(x: CGFloat(p1[0]), y: CGFloat(p1[1]))
        self.c2 = CGPoint(x: CGFloat(p2[0]), y: CGFloat(p2[1]))
    }

    var timingFunction: CAMediaTimingFunction {
        CAMediaTimingFunction(
            controlPoints: Float(c1.x), Float(c1.y), Float(c2.x), Float(c2.y)
        )
    }

    func value(at t: CGFloat) -> CGFloat {
        let x = min(max(t, 0), 1)
        let u = solveForU(x)
        return sampleY(u)
    }

    private var cx: CGFloat { 3 * c1.x }
    private var bx: CGFloat { 3 * (c2.x - c1.x) - cx }
    private var ax: CGFloat { 1 - cx - bx }
    private var cy: CGFloat { 3 * c1.y }
    private var by: CGFloat { 3 * (c2.y - c1.y) - cy }
    private var ay: CGFloat { 1 - cy - by }

    private func sampleX(_ u: CGFloat) -> CGFloat { ((ax * u + bx) * u + cx) * u }
    private func sampleY(_ u: CGFloat) -> CGFloat { ((ay * u + by) * u + cy) * u }
    private func sampleDerivativeX(_ u: CGFloat) -> CGFloat { (3 * ax * u + 2 * bx) * u + cx }

    private func solveForU(_ x: CGFloat) -> CGFloat {
        var u = x
        for _ in 0..<8 {
            let dx = sampleX(u) - x
            if abs(dx) < 1e-6 { return u }
            let d = sampleDerivativeX(u)
            if abs(d) < 1e-6 { break }
            u -= dx / d
        }
        var lo: CGFloat = 0
        var hi: CGFloat = 1
        u = x
        while lo < hi {
            let xU = sampleX(u)
            if abs(xU - x) < 1e-6 { return u }
            if x > xU { lo = u } else { hi = u }
            u = (lo + hi) / 2
            if hi - lo < 1e-6 { break }
        }
        return u
    }
}

extension CubicBezierCurve {
    init(animationCurve: UIView.AnimationCurve) {
        switch animationCurve {
        case .easeInOut: self.init(0.42, 0, 0.58, 1)
        case .easeIn:    self.init(0.42, 0, 1, 1)
        case .easeOut:   self.init(0, 0, 0.58, 1)
        case .linear:    self.init(0, 0, 1, 1)
        @unknown default: self.init(0.42, 0, 0.58, 1)
        }
    }
}

// MARK: - 无障碍动效级别（ReducedMotionHelper.swift）

enum ReducedMotionHelper {
    enum MotionLevel { case full, reduced, none }
    static let reducedMaxDurationMs: Int = TimingScale.t1.durationMs
    private static var globalMotionLevel: MotionLevel?
    static func setMotionLevel(_ level: MotionLevel?) { globalMotionLevel = level }
    static func getMotionLevel() -> MotionLevel? { globalMotionLevel }
    static func resolveMotionLevel() -> MotionLevel {
        if let level = globalMotionLevel { return level }
        return UIAccessibility.isReduceMotionEnabled ? .none : .full
    }
    static func isReducedMotionEnabled() -> Bool { resolveMotionLevel() != .full }
}

// MARK: - 配置解析（ResolveConfig.swift）

func resolveConfig(options: FadeOptions) -> FadeConfig {
    let motionLevel = ReducedMotionHelper.resolveMotionLevel()
    return resolveConfigInternal(options: options, motionLevel: motionLevel)
}

func resolveConfigInternal(options: FadeOptions, motionLevel: ReducedMotionHelper.MotionLevel) -> FadeConfig {
    let resolvedDurationMs: Int
    if let duration = options.duration {
        resolvedDurationMs = duration >= 0 ? duration : Defaults.duration
    } else if let timing = options.timing {
        resolvedDurationMs = timing.durationMs
    } else if let preset = options.preset {
        resolvedDurationMs = preset.durationMs
    } else if let intent = options.intent {
        resolvedDurationMs = intent.timing.durationMs
    } else {
        resolvedDurationMs = Defaults.duration
    }

    let resolvedDelayMs: Int
    if let delay = options.delay {
        resolvedDelayMs = delay >= 0 ? delay : Defaults.delay
    } else {
        resolvedDelayMs = Defaults.delay
    }

    let resolvedCurve = options.curve
        ?? options.intent?.curve
        ?? Defaults.curve

    let resolvedTimingFunction = options.timingFunction
        ?? options.intent?.timingFunction
        ?? options.curve.map { CubicBezierCurve(animationCurve: $0).timingFunction }
        ?? EasingCurves.ease

    switch motionLevel {
    case .none:
        return FadeConfig(duration: 0, delay: 0, curve: resolvedCurve,
                          timingFunction: resolvedTimingFunction, reducedMotion: true)
    case .reduced:
        let clampedDuration = min(resolvedDurationMs, ReducedMotionHelper.reducedMaxDurationMs)
        return FadeConfig(duration: TimeInterval(clampedDuration) / 1000.0, delay: 0,
                          curve: resolvedCurve, timingFunction: resolvedTimingFunction, reducedMotion: true)
    case .full:
        return FadeConfig(duration: TimeInterval(resolvedDurationMs) / 1000.0,
                          delay: TimeInterval(resolvedDelayMs) / 1000.0,
                          curve: resolvedCurve, timingFunction: resolvedTimingFunction, reducedMotion: false)
    }
}

// MARK: - 通用动效控制器（MotionAnimator.swift，与发布库一致）

class MotionAnimator {

    private let targetView: UIView
    private let options: FadeOptions
    private var callbackInvoked: Bool = false
    private var safetyTimer: DispatchWorkItem?
    private var dynamicHeightConstraint: NSLayoutConstraint?
    private var flipDisplayLink: CADisplayLink?
    private var flipStartTime: CFTimeInterval = 0
    private var flipDuration: CFTimeInterval = 0
    private var flipFromAngle: CGFloat = 0
    private var flipToAngle: CGFloat = 0
    private var flipAxis: FlipAxis = .y
    private var flipPerspective: CGFloat = 800
    private var flipBackfaceHidden: Bool = true
    private var flipBezier: CubicBezierCurve = CubicBezierCurve(0.42, 0, 0.58, 1)
    private var blurEffectView: UIVisualEffectView?

    init(targetView: UIView, options: FadeOptions = FadeOptions()) {
        self.targetView = targetView
        self.options = options
    }

    func start(
        entering: Bool = true,
        effects: [MotionEffect] = EffectPresets.fadeIn,
        onEnd: (() -> Void)? = nil
    ) {
        cancelInternal()
        callbackInvoked = false

        let view = targetView
        let config = resolveConfig(options: options)

        let hasFlip = effects.contains { if case .flip = $0 { return true }; return false }
        let hasRotate = effects.contains { if case .rotate = $0 { return true }; return false }
        let resolvedEffects: [MotionEffect]
        if hasFlip && hasRotate {
            resolvedEffects = effects.filter { if case .rotate = $0 { return false }; return true }
        } else {
            resolvedEffects = effects
        }

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
                } else {
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

        view.transform = initialTransform

        for effect in resolvedEffects {
            switch effect {
            case .fade(let from, _):
                view.alpha = from ?? (entering ? 0 : 1)
            case .blur(let from, _):
                let blurFrom = from ?? (entering ? 8 : 0)
                applyBlur(radius: blurFrom)
            case .flip(let axis, let from, let to, let perspective, let backfaceVisibility):
                let startAngle = entering ? from : to
                applyFlipTransform(angle: startAngle, axis: axis, perspective: perspective)
                view.layer.isDoubleSided = (backfaceVisibility != "hidden")
            case .collapse(let collapsedHeight):
                let collapsedPx = resolveCollapsedHeight(collapsedHeight)
                let startHeight = entering ? collapsedPx : measureContentHeight()
                view.clipsToBounds = true
                applyHeightConstraint(height: startHeight)
            default:
                break
            }
        }

        let bezier = CubicBezierCurve(
            timingFunction: config.timingFunction
                ?? CubicBezierCurve(animationCurve: config.curve).timingFunction
        )

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
                startAngle: startAngle, endAngle: endAngle, axis: axis,
                perspective: perspective, backfaceHidden: backfaceVisibility == "hidden",
                duration: config.duration, delay: config.delay, bezier: bezier
            )
        }

        let collapseEffect = resolvedEffects.compactMap { effect -> CollapseHeight? in
            if case .collapse(let ch) = effect { return ch }
            return nil
        }.first

        if let collapsedHeight = collapseEffect {
            let contentHeight = measureContentHeight()
            let collapsedPx = resolveCollapsedHeight(collapsedHeight)
            let startHeight = entering ? collapsedPx : contentHeight
            let endHeight = entering ? contentHeight : collapsedPx
            startCollapseAnimation(startHeight: startHeight, endHeight: endHeight, entering: entering,
                                   duration: config.duration, delay: config.delay, bezier: bezier, onEnd: nil)
        }

        let mainAnimations = {
            for effect in resolvedEffects {
                switch effect {
                case .fade(_, let to):
                    view.alpha = to ?? (entering ? 1 : 0)
                case .blur(_, let to):
                    let blurTo = to ?? (entering ? 0 : 8)
                    self.applyBlur(radius: blurTo)
                case .scale, .slide, .rotate, .flip, .collapse:
                    break
                }
            }
            view.transform = targetTransform
        }

        if config.duration <= 0 {
            mainAnimations()
            invokeOnEnd()
        } else {
            let propertyAnimator = UIViewPropertyAnimator(
                duration: config.duration, controlPoint1: bezier.c1, controlPoint2: bezier.c2,
                animations: mainAnimations
            )
            propertyAnimator.addCompletion { _ in invokeOnEnd() }
            propertyAnimator.startAnimation(afterDelay: config.delay)
        }

        if combinedOnEnd != nil {
            let workItem = DispatchWorkItem { [weak self] in
                guard self != nil else { return }
                invokeOnEnd()
            }
            safetyTimer = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + config.duration + config.delay + 0.05, execute: workItem)
        }
    }

    func cancel() { cancelInternal() }
    deinit { cancelInternal() }

    private func applyBlur(radius: CGFloat) {
        let view = targetView
        if radius <= 0 {
            blurEffectView?.removeFromSuperview()
            blurEffectView = nil
            return
        }
        if blurEffectView == nil {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            effectView.frame = view.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.isUserInteractionEnabled = false
            view.addSubview(effectView)
            blurEffectView = effectView
        }
        blurEffectView?.alpha = min(radius / 8.0, 1.0)
    }

    private func applyFlipTransform(angle: CGFloat, axis: FlipAxis, perspective: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / perspective
        let radians = angle * .pi / 180
        switch axis {
        case .x: transform = CATransform3DRotate(transform, radians, 1, 0, 0)
        case .y: transform = CATransform3DRotate(transform, radians, 0, 1, 0)
        }
        targetView.layer.transform = transform
    }

    private func startFlipAnimation(startAngle: CGFloat, endAngle: CGFloat, axis: FlipAxis,
                                    perspective: CGFloat, backfaceHidden: Bool,
                                    duration: TimeInterval, delay: TimeInterval, bezier: CubicBezierCurve) {
        stopFlipDisplayLink()
        flipFromAngle = startAngle
        flipToAngle = endAngle
        flipAxis = axis
        flipPerspective = perspective
        flipBackfaceHidden = backfaceHidden
        flipDuration = duration
        flipBezier = bezier
        flipStartTime = 0
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
        if #available(iOS 15.0, *) {
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        }
        displayLink.add(to: .main, forMode: .common)
        flipDisplayLink = displayLink
    }

    @objc private func flipDisplayLinkTick(_ displayLink: CADisplayLink) {
        if flipStartTime == 0 { flipStartTime = displayLink.timestamp }
        let elapsed = displayLink.timestamp - flipStartTime
        var progress = flipDuration > 0 ? CGFloat(elapsed / flipDuration) : 1.0
        progress = min(max(progress, 0), 1)
        let easedProgress = flipBezier.value(at: progress)
        let currentAngle = flipFromAngle + (flipToAngle - flipFromAngle) * easedProgress
        applyFlipTransform(angle: currentAngle, axis: flipAxis, perspective: flipPerspective)
        if flipBackfaceHidden {
            let normalizedAngle = ((currentAngle.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
            targetView.isHidden = (normalizedAngle > 90 && normalizedAngle < 270)
        }
        if progress >= 1.0 {
            stopFlipDisplayLink()
            applyFlipTransform(angle: flipToAngle, axis: flipAxis, perspective: flipPerspective)
            if flipBackfaceHidden {
                let normalizedAngle = ((flipToAngle.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
                targetView.isHidden = (normalizedAngle > 90 && normalizedAngle < 270)
            }
        }
    }

    private func stopFlipDisplayLink() {
        flipDisplayLink?.invalidate()
        flipDisplayLink = nil
    }

    private var isUsingAutoLayout: Bool {
        let view = targetView
        if !view.translatesAutoresizingMaskIntoConstraints { return true }
        if let superview = view.superview {
            let heightAttributes: Set<NSLayoutConstraint.Attribute> = [.height, .top, .bottom, .centerY]
            for constraint in superview.constraints {
                let involvesView = (constraint.firstItem as? UIView === view) || (constraint.secondItem as? UIView === view)
                if involvesView {
                    if heightAttributes.contains(constraint.firstAttribute) || heightAttributes.contains(constraint.secondAttribute) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func measureContentHeight() -> CGFloat {
        let view = targetView
        if isUsingAutoLayout {
            let fittingSize = CGSize(width: view.bounds.width, height: 0)
            let size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return size.height > 0 ? size.height : view.bounds.height
        } else {
            view.sizeToFit()
            return view.bounds.height
        }
    }

    private func resolveCollapsedHeight(_ collapsedHeight: CollapseHeight) -> CGFloat {
        switch collapsedHeight {
        case .fixed(let value): return value
        case .auto: return targetView.bounds.height
        }
    }

    private func findOrCreateHeightConstraint() -> NSLayoutConstraint {
        for constraint in targetView.constraints {
            if constraint.firstAttribute == .height && constraint.secondItem == nil
                && constraint.firstItem === targetView && constraint.isActive {
                return constraint
            }
        }
        if let superview = targetView.superview {
            for constraint in superview.constraints {
                if constraint.firstAttribute == .height && constraint.firstItem === targetView
                    && constraint.secondItem == nil && constraint.isActive {
                    return constraint
                }
            }
        }
        if targetView.translatesAutoresizingMaskIntoConstraints {
            targetView.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraint = NSLayoutConstraint(item: targetView as Any, attribute: .height, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: targetView.bounds.height)
        constraint.priority = UILayoutPriority(999)
        targetView.addConstraint(constraint)
        dynamicHeightConstraint = constraint
        return constraint
    }

    private func applyHeightConstraint(height: CGFloat) {
        if isUsingAutoLayout {
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = height
            targetView.superview?.layoutIfNeeded()
        } else {
            var frame = targetView.frame
            frame.size.height = height
            targetView.frame = frame
        }
    }

    private func startCollapseAnimation(startHeight: CGFloat, endHeight: CGFloat, entering: Bool,
                                        duration: TimeInterval, delay: TimeInterval,
                                        bezier: CubicBezierCurve, onEnd: (() -> Void)?) {
        let view = targetView
        view.clipsToBounds = true
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
            let constraint = findOrCreateHeightConstraint()
            constraint.constant = startHeight
            view.superview?.layoutIfNeeded()
            let animator = UIViewPropertyAnimator(duration: duration, controlPoint1: bezier.c1, controlPoint2: bezier.c2) {
                constraint.constant = endHeight
                view.superview?.layoutIfNeeded()
            }
            animator.addCompletion { [weak self] _ in
                if entering, let dynamicConstraint = self?.dynamicHeightConstraint {
                    view.removeConstraint(dynamicConstraint)
                    self?.dynamicHeightConstraint = nil
                }
                onEnd?()
            }
            animator.startAnimation(afterDelay: delay)
        } else {
            var frame = view.frame
            frame.size.height = startHeight
            view.frame = frame
            let animator = UIViewPropertyAnimator(duration: duration, controlPoint1: bezier.c1, controlPoint2: bezier.c2) {
                var frame = view.frame
                frame.size.height = endHeight
                view.frame = frame
            }
            animator.addCompletion { _ in
                if entering { view.sizeToFit() }
                onEnd?()
            }
            animator.startAnimation(afterDelay: delay)
        }
    }

    private func cancelInternal() {
        callbackInvoked = true
        targetView.layer.removeAllAnimations()
        stopFlipDisplayLink()
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
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

// MARK: - 薄封装：保持画廊 VC 调用方式不变，内部走真实 MotionAnimator

class DemoAnimator {
    private let view: UIView
    private var motion: MotionAnimator?

    init(view: UIView) { self.view = view }

    /// 播放效果组合（内部委托给真实库的 MotionAnimator）
    func play(entering: Bool, effects: [MotionEffect], duration: TimeInterval = 0.6,
              timingFunction: CAMediaTimingFunction? = nil, onEnd: (() -> Void)? = nil) {
        let opts = FadeOptions(duration: Int(duration * 1000), timingFunction: timingFunction)
        let m = MotionAnimator(targetView: view, options: opts)
        self.motion = m  // 强引用，避免 flip 的 CADisplayLink 因 animator 释放而中断
        m.start(entering: entering, effects: effects, onEnd: onEnd)
    }
}
