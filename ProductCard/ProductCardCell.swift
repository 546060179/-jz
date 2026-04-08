import UIKit
import FadeAnimation

/// 商品卡片 Cell — 封面图 + 标题 + 价格 + 购买按钮
final class ProductCardCell: UICollectionViewCell {

    static let reuseID = "ProductCardCell"

    // MARK: - UI Elements

    let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.93, alpha: 1)
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let buyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("购买", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.backgroundColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1)
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    /// 封面图高度约束（瀑布流中动态设置）
    private var imageHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 8
        contentView.clipsToBounds = false

        // 内部裁剪容器
        let container = UIView()
        container.clipsToBounds = true
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        container.addSubview(coverImageView)
        container.addSubview(titleLabel)
        container.addSubview(priceLabel)
        container.addSubview(buyButton)

        let imgH = coverImageView.heightAnchor.constraint(equalToConstant: 180)
        imageHeightConstraint = imgH

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.topAnchor.constraint(equalTo: container.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imgH,

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),

            buyButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            buyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            buyButton.widthAnchor.constraint(equalToConstant: 56),
            buyButton.heightAnchor.constraint(equalToConstant: 28),

            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -10),
            buyButton.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -10),
        ])

        buyButton.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
    }

    // MARK: - Configure

    func configure(title: String, price: String, imageHeight: CGFloat) {
        titleLabel.text = title
        priceLabel.text = price
        imageHeightConstraint?.constant = imageHeight
    }

    // MARK: - Animations

    /// 点击卡片 — scaleIn 效果
    func animateTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = .identity
            }
        }
    }

    /// 购买按钮脉冲效果 (scale 0.95 → 1)
    @objc private func buyTapped() {
        buyButton.pulse()
    }
}
