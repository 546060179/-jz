import UIKit

/// TypingDots 配置
public struct TypingDotsConfig {
    /// 圆点数量，默认 3
    public var count: Int = 3
    /// 圆点直径（pt），默认 8
    public var dotSize: CGFloat = 8
    /// 圆点间距（pt），默认 6
    public var gap: CGFloat = 6
    /// 暗态颜色，默认 Neutral/T-b31 (#4C4B50)
    public var dimColor: UIColor = UIColor(red: 0x4C/255, green: 0x4B/255, blue: 0x50/255, alpha: 1)
    /// 亮态颜色（脉冲峰值），默认 Neutral/T-b53 (#828386)
    public var brightColor: UIColor = UIColor(red: 0x82/255, green: 0x83/255, blue: 0x86/255, alpha: 1)
    /// 容器背景色，默认 Neutral/T-b16 (#23252A)
    public var backgroundColor: UIColor = UIColor(red: 0x23/255, green: 0x25/255, blue: 0x2A/255, alpha: 1)
    /// 单个圆点动画周期（ms），默认 TimingScale.t4 (500)
    public var cycleDuration: Int = TimingScale.t4.durationMs
    /// 圆点间交错延迟（ms），默认 150
    public var staggerInterval: Int = 150
    /// 容器圆角
    public var cornerRadii: UIRectCorner = [.topRight, .bottomLeft, .bottomRight]
    /// 容器圆角半径，默认 12
    public var cornerRadius: CGFloat = 12
    /// 容器内边距，默认 12
    public var padding: CGFloat = 12
    /// 容器高度，默认 44
    public var height: CGFloat = 44

    public init(
        count: Int = 3,
        dotSize: CGFloat = 8,
        gap: CGFloat = 6,
        dimColor: UIColor = UIColor(red: 0x4C/255, green: 0x4B/255, blue: 0x50/255, alpha: 1),
        brightColor: UIColor = UIColor(red: 0x82/255, green: 0x83/255, blue: 0x86/255, alpha: 1),
        backgroundColor: UIColor = UIColor(red: 0x23/255, green: 0x25/255, blue: 0x2A/255, alpha: 1),
        cycleDuration: Int = TimingScale.t4.durationMs,
        staggerInterval: Int = 150,
        cornerRadii: UIRectCorner = [.topRight, .bottomLeft, .bottomRight],
        cornerRadius: CGFloat = 12,
        padding: CGFloat = 12,
        height: CGFloat = 44
    ) {
        self.count = count
        self.dotSize = dotSize
        self.gap = gap
        self.dimColor = dimColor
        self.brightColor = brightColor
        self.backgroundColor = backgroundColor
        self.cycleDuration = cycleDuration
        self.staggerInterval = staggerInterval
        self.cornerRadii = cornerRadii
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.height = height
    }
}

/// TypingDotsView — 聊天"正在输入"跑马灯动效视图
///
/// 基于 Figma ShortMax 对话框加载效果：多个圆点以交错节奏
/// 依次脉冲（opacity + scale），形成跑马灯式的波浪动画。
///
/// 使用库内 design tokens：
/// - TimingScale.t4 作为默认周期
/// - stagger 延迟计算交错时间
///
/// ```swift
/// let dots = TypingDotsView()
/// view.addSubview(dots)
/// dots.startAnimating()
/// ```
public class TypingDotsView: UIView {

    private let config: TypingDotsConfig
    private var dotLayers: [CAShapeLayer] = []
    private var isAnimating = false

    // MARK: - Init

    public init(config: TypingDotsConfig = TypingDotsConfig()) {
        self.config = config
        super.init(frame: .zero)
        setupView()
    }

    public required init?(coder: NSCoder) {
        self.config = TypingDotsConfig()
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = config.backgroundColor
        accessibilityLabel = "Loading"
        accessibilityTraits = .updatesFrequently
        isAccessibilityElement = true

        // 创建圆点
        for _ in 0..<config.count {
            let dot = CAShapeLayer()
            let rect = CGRect(x: 0, y: 0, width: config.dotSize, height: config.dotSize)
            dot.path = UIBezierPath(ovalIn: rect).cgPath
            dot.fillColor = config.dimColor.cgColor
            dot.opacity = 0.4
            layer.addSublayer(dot)
            dotLayers.append(dot)
        }
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        let dotsWidth = CGFloat(config.count) * config.dotSize + CGFloat(config.count - 1) * config.gap
        let totalWidth = dotsWidth + config.padding * 2
        return CGSize(width: totalWidth, height: config.height)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 应用圆角蒙版
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: config.cornerRadii,
            cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask

        // 布局圆点：水平居中，垂直居中
        let dotsWidth = CGFloat(config.count) * config.dotSize + CGFloat(config.count - 1) * config.gap
        let startX = (bounds.width - dotsWidth) / 2
        let centerY = bounds.height / 2

        for (i, dot) in dotLayers.enumerated() {
            let x = startX + CGFloat(i) * (config.dotSize + config.gap)
            let y = centerY - config.dotSize / 2
            dot.frame = CGRect(x: x, y: y, width: config.dotSize, height: config.dotSize)
        }
    }

    // MARK: - Animation

    /// 启动跑马灯脉冲动画
    public func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true

        let totalDuration = CFTimeInterval(config.cycleDuration + (config.count - 1) * config.staggerInterval) / 1000.0
        let delays = staggerDelays()

        for (i, dot) in dotLayers.enumerated() {
            let delaySeconds = CFTimeInterval(delays[i]) / 1000.0
            addPulseAnimation(to: dot, totalDuration: totalDuration, delay: delaySeconds)
        }
    }

    /// 停止动画
    public func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        for dot in dotLayers {
            dot.removeAllAnimations()
        }
    }

    // MARK: - Private

    /// 计算交错延迟（复用 stagger 逻辑）
    private func staggerDelays() -> [Int] {
        var delays: [Int] = []
        for i in 0..<config.count {
            delays.append(i * config.staggerInterval)
        }
        return delays
    }

    /// 为单个圆点添加脉冲动画组
    private func addPulseAnimation(to dot: CAShapeLayer, totalDuration: CFTimeInterval, delay: CFTimeInterval) {
        // Opacity 动画: 0.4 → 1.0 → 0.4
        let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnim.values = [0.4, 1.0, 0.4]
        opacityAnim.keyTimes = [0, 0.5, 1.0]

        // Scale 动画: 1.0 → 1.15 → 1.0
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnim.values = [1.0, 1.15, 1.0]
        scaleAnim.keyTimes = [0, 0.5, 1.0]

        // 颜色动画: dim → bright → dim
        let colorAnim = CAKeyframeAnimation(keyPath: "fillColor")
        colorAnim.values = [
            config.dimColor.cgColor,
            config.brightColor.cgColor,
            config.dimColor.cgColor
        ]
        colorAnim.keyTimes = [0, 0.5, 1.0]

        // 动画组
        let group = CAAnimationGroup()
        group.animations = [opacityAnim, scaleAnim, colorAnim]
        group.duration = totalDuration
        group.beginTime = CACurrentMediaTime() + delay
        group.repeatCount = .infinity
        // expressive 缓动近似
        group.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1.0)

        dot.add(group, forKey: "typingPulse")
    }

    // MARK: - Lifecycle

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && isAnimating {
            // 从后台恢复时 CAAnimation 会被系统移除，需要重新添加
            isAnimating = false
            startAnimating()
        }
    }
}
