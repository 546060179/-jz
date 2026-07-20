import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .dark
        let nav = UINavigationController(rootViewController: MotionGalleryViewController())
        nav.navigationBar.prefersLargeTitles = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}

// MARK: - 自动巡演：依次循环播放全部预设，单屏录屏即可覆盖所有动效

final class AutoTourViewController: UIViewController {

    private struct Item {
        let name: String
        let effects: [MotionEffect]
        let entering: Bool
    }

    private let items: [Item] = [
        Item(name: "Fade In / 淡入", effects: EffectPresets.fadeIn, entering: true),
        Item(name: "Fade Out / 淡出", effects: EffectPresets.fadeOut, entering: false),
        Item(name: "Scale Fade In / 缩放淡入", effects: EffectPresets.scaleFadeIn, entering: true),
        Item(name: "Scale Fade Out / 缩放淡出", effects: EffectPresets.scaleFadeOut, entering: false),
        Item(name: "Slide Up In / 下方滑入", effects: EffectPresets.slideUpIn, entering: true),
        Item(name: "Slide Down Out / 向下滑出", effects: EffectPresets.slideDownOut, entering: false),
        Item(name: "Slide Left In / 左侧滑入", effects: EffectPresets.slideLeftIn, entering: true),
        Item(name: "Slide Right In / 右侧滑入", effects: EffectPresets.slideRightIn, entering: true),
        Item(name: "Rotate Fade In / 旋转淡入", effects: EffectPresets.rotateFadeIn, entering: true),
        Item(name: "Rotate Fade Out / 旋转淡出", effects: EffectPresets.rotateFadeOut, entering: false),
        Item(name: "Blur Fade In / 模糊淡入", effects: EffectPresets.blurFadeIn, entering: true),
        Item(name: "Blur Fade Out / 模糊淡出", effects: EffectPresets.blurFadeOut, entering: false),
        Item(name: "Flip X In / 绕X轴翻入", effects: EffectPresets.flipXIn, entering: true),
        Item(name: "Flip X Out / 绕X轴翻出", effects: EffectPresets.flipXOut, entering: false),
        Item(name: "Flip Y In / 绕Y轴翻入", effects: EffectPresets.flipYIn, entering: true),
        Item(name: "Flip Y Out / 绕Y轴翻出", effects: EffectPresets.flipYOut, entering: false),
        Item(name: "Collapse In / 展开", effects: EffectPresets.collapseIn, entering: true),
        Item(name: "Collapse Out / 折叠", effects: EffectPresets.collapseOut, entering: false),
    ]

    private let box = UIView()
    private let nameLabel = UILabel()
    private let indexLabel = UILabel()
    private let emoji = UILabel()
    private var heightConstraint: NSLayoutConstraint!
    private var animator: DemoAnimator?
    private var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kinetic UI · 自动巡演"
        view.backgroundColor = .systemBackground
        setupUI()
        // 启动后依次播放
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.playCurrent()
        }
    }

    private func setupUI() {
        box.backgroundColor = .systemIndigo
        box.layer.cornerRadius = 20
        box.translatesAutoresizingMaskIntoConstraints = false

        emoji.text = "🎬"
        emoji.font = .systemFont(ofSize: 40)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(emoji)

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        indexLabel.font = .systemFont(ofSize: 14)
        indexLabel.textColor = .secondaryLabel
        indexLabel.textAlignment = .center
        indexLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(box)
        view.addSubview(nameLabel)
        view.addSubview(indexLabel)

        heightConstraint = box.heightAnchor.constraint(equalToConstant: 120)
        NSLayoutConstraint.activate([
            box.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            box.widthAnchor.constraint(equalToConstant: 120),
            heightConstraint,
            emoji.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            nameLabel.topAnchor.constraint(equalTo: box.bottomAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            indexLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            indexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func resetBox() {
        box.alpha = 1
        box.transform = .identity
        box.layer.transform = CATransform3DIdentity
        box.isHidden = false
        heightConstraint.constant = 120
        view.layoutIfNeeded()
    }

    private func playCurrent() {
        let item = items[index]
        nameLabel.text = item.name
        indexLabel.text = "\(index + 1) / \(items.count)"
        resetBox()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.animator = DemoAnimator(view: self.box)
            self.animator?.play(entering: item.entering, effects: item.effects, duration: 0.6) { [weak self] in
                // 播放反向，形成完整往返
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard let self = self else { return }
                    self.animator = DemoAnimator(view: self.box)
                    self.animator?.play(entering: !item.entering, effects: item.effects, duration: 0.6) { [weak self] in
                        // 进入下一个
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            guard let self = self else { return }
                            self.index = (self.index + 1) % self.items.count
                            self.playCurrent()
                        }
                    }
                }
            }
        }
    }
}
