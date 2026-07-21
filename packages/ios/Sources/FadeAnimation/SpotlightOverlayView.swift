import UIKit

/// SpotlightOverlayView — 聚光灯引导遮罩
///
/// 铺满父视图的半透明遮罩,在目标区域"挖空"出一个高亮孔,并在其下方显示提示文字。
/// 通常配合 `motion(entering:effects:options:)` 做淡入。对齐 `docs/components.html`
/// 中 spotlight 的示例 API：
/// ```swift
/// let overlay = SpotlightOverlayView(targetRect: publishBtn.frame)
/// window.addSubview(overlay)
/// overlay.motion(entering: true, effects: EffectPresets.fadeIn,
///                options: FadeOptions(intent: .enter))
/// ```
public class SpotlightOverlayView: UIView {

    /// 高亮目标区域(相对本视图坐标系)
    public var targetRect: CGRect { didSet { setNeedsDisplay(); layoutTip() } }
    /// 目标区域外扩的内边距(pt),默认 8
    public var holePadding: CGFloat = 8 { didSet { setNeedsDisplay() } }
    /// 挖空孔圆角,默认 8
    public var holeCornerRadius: CGFloat = 8 { didSet { setNeedsDisplay() } }
    /// 遮罩颜色,默认黑色 50% 透明
    public var maskColor: UIColor = UIColor.black.withAlphaComponent(0.5) { didSet { setNeedsDisplay() } }

    private let tipLabel = UILabel()

    public init(targetRect: CGRect, tipText: String = "点击这里") {
        self.targetRect = targetRect
        super.init(frame: .zero)
        isOpaque = false
        backgroundColor = .clear

        tipLabel.text = tipText
        tipLabel.textColor = .white
        tipLabel.font = .boldSystemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        addSubview(tipLabel)
    }

    public required init?(coder: NSCoder) {
        self.targetRect = .zero
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = .clear
        addSubview(tipLabel)
    }

    /// 加到父视图后自动铺满
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let sv = superview {
            frame = sv.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            setNeedsDisplay()
            layoutTip()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutTip()
    }

    private func layoutTip() {
        let hole = targetRect.insetBy(dx: -holePadding, dy: -holePadding)
        let maxW = bounds.width - 32
        let size = tipLabel.sizeThatFits(CGSize(width: maxW, height: .greatestFiniteMagnitude))
        let w = min(size.width, maxW)
        tipLabel.frame = CGRect(x: (bounds.width - w) / 2,
                                y: hole.maxY + 12,
                                width: w, height: size.height)
    }

    /// 绘制半透明遮罩并挖空目标区域
    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(maskColor.cgColor)
        ctx.fill(rect)

        let hole = targetRect.insetBy(dx: -holePadding, dy: -holePadding)
        let holePath = UIBezierPath(roundedRect: hole, cornerRadius: holeCornerRadius)
        ctx.setBlendMode(.clear)
        holePath.fill()
        ctx.setBlendMode(.normal)
    }
}
