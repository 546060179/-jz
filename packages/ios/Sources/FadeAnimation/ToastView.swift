import UIKit

/// ToastView — 轻量提示气泡视图
///
/// 一个 pill 样式的消息条,通常配合 `MotionAnimator` 的 slideUpIn 做进入/退出。
/// 对齐 `docs/components.html` 中 toast 的示例 API：
/// ```swift
/// let toast = ToastView(message: "操作成功")
/// view.addSubview(toast)
/// MotionAnimator(targetView: toast).start(entering: true, effects: EffectPresets.slideUpIn,
///                                         options: FadeOptions(intent: .enter))
/// ```
public class ToastView: UIView {

    private let label = UILabel()

    /// 提示文字
    public var message: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }

    public init(message: String) {
        super.init(frame: .zero)
        setup()
        label.text = message
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        layer.cornerRadius = 8
        layer.masksToBounds = true

        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
