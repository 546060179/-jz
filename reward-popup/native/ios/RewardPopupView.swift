import UIKit

/// BingeUp 通知奖励弹窗 — 弹簧弹出动效
///
/// 使用 FadeAnimation 库的 MotionAnimator 驱动弹窗整体的弹簧进入/退出动画。
/// 弹窗内的图片（礼盒、金币、星星）保持静态，不做独立动效。
///
/// 用法:
/// ```swift
/// let popup = RewardPopupView()
/// popup.show(in: parentView)
/// ```
class RewardPopupView: UIView {

    // MARK: - Subviews

    /// 60% 黑色遮罩
    private let maskOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.alpha = 0
        return v
    }()

    /// 弹窗卡片容器
    private let cardContainer: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    /// 顶部装饰区（礼盒、金币、星星、渐变背景）
    private let headerView: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    /// 底部背景矩形 (y:72, h:88)
    private let headerBg: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.137, green: 0.145, blue: 0.145, alpha: 1) // #232525
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    /// 发光椭圆
    private let glowView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.alpha = 0.8
        return v
    }()

    /// 渐变叠加层切图
    private let headerOverlay: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 20
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.clipsToBounds = true
        iv.image = UIImage(named: "popup-header-overlay")
        return iv
    }()

    /// 礼盒图片
    private let trophyImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.image = UIImage(named: "popup-trophy")
        return iv
    }()

    /// 金币图片
    private let coinsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.image = UIImage(named: "popup-coins")
        return iv
    }()

    /// 大星星
    private let starBigImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "popup-star-big")
        return iv
    }()

    /// 小星星
    private let starSmallImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "popup-star-small")
        return iv
    }()

    /// 内容区背景
    private let bodyView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.137, green: 0.145, blue: 0.145, alpha: 1)
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    /// 标题
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Receive xX award"
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 描述
    private let descLabel: UILabel = {
        let l = UILabel()
        l.text = "Turn on notification permission to get reward notifications."
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(red: 0.769, green: 0.780, blue: 0.839, alpha: 1) // #C4C7D6
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    /// Later 按钮
    private let laterButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Later", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        b.setTitleColor(UIColor.white.withAlphaComponent(0.72), for: .normal)
        b.backgroundColor = UIColor(red: 0.231, green: 0.247, blue: 0.247, alpha: 1) // #3B3F3F
        b.layer.cornerRadius = 20
        return b
    }()

    /// Receive 按钮
    private let receiveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Receive", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        b.setTitleColor(UIColor(red: 0.078, green: 0.086, blue: 0.129, alpha: 1), for: .normal) // #141621
        b.backgroundColor = UIColor(red: 0.604, green: 0.937, blue: 0.369, alpha: 1) // #9AEF5E
        b.layer.cornerRadius = 20
        return b
    }()

    // MARK: - Callbacks

    var onLater: (() -> Void)?
    var onReceive: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Layout (Figma 坐标, 基于 375pt 宽度)

    private func setupViews() {
        addSubview(maskOverlay)
        addSubview(cardContainer)

        // Header
        cardContainer.addSubview(headerView)
        headerView.addSubview(headerBg)
        headerView.addSubview(glowView)
        headerView.addSubview(headerOverlay)
        headerView.addSubview(trophyImageView)
        headerView.addSubview(coinsImageView)
        headerView.addSubview(starBigImageView)
        headerView.addSubview(starSmallImageView)

        // Body
        cardContainer.addSubview(bodyView)
        bodyView.addSubview(titleLabel)
        bodyView.addSubview(descLabel)
        bodyView.addSubview(laterButton)
        bodyView.addSubview(receiveButton)

        // 发光渐变
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.267, green: 1, blue: 0.573, alpha: 1).cgColor,
            UIColor(red: 0.596, green: 0.918, blue: 1, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        glowView.layer.insertSublayer(gradientLayer, at: 0)

        // 模糊发光效果
        if let blurFilter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 70]) {
            glowView.layer.filters = [blurFilter]
        }

        // 按钮事件
        laterButton.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveTapped), for: .touchUpInside)

        // 遮罩点击关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(maskTapped))
        maskOverlay.addGestureRecognizer(tap)
        maskOverlay.isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskOverlay.frame = bounds

        // 弹窗卡片: Figma x:48, y:251, w:279
        let cardW: CGFloat = 279
        let cardX = (bounds.width - cardW) / 2
        let cardY: CGFloat = 251

        // Header: 279×160
        let headerH: CGFloat = 160
        headerView.frame = CGRect(x: 0, y: 0, width: cardW, height: headerH)

        // bg_rect: y:72, h:88
        headerBg.frame = CGRect(x: 0, y: 72, width: cardW, height: 88)

        // glow: x:44.08, y:54.49, 190.83×44.48
        glowView.frame = CGRect(x: 44.08, y: 54.49, width: 190.83, height: 44.48)
        glowView.layer.sublayers?.first?.frame = glowView.bounds

        // overlay: y:72, h:88
        headerOverlay.frame = CGRect(x: 0, y: 72, width: cardW, height: 88)

        // trophy: x:62.26, y:4, 133×140
        trophyImageView.frame = CGRect(x: 62.26, y: 4, width: 133, height: 140)

        // coins: x:149.26, y:72, 80×80
        coinsImageView.frame = CGRect(x: 149.26, y: 72, width: 80, height: 80)

        // stars
        starBigImageView.frame = CGRect(x: 55.69, y: 20.24, width: 16.53, height: 25.32)
        starSmallImageView.frame = CGRect(x: 39.34, y: 58.2, width: 6, height: 6.19)

        // Body
        let bodyY = headerH
        let bodyPadding: CGFloat = 8
        let textPaddingH: CGFloat = 16
        let buttonH: CGFloat = 40
        let gap: CGFloat = 20

        titleLabel.frame = CGRect(x: textPaddingH, y: bodyPadding + 0, width: cardW - textPaddingH * 2, height: 24)
        descLabel.frame = CGRect(x: textPaddingH, y: bodyPadding + 34, width: cardW - textPaddingH * 2, height: 40)
        descLabel.sizeToFit()
        let descBottom = descLabel.frame.maxY

        let btnY = descBottom + gap
        let btnW = (cardW - bodyPadding * 2 - 8) / 2
        laterButton.frame = CGRect(x: bodyPadding, y: btnY, width: btnW, height: buttonH)
        receiveButton.frame = CGRect(x: bodyPadding + btnW + 8, y: btnY, width: btnW, height: buttonH)

        let bodyH = btnY + buttonH + bodyPadding
        bodyView.frame = CGRect(x: 0, y: bodyY, width: cardW, height: bodyH)

        let totalCardH = headerH + bodyH
        cardContainer.frame = CGRect(x: cardX, y: cardY, width: cardW, height: totalCardH)
    }

    // MARK: - Show / Dismiss (使用 FadeAnimation 库弹簧动画)

    /// 弹窗弹簧弹出
    func show(in parentView: UIView) {
        frame = parentView.bounds
        parentView.addSubview(self)
        setNeedsLayout()
        layoutIfNeeded()

        // 初始状态：缩小 + 下移 + 透明
        cardContainer.alpha = 0
        cardContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            .concatenating(CGAffineTransform(translationX: 0, y: 40))

        // 遮罩淡入 — 使用库的 MotionAnimator
        let maskAnimator = MotionAnimator(
            targetView: maskOverlay,
            options: FadeOptions(duration: 0.35, easing: .easeOut)
        )
        maskAnimator.start(entering: true, effects: EffectPresets.fadeIn)

        // 弹窗弹簧弹出 — 使用 iOS 原生 UIView.animate(withDuration:delay:usingSpringWithDamping:)
        // 对齐库中 SPRING_PRESETS.bouncy: stiffness=200, damping=10
        // iOS spring damping ratio ≈ damping / (2 * sqrt(stiffness * mass)) = 10 / (2 * sqrt(200)) ≈ 0.354
        UIView.animate(
            withDuration: 0.7,
            delay: 0.05,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.cardContainer.alpha = 1
                self?.cardContainer.transform = .identity
            }
        )

        // 礼盒弹簧弹入（延迟 ~100ms, stiffness * 0.8）
        trophyImageView.alpha = 0
        trophyImageView.transform = CGAffineTransform(scaleX: 0, y: 0).rotated(by: -8 * .pi / 180)
        UIView.animate(
            withDuration: 0.8,
            delay: 0.15,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.trophyImageView.alpha = 1
                self?.trophyImageView.transform = .identity
            }
        )

        // 金币弹簧弹入（延迟 ~167ms, stiffness * 0.7）
        coinsImageView.alpha = 0
        coinsImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            .concatenating(CGAffineTransform(translationX: 0, y: 10))
        UIView.animate(
            withDuration: 0.85,
            delay: 0.22,
            usingSpringWithDamping: 0.48,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.coinsImageView.alpha = 1
                self?.coinsImageView.transform = .identity
            }
        )
    }

    /// 弹窗退出
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard animated else {
            removeFromSuperview()
            completion?()
            return
        }

        // 遮罩淡出
        let maskAnimator = MotionAnimator(
            targetView: maskOverlay,
            options: FadeOptions(duration: 0.25, easing: .easeOut)
        )
        maskAnimator.start(entering: false, effects: EffectPresets.fadeOut)

        // 弹窗缩小退出
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                self?.cardContainer.alpha = 0
                self?.cardContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                    .concatenating(CGAffineTransform(translationX: 0, y: 20))
            },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion?()
            }
        )
    }

    // MARK: - Actions

    @objc private func laterTapped() {
        dismiss { [weak self] in self?.onLater?() }
    }

    @objc private func receiveTapped() {
        dismiss { [weak self] in self?.onReceive?() }
    }

    @objc private func maskTapped() {
        dismiss()
    }
}
