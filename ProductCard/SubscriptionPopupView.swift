import UIKit
import FadeAnimation

// MARK: - 订阅弹窗视图（匹配 Figma 设计稿 node 49951:239493 "功能弹窗"）
// 集成 FadeAnimation 库实现弹窗出现/消失动效

final class SubscriptionPopupView: UIView {

    // MARK: - 设计 Token（从 Figma 提取）

    private enum Design {
        // 颜色
        static let bgDark = UIColor(red: 35/255, green: 37/255, blue: 42/255, alpha: 1)       // #23252A
        static let bgCard = UIColor(red: 25/255, green: 27/255, blue: 33/255, alpha: 1)        // #191B21
        static let vipDark = UIColor(red: 88/255, green: 45/255, blue: 1/255, alpha: 1)        // #582D01
        static let vipLight = UIColor(red: 254/255, green: 218/255, blue: 164/255, alpha: 1)   // #FEDAA4
        static let vipLightHalf = UIColor(red: 254/255, green: 218/255, blue: 164/255, alpha: 0.5)
        static let textSecondary = UIColor(red: 159/255, green: 159/255, blue: 162/255, alpha: 1) // #9F9FA2
        static let orangeStart = UIColor(red: 246/255, green: 97/255, blue: 15/255, alpha: 1)  // #F6610F
        static let orangeEnd = UIColor(red: 254/255, green: 218/255, blue: 164/255, alpha: 1)  // #FEDAA4
        static let gradientOrangeStart = UIColor(red: 255/255, green: 113/255, blue: 11/255, alpha: 1) // #FF710B
        static let gradientOrangeEnd = UIColor(red: 255/255, green: 53/255, blue: 28/255, alpha: 1)    // #FF351C
        static let goldStart = UIColor(red: 243/255, green: 173/255, blue: 99/255, alpha: 1)   // #F3AD63
        static let goldEnd = UIColor(red: 255/255, green: 234/255, blue: 203/255, alpha: 1)    // #FFEACB
        static let btnGoldStart = UIColor(red: 255/255, green: 234/255, blue: 203/255, alpha: 1) // #FFEACB
        static let btnGoldEnd = UIColor(red: 243/255, green: 173/255, blue: 99/255, alpha: 1)    // #F3AD63
        static let tagBorderColor = UIColor(red: 193/255, green: 165/255, blue: 128/255, alpha: 0.15)
        static let tagBgDark = UIColor(red: 87/255, green: 61/255, blue: 35/255, alpha: 1)     // #573D23
        static let maskColor = UIColor(red: 17/255, green: 18/255, blue: 24/255, alpha: 0.75)  // #111218 75%

        // 尺寸
        static let cardWidth: CGFloat = 279  // Figma: 375 - 48*2 padding
        static let cardRadius: CGFloat = 16
        static let headerHeight: CGFloat = 125
        static let closeSize: CGFloat = 24
    }

    // MARK: - 回调

    var onSubscribeTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?

    // MARK: - UI Elements

    /// 半透明遮罩层
    private let maskOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = Design.maskColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// 弹窗卡片容器
    private let cardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = Design.bgDark
        v.layer.cornerRadius = Design.cardRadius
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// 头部渐变区域（金色 + 装饰图）
    private let headerView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let headerGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 87/255, green: 61/255, blue: 35/255, alpha: 1).cgColor,
            UIColor(red: 35/255, green: 37/255, blue: 42/255, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    /// "All Free" 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "All Free"
        label.font = ShortMaxDesign.montserrat(.black, size: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 倒计时 + 折扣标签
    private let promoTagView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let promoLabel: UILabel = {
        let label = UILabel()
        label.text = "23:40:12  |  20% Off"
        label.font = ShortMaxDesign.montserrat(.semibold, size: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 价格区域
    private let priceContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 2
        sv.alignment = .lastBaseline
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$14.99"
        label.font = ShortMaxDesign.montserrat(.black, size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let perWeekLabel: UILabel = {
        let label = UILabel()
        label.text = "/week"
        label.font = ShortMaxDesign.montserrat(.medium, size: 12)
        label.textColor = Design.vipLight
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// "For 3 weeks" 标签
    private let durationTag: UIView = {
        let v = UIView()
        v.backgroundColor = Design.tagBgDark
        v.layer.cornerRadius = 10
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "For 3 weeks"
        label.font = ShortMaxDesign.montserrat(.semibold, size: 10)
        label.textColor = Design.vipLight
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 功能列表
    private let featuresStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    /// 订阅按钮
    private let subscribeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Subscribe Now", for: .normal)
        btn.setTitleColor(Design.vipDark, for: .normal)
        btn.titleLabel?.font = ShortMaxDesign.montserrat(.semibold, size: 14)
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let btnGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    /// 底部说明文字
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = "$14.99 for the first three weeks, then $19.99/week"
        label.font = ShortMaxDesign.montserrat(.medium, size: 9)
        label.textColor = Design.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 关闭按钮
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✕", for: .normal)
        btn.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    /// 价格卡片容器（深色背景 + 金色边框）
    private let priceCard: UIView = {
        let v = UIView()
        v.backgroundColor = Design.bgCard
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = Design.tagBorderColor.cgColor
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradient.frame = headerView.bounds
        btnGradient.frame = subscribeButton.bounds
        btnGradient.colors = [Design.btnGoldStart.cgColor, Design.btnGoldEnd.cgColor]
    }

    // MARK: - Setup

    private func setupUI() {
        // 遮罩层
        addSubview(maskOverlay)
        NSLayoutConstraint.activate([
            maskOverlay.topAnchor.constraint(equalTo: topAnchor),
            maskOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            maskOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            maskOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // 卡片容器
        addSubview(cardContainer)
        NSLayoutConstraint.activate([
            cardContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardContainer.widthAnchor.constraint(equalToConstant: Design.cardWidth),
        ])

        // 头部渐变
        headerView.layer.insertSublayer(headerGradient, at: 0)
        cardContainer.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Design.headerHeight),
        ])

        // "All Free" 标题（金色渐变文字）
        cardContainer.addSubview(titleLabel)
        applyGoldGradient(to: titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
        ])

        // 价格卡片
        cardContainer.addSubview(priceCard)
        NSLayoutConstraint.activate([
            priceCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            priceCard.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
            priceCard.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
        ])

        // "For 3 weeks" 标签
        durationTag.addSubview(durationLabel)
        priceCard.addSubview(durationTag)
        NSLayoutConstraint.activate([
            durationTag.topAnchor.constraint(equalTo: priceCard.topAnchor),
            durationTag.leadingAnchor.constraint(equalTo: priceCard.leadingAnchor),
            durationTag.heightAnchor.constraint(equalToConstant: 20),
            durationLabel.centerYAnchor.constraint(equalTo: durationTag.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: durationTag.leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: durationTag.trailingAnchor, constant: -8),
        ])

        // 倒计时标签（右上角）
        let promoGradient = CAGradientLayer()
        promoGradient.colors = [Design.gradientOrangeStart.cgColor, Design.gradientOrangeEnd.cgColor]
        promoGradient.startPoint = CGPoint(x: 0, y: 0.5)
        promoGradient.endPoint = CGPoint(x: 1, y: 0.5)
        promoGradient.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        promoGradient.cornerRadius = 10
        promoGradient.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        promoTagView.layer.insertSublayer(promoGradient, at: 0)
        promoTagView.addSubview(promoLabel)
        cardContainer.addSubview(promoTagView)
        NSLayoutConstraint.activate([
            promoTagView.bottomAnchor.constraint(equalTo: priceCard.topAnchor),
            promoTagView.trailingAnchor.constraint(equalTo: priceCard.trailingAnchor),
            promoTagView.heightAnchor.constraint(equalToConstant: 20),
            promoLabel.centerYAnchor.constraint(equalTo: promoTagView.centerYAnchor),
            promoLabel.leadingAnchor.constraint(equalTo: promoTagView.leadingAnchor, constant: 8),
            promoLabel.trailingAnchor.constraint(equalTo: promoTagView.trailingAnchor, constant: -8),
        ])

        // 价格
        priceLabel.textColor = Design.orangeStart
        priceContainer.addArrangedSubview(priceLabel)
        priceContainer.addArrangedSubview(perWeekLabel)
        priceCard.addSubview(priceContainer)
        NSLayoutConstraint.activate([
            priceContainer.topAnchor.constraint(equalTo: durationTag.bottomAnchor, constant: 20),
            priceContainer.centerXAnchor.constraint(equalTo: priceCard.centerXAnchor),
        ])

        // 功能列表
        let features: [(String, String)] = [
            ("🎬", "Unlimited viewing"),
            ("📺", "1080P quality"),
            ("🚫", "No ads"),
            ("⬇️", "Offline download"),
        ]
        let row1 = makeFeatureRow(features[0], features[1])
        let row2 = makeFeatureRow(features[2], features[3])
        featuresStack.addArrangedSubview(row1)
        featuresStack.addArrangedSubview(row2)
        priceCard.addSubview(featuresStack)
        NSLayoutConstraint.activate([
            featuresStack.topAnchor.constraint(equalTo: priceContainer.bottomAnchor, constant: 20),
            featuresStack.leadingAnchor.constraint(equalTo: priceCard.leadingAnchor, constant: 12),
            featuresStack.trailingAnchor.constraint(equalTo: priceCard.trailingAnchor, constant: -12),
            featuresStack.bottomAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: -16),
        ])

        // 订阅按钮
        subscribeButton.layer.insertSublayer(btnGradient, at: 0)
        cardContainer.addSubview(subscribeButton)
        NSLayoutConstraint.activate([
            subscribeButton.topAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: 16),
            subscribeButton.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            subscribeButton.widthAnchor.constraint(equalToConstant: 223),
            subscribeButton.heightAnchor.constraint(equalToConstant: 36),
        ])

        // 底部说明
        cardContainer.addSubview(disclaimerLabel)
        NSLayoutConstraint.activate([
            disclaimerLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 4),
            disclaimerLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 28),
            disclaimerLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -28),
            disclaimerLabel.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -16),
        ])

        // 关闭按钮
        cardContainer.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: Design.closeSize),
            closeButton.heightAnchor.constraint(equalToConstant: Design.closeSize),
        ])

        // 初始隐藏
        alpha = 0
        cardContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        subscribeButton.addTarget(self, action: #selector(subscribeTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskTapped(_:)))
        maskOverlay.addGestureRecognizer(tapGesture)
    }

    // MARK: - 动效：出现（使用 FadeAnimation 库）

    /// 弹窗出现动效：遮罩淡入 + 卡片 fadeIn + scale 弹性放大
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])

        // 1. 遮罩层淡入
        maskOverlay.alpha = 0
        let maskFadeOptions = FadeOptions(duration: 250)
        maskOverlay.fadeIn(options: maskFadeOptions, onEnd: nil)

        // 2. 卡片 fadeIn + scale 弹性动画
        cardContainer.alpha = 0
        cardContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        alpha = 1

        let cardFadeOptions = FadeOptions(duration: 300, delay: 100)
        cardContainer.fadeIn(options: cardFadeOptions, onEnd: nil)

        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: [],
            animations: { [weak self] in
                self?.cardContainer.transform = .identity
            },
            completion: nil
        )
    }

    // MARK: - 动效：消失（使用 FadeAnimation 库）

    /// 弹窗消失动效：卡片 fadeOut + scale 缩小 → 遮罩淡出 → 移除
    func dismiss(completion: (() -> Void)? = nil) {
        // 1. 卡片 fadeOut + 缩小
        let cardFadeOptions = FadeOptions(duration: 200)
        cardContainer.fadeOut(options: cardFadeOptions, onEnd: nil)

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: { [weak self] in
                self?.cardContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: nil
        )

        // 2. 遮罩层延迟淡出
        let maskFadeOptions = FadeOptions(duration: 200, delay: 100)
        maskOverlay.fadeOut(options: maskFadeOptions, onEnd: { [weak self] in
            self?.removeFromSuperview()
            completion?()
        })
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(completion: onCloseTapped)
    }

    @objc private func subscribeTapped() {
        // 按钮脉冲效果
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.subscribeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.1, animations: {
                self?.subscribeButton.transform = .identity
            }) { _ in
                self?.onSubscribeTapped?()
            }
        }
    }

    @objc private func maskTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !cardContainer.frame.contains(location) {
            dismiss(completion: onCloseTapped)
        }
    }

    // MARK: - Helpers

    private func makeFeatureRow(_ left: (String, String), _ right: (String, String)) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fillEqually

        row.addArrangedSubview(makeFeatureItem(icon: left.0, text: left.1))
        row.addArrangedSubview(makeFeatureItem(icon: right.0, text: right.1))
        return row
    }

    private func makeFeatureItem(icon: String, text: String) -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 12)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = ShortMaxDesign.montserrat(.medium, size: 9)
        textLabel.textColor = Design.vipLightHalf

        sv.addArrangedSubview(iconLabel)
        sv.addArrangedSubview(textLabel)
        return sv
    }

    private func applyGoldGradient(to label: UILabel) {
        // 金色渐变文字效果
        label.textColor = Design.goldStart
        // 注意：真正的渐变文字需要在 layoutSubviews 中用 CAGradientLayer + mask 实现
        // 这里简化为金色
    }
}
