import UIKit

/// 短剧卡片 Cell — 匹配 Figma 设计稿 (109x145 封面 + 标题 + 标签)
final class ShortMaxCardCell: UICollectionViewCell {

    static let reuseID = "ShortMaxCardCell"

    // MARK: - UI Elements

    /// 封面图
    let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = ShortMaxDesign.coverRadius
        iv.backgroundColor = ShortMaxDesign.bgCard
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// 封面底部渐变遮罩（播放量区域）
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 17/255, green: 18/255, blue: 24/255, alpha: 0).cgColor,
            UIColor(red: 17/255, green: 18/255, blue: 24/255, alpha: 0.5).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    /// 播放图标 + 播放量
    private let viewCountContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 2
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let playIcon: UILabel = {
        let label = UILabel()
        label.text = "▶"
        label.font = .systemFont(ofSize: 8)
        label.textColor = .white
        return label
    }()

    private let viewCountLabel: UILabel = {
        let label = UILabel()
        label.font = ShortMaxDesign.montserrat(.semibold, size: 10)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 右上角标签 (Hot / New / VIP / Dubbed)
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = ShortMaxDesign.montserrat(.medium, size: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tagContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.maskedCorners = [.layerMinXMaxYCorner]
        v.layer.cornerRadius = 4
        return v
    }()

    /// 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ShortMaxDesign.montserrat(.medium, size: 11)
        label.textColor = ShortMaxDesign.textPrimary
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 题材标签 (Revenge / CEO / Secret Baby)
    private let genreContainer: UIView = {
        let v = UIView()
        v.backgroundColor = ShortMaxDesign.bgCard
        v.layer.cornerRadius = 2
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = ShortMaxDesign.montserrat(.medium, size: 10)
        label.textColor = ShortMaxDesign.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 排行榜标签
    private let rankContainer: UIView = {
        let v = UIView()
        v.backgroundColor = ShortMaxDesign.tagRedBg
        v.layer.cornerRadius = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = ShortMaxDesign.montserrat(.medium, size: 10)
        label.textColor = ShortMaxDesign.accentRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: 0,
            y: ShortMaxDesign.coverHeight - 24,
            width: bounds.width,
            height: 24
        )
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        // 封面
        contentView.addSubview(coverImageView)
        coverImageView.layer.addSublayer(gradientLayer)

        // 播放量
        viewCountContainer.addArrangedSubview(playIcon)
        viewCountContainer.addArrangedSubview(viewCountLabel)
        contentView.addSubview(viewCountContainer)

        // 右上角标签
        tagContainer.addSubview(tagLabel)
        contentView.addSubview(tagContainer)

        // 标题
        contentView.addSubview(titleLabel)

        // 题材标签
        genreContainer.addSubview(genreLabel)
        contentView.addSubview(genreContainer)

        // 排行榜标签
        rankContainer.addSubview(rankLabel)
        contentView.addSubview(rankContainer)

        NSLayoutConstraint.activate([
            // 封面
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: ShortMaxDesign.coverHeight),

            // 播放量 — 封面右下角
            viewCountContainer.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -4),
            viewCountContainer.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -2),

            // 标签 — 封面右上角
            tagContainer.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            tagContainer.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            tagLabel.topAnchor.constraint(equalTo: tagContainer.topAnchor, constant: 1),
            tagLabel.bottomAnchor.constraint(equalTo: tagContainer.bottomAnchor, constant: -1),
            tagLabel.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor, constant: 4),
            tagLabel.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: -4),
            tagContainer.heightAnchor.constraint(equalToConstant: 14),

            // 标题
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),

            // 题材标签
            genreContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            genreContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genreContainer.heightAnchor.constraint(equalToConstant: 16),
            genreLabel.topAnchor.constraint(equalTo: genreContainer.topAnchor),
            genreLabel.bottomAnchor.constraint(equalTo: genreContainer.bottomAnchor, constant: -2),
            genreLabel.leadingAnchor.constraint(equalTo: genreContainer.leadingAnchor, constant: 4),
            genreLabel.trailingAnchor.constraint(equalTo: genreContainer.trailingAnchor, constant: -4),

            // 排行榜标签
            rankContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            rankContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rankContainer.heightAnchor.constraint(equalToConstant: 16),
            rankLabel.topAnchor.constraint(equalTo: rankContainer.topAnchor),
            rankLabel.bottomAnchor.constraint(equalTo: rankContainer.bottomAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: rankContainer.leadingAnchor, constant: 4),
            rankLabel.trailingAnchor.constraint(equalTo: rankContainer.trailingAnchor, constant: -4),
        ])
    }

    // MARK: - Configure

    func configure(with drama: ShortDrama) {
        titleLabel.text = drama.title
        viewCountLabel.text = drama.viewCount

        // 封面占位色（实际项目替换为网络图片加载）
        if drama.coverURL == nil {
            let colors: [UIColor] = [
                UIColor(red: 0.55, green: 0.47, blue: 0.85, alpha: 1),
                UIColor(red: 0.95, green: 0.55, blue: 0.55, alpha: 1),
                UIColor(red: 0.40, green: 0.73, blue: 0.85, alpha: 1),
                UIColor(red: 0.95, green: 0.77, blue: 0.40, alpha: 1),
                UIColor(red: 0.55, green: 0.82, blue: 0.55, alpha: 1),
            ]
            coverImageView.backgroundColor = colors[abs(drama.title.hashValue) % colors.count]
        }

        // 右上角标签
        if let tag = drama.tag {
            tagContainer.isHidden = false
            tagLabel.text = tag.text
            if tag.text == "VIP" {
                // VIP 使用金色渐变
                let gradient = CAGradientLayer()
                gradient.colors = [
                    UIColor(red: 243/255, green: 173/255, blue: 99/255, alpha: 1).cgColor,
                    UIColor(red: 255/255, green: 234/255, blue: 203/255, alpha: 1).cgColor
                ]
                gradient.startPoint = CGPoint(x: 0.5, y: 0)
                gradient.endPoint = CGPoint(x: 0.5, y: 1)
                gradient.frame = CGRect(x: 0, y: 0, width: 30, height: 14)
                gradient.maskedCorners = [.layerMinXMaxYCorner]
                gradient.cornerRadius = 4
                tagContainer.layer.insertSublayer(gradient, at: 0)
                tagContainer.backgroundColor = .clear
                tagLabel.textColor = UIColor(red: 88/255, green: 45/255, blue: 1/255, alpha: 1) // #582D01
            } else {
                tagContainer.backgroundColor = tag.color
                tagLabel.textColor = .white
            }
        } else {
            tagContainer.isHidden = true
        }

        // 题材标签
        if let genre = drama.genreTag, drama.rankTag == nil {
            genreContainer.isHidden = false
            genreLabel.text = genre
            rankContainer.isHidden = true
        } else {
            genreContainer.isHidden = true
        }

        // 排行榜标签
        if let rank = drama.rankTag {
            rankContainer.isHidden = false
            rankLabel.text = "\(rank.listName) \(rank.rank)"
            genreContainer.isHidden = true
        } else {
            rankContainer.isHidden = true
        }
    }
}
