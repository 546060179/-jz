import UIKit

/// NotificationBanner — 应用内通知横幅视图
///
/// 顶部下滑进入的通知卡片,含可选图标与标题。动画由 `MotionAnimator` 驱动
/// (通常 fade + slide down)。对齐 `docs/components.html` 中 notification 的示例 API：
/// ```swift
/// let banner = NotificationBanner(title: title)
/// view.addSubview(banner)
/// MotionAnimator(targetView: banner).start(
///   entering: true,
///   effects: [.fade(from: 0, to: 1), .slide(direction: .down, distance: 20)]
/// )
/// ```
public class NotificationBanner: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    /// 标题文字
    public var title: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    /// 左侧图标(可选)
    public var icon: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue; updateIconVisibility() }
    }

    public init(title: String, icon: UIImage? = nil) {
        super.init(frame: .zero)
        setup()
        titleLabel.text = title
        iconView.image = icon
        updateIconVisibility()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0x18/255.0, green: 0x6C/255.0, blue: 0xE5/255.0, alpha: 1)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    private var iconLeadingConstraint: NSLayoutConstraint?

    private func updateIconVisibility() {
        iconView.isHidden = (iconView.image == nil)
    }
}
