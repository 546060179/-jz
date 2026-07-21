import UIKit
import QuartzCore

/// BubbleExpandView — 气泡展开动效组件
///
/// 从一个小圆点/窄条向左（或向右）弹性展开为带文字的气泡，文字在展开动画的
/// 后段淡入。展开曲线为阻尼谐振子（damped harmonic oscillator），带轻微过冲回弹，
/// 与 Web/Android 端同款参数（zeta=0.5, omega=9.0）。
///
/// 对齐 `docs/components.html` 中 bubble-expand 的示例 API：
/// ```swift
/// let bubble = BubbleExpandView()
/// bubble.text = "限时免费"
/// bubble.expandDuration = 0.65
/// bubble.textFadeDuration = 0.3
/// bubble.arrowDirection = .right
/// view.addSubview(bubble)
/// bubble.play()
/// ```
///
/// 布局说明：组件用 frame 布局。`play()` 会以当前 frame 的**右边缘**为锚点向左展开
/// （arrowDirection == .right 时），或以左边缘为锚点向右展开（.left）。调用前请先把
/// 视图放到目标位置（设定 frame）。
public class BubbleExpandView: UIView {

    /// 展开方向锚点：.right 右对齐向左展开；.left 左对齐向右展开
    public enum ArrowDirection {
        case left
        case right
    }

    // MARK: - 可配置属性

    /// 气泡文字
    public var text: String = "" {
        didSet { label.text = text }
    }
    /// 展开动画时长（秒），默认 0.65
    public var expandDuration: TimeInterval = 0.65
    /// 文字淡入时长（秒），默认 0.3
    public var textFadeDuration: TimeInterval = 0.3
    /// 展开/收起锚点方向，默认 .right（右对齐向左展开）
    public var arrowDirection: ArrowDirection = .right
    /// 是否显示指向来源的小箭头（预留属性，当前版本聚焦展开+文字动效，暂不绘制三角）
    public var showArrow: Bool = false
    /// 收起态宽度（pt），默认 20
    public var collapsedWidth: CGFloat = 20
    /// 气泡高度（pt），默认 22
    public var bubbleHeight: CGFloat = 22
    /// 文字左右内边距（pt），默认 12
    public var horizontalPadding: CGFloat = 12
    /// 气泡填充色，默认品牌蓝 #186CE5
    public var fillColor: UIColor = UIColor(red: 0x18/255.0, green: 0x6C/255.0, blue: 0xE5/255.0, alpha: 1) {
        didSet { backgroundColor = fillColor }
    }
    /// 阻尼比 zeta（0~1，越小回弹越明显），默认 0.5
    public var zeta: CGFloat = 0.5
    /// 角频率 omega，默认 9.0
    public var omega: CGFloat = 9.0

    // MARK: - 内部状态

    private let label = UILabel()
    private var displayLink: CADisplayLink?
    private var startTimestamp: CFTimeInterval = 0
    private var expandedWidth: CGFloat = 0
    private var anchorX: CGFloat = 0   // 展开锚点（右缘或左缘）的 x

    // MARK: - Init

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = fillColor
        layer.cornerRadius = bubbleHeight / 2
        clipsToBounds = true

        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.alpha = 0
        addSubview(label)
    }

    // MARK: - 阻尼谐振子求值（与 Web/Android 同款公式）

    private func springBounce(_ t: CGFloat) -> CGFloat {
        if t <= 0 { return 0 }
        if t >= 1 { return 1 }
        let wd = omega * sqrt(1 - zeta * zeta)
        let env = exp(-zeta * omega * t)
        return 1 - env * (cos(wd * t) + (zeta / sqrt(1 - zeta * zeta)) * sin(wd * t))
    }

    // MARK: - 播放

    /// 从收起态弹性展开为气泡，文字在后 30% 淡入。
    public func play() {
        stop()

        // 测量展开后宽度（按文字自适应）
        label.text = text
        label.sizeToFit()
        expandedWidth = max(collapsedWidth, label.bounds.width + horizontalPadding * 2)

        // 记录锚点：右展开锁右缘，左展开锁左缘
        let currentFrame = frame
        switch arrowDirection {
        case .right: anchorX = currentFrame.maxX > 0 ? currentFrame.maxX : collapsedWidth
        case .left:  anchorX = currentFrame.minX
        }

        applyWidth(collapsedWidth)
        label.alpha = 0

        startTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        if #available(iOS 15.0, *) {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        }
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// 停止动画
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    deinit { stop() }

    // MARK: - 逐帧驱动

    @objc private func tick(_ link: CADisplayLink) {
        if startTimestamp == 0 { startTimestamp = link.timestamp }
        let elapsed = CGFloat(link.timestamp - startTimestamp)
        let p = min(elapsed / CGFloat(expandDuration), 1)
        let s = springBounce(p)
        let w = max(collapsedWidth, collapsedWidth + (expandedWidth - collapsedWidth) * s)
        applyWidth(w)

        // 文字在后 30% 淡入
        let fadeStart: CGFloat = 1 - CGFloat(textFadeDuration / expandDuration)
        if p > fadeStart {
            label.alpha = min((p - fadeStart) / (1 - fadeStart), 1)
        }

        if p >= 1 {
            applyWidth(expandedWidth)
            label.alpha = 1
            stop()
        }
    }

    private func applyWidth(_ w: CGFloat) {
        var f = frame
        switch arrowDirection {
        case .right: f.origin.x = anchorX - w   // 右缘固定，向左长
        case .left:  f.origin.x = anchorX        // 左缘固定，向右长
        }
        f.size.width = w
        f.size.height = bubbleHeight
        frame = f
        layer.cornerRadius = bubbleHeight / 2
        // 文字贴右（右展开）或贴左（左展开），始终显示完整文字
        label.frame = CGRect(x: w - expandedWidth + (expandedWidth - label.bounds.width) / 2,
                             y: 0, width: label.bounds.width, height: bubbleHeight)
    }
}
