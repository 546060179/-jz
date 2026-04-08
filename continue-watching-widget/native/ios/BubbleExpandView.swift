import UIKit

protocol BubbleExpandDelegate: AnyObject {
    func bubbleExpandDidFinish()
    func bubbleExpandDidExpand()
}
extension BubbleExpandDelegate {
    func bubbleExpandDidFinish() {}
    func bubbleExpandDidExpand() {}
}

/// 气泡展开动效 — 和 HTML 预览完全一致，兼容 SnapKit
///
/// Figma 3203-7940:
/// - body: 120px 固定宽, padding 6/8, 8px 圆角, 渐变背景
/// - 箭头: pic_arrow 2, 9x40 图片
/// - 文字: Montserrat 10px/1.4 Medium, #62241B
///
/// ```swift
/// let bubble = BubbleExpandView()
/// bubble.configure(text: NSLocalizedString("bubble_text", comment: ""))
/// view.addSubview(bubble)
/// bubble.snp.makeConstraints { make in
///     make.right.equalTo(welfareIcon.snp.left)
///     make.centerY.equalTo(lottieView)
///     make.width.equalTo(bubble.totalWidth)
///     make.height.equalTo(bubble.totalHeight)
/// }
/// DispatchQueue.main.async { bubble.play() }
/// ```
class BubbleExpandView: UIView {

    enum Phase { case idle, expanding, done }

    var expandDuration: TimeInterval = 0.65
    weak var delegate: BubbleExpandDelegate?
    private(set) var phase: Phase = .idle

    // Figma dimensions
    private let bodyWidth: CGFloat = 120
    private let arrowWidth: CGFloat = 9
    private let arrowHeight: CGFloat = 40
    private let bubbleRadius: CGFloat = 8
    private let padTop: CGFloat = 6
    private let padBottom: CGFloat = 6
    private let padLeft: CGFloat = 8
    private let padRight: CGFloat = 8

    /// 总宽度 (body + arrow)，用于约束
    var totalWidth: CGFloat { bodyWidth + arrowWidth }
    /// 总高度，用于约束（文字撑开，最小 40）
    private(set) var totalHeight: CGFloat = 40

    // Subviews
    private let gradientLayer = CAGradientLayer()
    private let arrowImageView = UIImageView()
    private let textLabel = UILabel()
    private let textMaskView = UIView()
    private let maskGradientLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var phaseStartTime: CFTimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    private func commonSetup() {
        clipsToBounds = false
        isUserInteractionEnabled = false

        // 渐变背景 (Figma: linear-gradient(90deg, #FFD1C4, #FFD75F))
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.82, blue: 0.77, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.84, blue: 0.37, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = bubbleRadius
        layer.addSublayer(gradientLayer)

        // 箭头图片 (Figma: pic_arrow 2, 内嵌 base64)
        if let data = Data(base64Encoded: Self.arrowImageBase64, options: .ignoreUnknownCharacters),
           let img = UIImage(data: data, scale: 2) {
            arrowImageView.image = img
        }
        arrowImageView.contentMode = .scaleToFill
        addSubview(arrowImageView)

        // 文字
        textLabel.font = UIFont(name: "Montserrat-Medium", size: 10) ?? .systemFont(ofSize: 10, weight: .medium)
        textLabel.textColor = UIColor(red: 0.384, green: 0.141, blue: 0.106, alpha: 1)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        addSubview(textLabel)

        // 文字遮罩
        maskGradientLayer.colors = gradientLayer.colors
        maskGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        maskGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        maskGradientLayer.cornerRadius = 4
        textMaskView.layer.addSublayer(maskGradientLayer)
        addSubview(textMaskView)

        alpha = 0
    }

    func configure(text: String) {
        textLabel.text = text
        let maxTextW = bodyWidth - padLeft - padRight
        let textSize = textLabel.sizeThatFits(CGSize(width: maxTextW, height: .greatestFiniteMagnitude))
        totalHeight = max(textSize.height + padTop + padBottom, arrowHeight)
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: bodyWidth, height: bounds.height)
        arrowImageView.frame = CGRect(x: bodyWidth - 1, y: 0, width: arrowWidth, height: arrowHeight)
        textLabel.frame = CGRect(x: padLeft, y: padTop, width: bodyWidth - padLeft - padRight, height: bounds.height - padTop - padBottom)
        textMaskView.frame = CGRect(x: padLeft - 2, y: padTop - 2, width: bodyWidth - padLeft - padRight + 4, height: bounds.height - padTop - padBottom + 4)
        maskGradientLayer.frame = textMaskView.bounds
    }

    func play() {
        guard phase == .idle else { return }
        phase = .expanding
        alpha = 1
        textMaskView.alpha = 1
        textLabel.alpha = 0
        setNeedsLayout()
        layoutIfNeeded()
        guard bounds.width > 0 else {
            phase = .idle
            DispatchQueue.main.async { [weak self] in self?.play() }
            return
        }
        applyScaleFromRight(0.001)
        phaseStartTime = 0
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(animTick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func reset() {
        displayLink?.invalidate()
        displayLink = nil
        phase = .idle
        alpha = 0
        textMaskView.alpha = 1
        textLabel.alpha = 0
        layer.transform = CATransform3DIdentity
    }

    private func applyScaleFromRight(_ sx: CGFloat) {
        let w = bounds.width
        var t = CATransform3DIdentity
        t = CATransform3DTranslate(t, w / 2, 0, 0)
        t = CATransform3DScale(t, sx, 1, 1)
        t = CATransform3DTranslate(t, -w / 2, 0, 0)
        layer.transform = t
    }

    private func springBounce(_ t: CGFloat) -> CGFloat {
        if t <= 0 { return 0 }
        if t >= 1 { return 1 }
        let z: CGFloat = 0.5, w: CGFloat = 9.0
        let wd = w * sqrt(1 - z * z)
        let env = exp(-z * w * t)
        return 1 - env * (cos(wd * t) + (z / sqrt(1 - z * z)) * sin(wd * t))
    }

    @objc private func animTick(_ link: CADisplayLink) {
        let now = link.timestamp
        if phaseStartTime == 0 { phaseStartTime = now }
        let progress = min(CGFloat(now - phaseStartTime) / CGFloat(expandDuration), 1)
        applyScaleFromRight(max(0.001, springBounce(progress)))
        if progress > 0.7 {
            let ft = (progress - 0.7) / 0.3
            textMaskView.alpha = CGFloat(1 - ft)
            textLabel.alpha = ft
        }
        if progress >= 1 {
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

    // Auto Layout: 告诉约束系统这个 view 的固有尺寸
    override var intrinsicContentSize: CGSize {
        CGSize(width: totalWidth, height: totalHeight)
    }

    deinit { displayLink?.invalidate() }

    // MARK: - Embedded arrow image (Figma pic_arrow 2, @2x)
    private static let arrowImageBase64: String = """
    iVBORw0KGgoAAAANSUhEUgAAABsAAAB4CAYAAAADtImhAAAACXBIWXMAACE4AAAhOAFFljFgAAAA
    AXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAOdEVYdFNvZnR3YXJlAEZpZ21hnrGWYwAAAahJ
    REFUeAHt181NAkEYxvFnJhaAHezVeJAOpASvggl0IB0gFYAVcNQbJWgVEL1ICZwQ+XqdWYyKurAf
    s288PL8Ewlfyz8zO7C4AEREREREREdEOeWlVoMRiPleM2aMqlFis1xGUWMBEUOJj51DiYlLVWpE2
    fp4tLqBgGzOmCQXbGKSmMZX289Vs0UbJvmIG12WPzn57XSl7dHbnXcmjsz/eV/C67KAk9vdH0pbx
    VQ06Md/bDMqYTpvweeSmcwilGOKNPq4HPX5277eCGxldBjtv2sM/MQMZtyIEkCLmtoMsHkIsmDQx
    L8Js2UNBaWNuNqXljl+h01n62LbYK7LhM8aw3fA5F0z2mD9+ssi14fPEvKqMGpkXTN4Y4hN2xgVT
    IOaZjjzXU9++F4y5Db/CMO2GLxrzUl8hQsQQXyFSLJhAsTjYlqdGUynmrKW/b8OHjR24QoSOeW7B
    vLWgFPN/VM6gFtvgGGoxgwn0Yps+VGKCrjm5n/z11RGCMVN3sLrm9K6f9IuPmHl0j1s311Pkspok
    jWaHjOrBb7OTWDe2LoiIiIiIiIjoX3sHBeGDqyiLoSAAAAAASUVORK5CYII=
    """
}
