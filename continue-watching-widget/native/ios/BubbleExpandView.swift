import UIKit

// MARK: - Delegate
protocol BubbleExpandDelegate: AnyObject {
    func bubbleExpandDidFinish()
    func bubbleExpandDidExpand()
}
extension BubbleExpandDelegate {
    func bubbleExpandDidFinish() {}
    func bubbleExpandDidExpand() {}
}

// MARK: - BubbleExpandView
/// 气泡展开动效 — 拖进项目即用，兼容 SnapKit / Auto Layout
///
/// 使用方式：
/// ```swift
/// let bubble = BubbleExpandView()
/// bubble.text = "Continue watching"   // 直接设文字
/// // bubble.isRTL = true              // 阿拉伯语设 true
/// view.addSubview(bubble)
/// bubble.snp.makeConstraints { make in
///     make.right.equalTo(icon.snp.left)
///     make.centerY.equalTo(icon)
///     make.width.equalTo(bubble.totalWidth)
///     make.height.equalTo(bubble.totalHeight)
/// }
/// bubble.play()
/// ```
class BubbleExpandView: UIView {

    // MARK: - Public API

    enum Phase { case idle, expanding, done }

    /// 气泡文字，设置后自动计算高度
    var text: String = "" {
        didSet {
            textLabel.text = text
            textLabel.textAlignment = isRTL ? .right : .left
            recalcHeight()
        }
    }

    /// 阿拉伯语等 RTL 语言设为 true
    var isRTL: Bool = false {
        didSet {
            textLabel.textAlignment = isRTL ? .right : .left
            setNeedsLayout()
        }
    }

    /// 展开动画时长（默认 650ms）
    var expandDuration: TimeInterval = 0.65

    /// 动画回调
    weak var delegate: BubbleExpandDelegate?

    /// 当前动画阶段
    private(set) var phase: Phase = .idle

    /// 总宽度 (body + arrow)，用于约束
    var totalWidth: CGFloat { bodyWidth + arrowWidth }

    /// 总高度（文字撑开，最小 40），用于约束
    private(set) var totalHeight: CGFloat = 40

    // MARK: - Figma Dimensions
    private let bodyWidth: CGFloat = 120
    private let arrowWidth: CGFloat = 9
    private let arrowHeight: CGFloat = 40
    private let bubbleRadius: CGFloat = 8
    private let padTop: CGFloat = 6
    private let padBottom: CGFloat = 6
    private let padLeft: CGFloat = 8
    private let padRight: CGFloat = 8

    // MARK: - Subviews
    private let gradientLayer = CAGradientLayer()
    private let arrowImageView = UIImageView()
    private let textLabel = UILabel()
    /// 渐变遮罩：展开过程中盖住文字，70% 后渐隐露出文字
    private let textMaskView = UIView()
    private let maskGradientLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var phaseStartTime: CFTimeInterval = 0

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = false
        isUserInteractionEnabled = false

        // 渐变背景 (Figma: #FFD1C4 → #FFD75F)
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.82, blue: 0.77, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.84, blue: 0.37, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = bubbleRadius
        layer.addSublayer(gradientLayer)

        // 箭头图片
        // 方式1: 项目中有 pic_arrow_2 图片资源时自动加载
        // 方式2: 没有图片资源时用内嵌 base64 兜底
        if let img = UIImage(named: "pic_arrow_2") {
            arrowImageView.image = img
        } else if let data = Data(base64Encoded: Self.arrowBase64),
                  let img = UIImage(data: data, scale: 3) {
            arrowImageView.image = img
        }
        arrowImageView.contentMode = .scaleAspectFit

        // 文字
        textLabel.font = UIFont(name: "Montserrat-Medium", size: 10)
            ?? .systemFont(ofSize: 10, weight: .medium)
        textLabel.textColor = UIColor(red: 0.384, green: 0.141, blue: 0.106, alpha: 1) // #62241B
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        addSubview(textLabel)

        // 文字遮罩（和背景同色渐变，盖住文字）
        maskGradientLayer.colors = gradientLayer.colors
        maskGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        maskGradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        maskGradientLayer.cornerRadius = 4
        textMaskView.layer.addSublayer(maskGradientLayer)
        addSubview(textMaskView)

        // 箭头最后 addSubview，确保在遮罩上层
        addSubview(arrowImageView)

        // 初始隐藏整个气泡，play() 时才显示
        alpha = 0
    }

    private func recalcHeight() {
        let maxW = bodyWidth - padLeft - padRight
        let size = textLabel.sizeThatFits(CGSize(width: maxW, height: .greatestFiniteMagnitude))
        totalHeight = max(size.height + padTop + padBottom, arrowHeight)
        invalidateIntrinsicContentSize()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        if isRTL {
            // RTL: [arrow][body] — 渐变方向翻转（右→左）
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0, y: 0.5)
            arrowImageView.frame = CGRect(x: 0, y: (h - arrowHeight) / 2, width: arrowWidth, height: arrowHeight)
            arrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            gradientLayer.frame = CGRect(x: arrowWidth - 1, y: 0, width: bodyWidth, height: h)
            let tx = arrowWidth - 1 + padLeft
            textLabel.frame    = CGRect(x: tx, y: padTop, width: bodyWidth - padLeft - padRight, height: h - padTop - padBottom)
            textMaskView.frame = CGRect(x: tx - 2, y: padTop - 2, width: bodyWidth - padLeft - padRight + 4, height: h - padTop - padBottom + 4)
            // 遮罩渐变也翻转
            maskGradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            maskGradientLayer.endPoint   = CGPoint(x: 0, y: 0.5)
        } else {
            // LTR: [body][arrow] — 渐变方向正常（左→右）
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
            gradientLayer.frame = CGRect(x: 0, y: 0, width: bodyWidth, height: h)
            arrowImageView.frame = CGRect(x: bodyWidth - 1, y: (h - arrowHeight) / 2, width: arrowWidth, height: arrowHeight)
            arrowImageView.transform = .identity
            textLabel.frame    = CGRect(x: padLeft, y: padTop, width: bodyWidth - padLeft - padRight, height: h - padTop - padBottom)
            textMaskView.frame = CGRect(x: padLeft - 2, y: padTop - 2, width: bodyWidth - padLeft - padRight + 4, height: h - padTop - padBottom + 4)
            maskGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            maskGradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        maskGradientLayer.frame = textMaskView.bounds
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: totalWidth, height: totalHeight)
    }

    // MARK: - Animation
    /// 播放展开动画
    func play() {
        guard phase == .idle else { return }
        phase = .expanding
        alpha = 1                 // 显示气泡
        textMaskView.alpha = 1    // 遮罩盖住文字
        textLabel.alpha = 0       // 文字先隐藏
        setNeedsLayout()
        layoutIfNeeded()
        guard bounds.width > 0 else {
            // Auto Layout 还没算好，下一帧重试
            phase = .idle
            DispatchQueue.main.async { [weak self] in self?.play() }
            return
        }
        applyScale(0.001)
        phaseStartTime = 0
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    /// 重置到初始状态（可再次 play）
    func reset() {
        displayLink?.invalidate()
        displayLink = nil
        phase = .idle
        alpha = 0
        textMaskView.alpha = 1
        textLabel.alpha = 0
        layer.transform = CATransform3DIdentity
    }

    /// 直接显示（无动画），用于恢复已展开状态
    func showWithoutAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        phase = .done
        alpha = 1
        textMaskView.alpha = 0
        textLabel.alpha = 1
        layer.transform = CATransform3DIdentity
        setNeedsLayout()
    }

    // MARK: - Private
    private func applyScale(_ sx: CGFloat) {
        let w = bounds.width
        var t = CATransform3DIdentity
        if isRTL {
            t = CATransform3DTranslate(t, -w / 2, 0, 0)
            t = CATransform3DScale(t, sx, 1, 1)
            t = CATransform3DTranslate(t, w / 2, 0, 0)
        } else {
            t = CATransform3DTranslate(t, w / 2, 0, 0)
            t = CATransform3DScale(t, sx, 1, 1)
            t = CATransform3DTranslate(t, -w / 2, 0, 0)
        }
        layer.transform = t
    }

    /// Spring bounce ζ=0.5, ω=9.0
    private func spring(_ t: CGFloat) -> CGFloat {
        guard t > 0 else { return 0 }
        guard t < 1 else { return 1 }
        let z: CGFloat = 0.5, w: CGFloat = 9.0
        let wd = w * sqrt(1 - z * z)
        return 1 - exp(-z * w * t) * (cos(wd * t) + (z / sqrt(1 - z * z)) * sin(wd * t))
    }

    @objc private func tick(_ link: CADisplayLink) {
        let now = link.timestamp
        if phaseStartTime == 0 { phaseStartTime = now }
        let p = min(CGFloat(now - phaseStartTime) / CGFloat(expandDuration), 1)

        applyScale(max(0.001, spring(p)))

        // 文字在 70% 时开始淡入
        if p > 0.7 {
            let f = (p - 0.7) / 0.3
            textMaskView.alpha = CGFloat(1 - f)
            textLabel.alpha = f
        }

        if p >= 1 {
            layer.transform = CATransform3DIdentity
            textMaskView.alpha = 0
            textLabel.alpha = 1
            phase = .done
            displayLink?.invalidate()
            displayLink = nil
            delegate?.bubbleExpandDidExpand()
            delegate?.bubbleExpandDidFinish()
        }
    }

    deinit { displayLink?.invalidate() }

    // MARK: - Arrow Image (pic-arrow-2.png @3x 内嵌，27×120px = 9×40pt)
    private static let arrowBase64 = "iVBORw0KGgoAAAANSUhEUgAAABsAAAB4CAYAAAADtImhAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAOdEVYdFNvZnR3YXJlAEZpZ21hnrGWYwAAAahJREFUeAHt281NAkEYxvFnJhaAHezVeJAOpASvggl0IB0gFYAVcNQbJWgVEL1ICZwQ+XqdWYyKurAfs288PL8Ewlfyz8zO7C4AEREREREREdEOeWlVoMRiPleM2aMqlFis1xGUWMBEUOJj51DiYlLVWpE2fp4tLqBgGzOmCQXbGKSmMZX289Vs0UbJvmIG12WPzn57XSl7dHbnXcmjsz/eV/C67KAk9vdH0pbxVQ06Md/bDMqYTpvweeSmcwilGOKNPq4HPX5277eCGxldBjtv2sM/MQMZtyIEkCLmtoMsHkIsmDQxL8Js2UNBaWNuNqXljl+h01n62LbYK7LhM8aw3fA5F0z2mD9+ssi14fPEvKqMGpkXTN4Y4hN2xgVTIOaZjjzXU9++F4y5Db/CMO2GLxrzUl8hQsQQXyFSLJhAsTjYlqdGUynmrKW/b8OHjR24QoSOeW7BvLWgFPN/VM6gFtvgGGoxgwn0Yps+VGKCrjm5n/z11RGCMVN3sLrm9K6f9IuPmHl0j1s311PkspokjWaHjOrBb7OTWDe2LoiIiIiIiIjoX3sHBeGDqyiLoSAAAAAASUVORK5CYII="
}
