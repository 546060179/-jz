import UIKit

// MARK: - 配色（对齐 components.html KINETIC UI 深色主题）

private enum K {
    static let bg = UIColor(hex: 0x151515)
    static let previewBg = UIColor(hex: 0x1C1C1C)
    static let cardInfoBg = UIColor(hex: 0x242424)
    static let primary = UIColor(hex: 0x186CE5)
    static let primaryLight = UIColor(hex: 0x6AADFF)
    static let t1 = UIColor.white
    static let t2 = UIColor.white.withAlphaComponent(0.6)
    static let t3 = UIColor.white.withAlphaComponent(0.4)
    static let badgeBg = UIColor.white.withAlphaComponent(0.1)
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

// MARK: - 数据模型（对齐 html CASES 的分类与顺序）

struct EffectItem {
    let id: String
    let cn: String
    let en: String
}

struct EffectCategory {
    let label: String
    let items: [EffectItem]
}

enum EffectCatalog {
    static let categories: [EffectCategory] = [
        EffectCategory(label: "弹窗/浮层", items: [
            EffectItem(id: "modal", cn: "Modal 弹窗", en: "Modal"),
            EffectItem(id: "toast", cn: "Toast 提示", en: "Toast"),
            EffectItem(id: "drawer", cn: "抽屉面板", en: "Drawer"),
            EffectItem(id: "actionsheet", cn: "操作面板", en: "ActionSheet"),
            EffectItem(id: "notification", cn: "通知横幅", en: "Notification"),
            EffectItem(id: "continue-watching", cn: "最近播放浮层", en: "ContinueWatching"),
            EffectItem(id: "bubble-expand", cn: "气泡展开", en: "BubbleExpand"),
            EffectItem(id: "vip-flip", cn: "VIP 翻转弹窗", en: "VipFlip"),
        ]),
        EffectCategory(label: "页面转场", items: [
            EffectItem(id: "fade-in", cn: "淡入/淡出", en: "FadeIn"),
            EffectItem(id: "blur-in", cn: "模糊进入", en: "BlurIn"),
            EffectItem(id: "flip-in", cn: "3D 翻转", en: "FlipIn"),
            EffectItem(id: "collapse", cn: "折叠展开", en: "Collapse"),
            EffectItem(id: "slide-in", cn: "滑入过渡", en: "SlideIn"),
            EffectItem(id: "bounce-in", cn: "弹性进入", en: "BounceIn"),
            EffectItem(id: "zoom-slide-in", cn: "缩放上滑", en: "ZoomSlideIn"),
            EffectItem(id: "spin-in", cn: "旋转进入", en: "SpinIn"),
        ]),
        EffectCategory(label: "操作反馈", items: [
            EffectItem(id: "press", cn: "按压反馈", en: "Press"),
            EffectItem(id: "shake", cn: "错误抖动", en: "Shake"),
            EffectItem(id: "success", cn: "成功打勾", en: "Success"),
            EffectItem(id: "pulse", cn: "脉冲提醒", en: "Pulse"),
            EffectItem(id: "ripple", cn: "涟漪扩散", en: "Ripple"),
        ]),
        EffectCategory(label: "加载状态", items: [
            EffectItem(id: "spinner", cn: "旋转加载", en: "Spinner"),
            EffectItem(id: "progress", cn: "进度条", en: "Progress"),
            EffectItem(id: "typing", cn: "打字点点", en: "TypingDots"),
            EffectItem(id: "wave", cn: "波浪条", en: "Wave"),
            EffectItem(id: "count-up", cn: "数字滚动", en: "CountUp"),
        ]),
        EffectCategory(label: "列表/编排", items: [
            EffectItem(id: "stagger", cn: "交错进入", en: "Stagger"),
            EffectItem(id: "reorder", cn: "拖拽排序", en: "Reorder"),
            EffectItem(id: "swipe-delete", cn: "滑动删除", en: "SwipeDelete"),
            EffectItem(id: "insert", cn: "插入项", en: "Insert"),
            EffectItem(id: "sequence", cn: "序列动画", en: "Sequence"),
            EffectItem(id: "marquee", cn: "跑马灯", en: "Marquee"),
        ]),
        EffectCategory(label: "强调/引导", items: [
            EffectItem(id: "float", cn: "悬浮", en: "Float"),
            EffectItem(id: "vip-shimmer", cn: "VIP 流光扫过", en: "VipShimmer"),
            EffectItem(id: "spotlight", cn: "聚光灯引导", en: "Spotlight"),
            EffectItem(id: "zoom-in", cn: "缩放进入", en: "ZoomIn"),
        ]),
        EffectCategory(label: "手势交互", items: [
            EffectItem(id: "drag-spring", cn: "拖拽回弹", en: "DragSpring"),
            EffectItem(id: "swipe-card", cn: "卡片滑动", en: "SwipeCard"),
            EffectItem(id: "pinch-zoom", cn: "捏合缩放", en: "PinchZoom"),
            EffectItem(id: "long-press", cn: "长按操作", en: "LongPress"),
        ]),
    ]
}

// MARK: - 画廊主控制器

final class MotionGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kinetic UI"
        view.backgroundColor = K.bg
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = K.bg
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(EffectCardCell.self, forCellWithReuseIdentifier: "card")
        collectionView.register(CategoryHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        view.addSubview(collectionView)
    }



    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(210)),
                subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 20, trailing: 12)
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)),
                elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            return section
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        EffectCatalog.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        EffectCatalog.categories[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! EffectCardCell
        let item = EffectCatalog.categories[indexPath.section].items[indexPath.item]
        cell.configure(item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        (collectionView.cellForItem(at: indexPath) as? EffectCardCell)?.replay()
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CategoryHeader
        let cat = EffectCatalog.categories[indexPath.section]
        header.configure(label: cat.label, count: cat.items.count)
        return header
    }
}

// MARK: - 分类标题

final class CategoryHeader: UICollectionReusableView {
    private let label = UILabel()
    private let badge = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = K.t1
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = K.t1
        badge.backgroundColor = K.badgeBg
        badge.textAlignment = .center
        badge.layer.cornerRadius = 8
        badge.layer.masksToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badge)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            badge.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            badge.centerYAnchor.constraint(equalTo: centerYAnchor),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            badge.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(label text: String, count: Int) {
        label.text = text
        badge.text = " \(count) "
    }
}

// MARK: - 卡片 Cell

final class EffectCardCell: UICollectionViewCell {
    private let previewContainer = UIView()
    private let contentHolder = UIView()
    private let infoView = UIView()
    private let cnLabel = UILabel()
    private let enLabel = UILabel()
    private var currentId: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true

        previewContainer.backgroundColor = K.previewBg
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.clipsToBounds = true
        contentView.addSubview(previewContainer)

        contentHolder.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(contentHolder)

        infoView.backgroundColor = K.cardInfoBg
        infoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoView)

        cnLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        cnLabel.textColor = .white
        cnLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(cnLabel)

        enLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        enLabel.textColor = K.t2
        enLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(enLabel)

        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewContainer.heightAnchor.constraint(equalToConstant: 140),

            contentHolder.centerXAnchor.constraint(equalTo: previewContainer.centerXAnchor),
            contentHolder.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor),
            contentHolder.widthAnchor.constraint(equalToConstant: 96),
            contentHolder.heightAnchor.constraint(equalToConstant: 60),

            infoView.topAnchor.constraint(equalTo: previewContainer.bottomAnchor),
            infoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            cnLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            cnLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 12),
            enLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            enLabel.topAnchor.constraint(equalTo: cnLabel.bottomAnchor, constant: 2),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentHolder.subviews.forEach { $0.removeFromSuperlayerAnimationsAndRemove() }
        contentHolder.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        contentHolder.transform = .identity
        contentHolder.layer.transform = CATransform3DIdentity
    }

    func configure(_ item: EffectItem) {
        currentId = item.id
        cnLabel.text = item.cn
        enLabel.text = item.en
        // 延迟到布局完成后再构建动画，保证尺寸正确
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.currentId == item.id else { return }
            self.contentHolder.subviews.forEach { $0.removeFromSuperview() }
            self.contentHolder.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            EffectPreview.play(id: item.id, in: self.contentHolder)
        }
    }

    /// 点击卡片时重新播放一次
    func replay() {
        contentHolder.subviews.forEach { $0.removeFromSuperview() }
        contentHolder.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        EffectPreview.play(id: currentId, in: contentHolder)
    }
}

private extension UIView {
    func removeFromSuperlayerAnimationsAndRemove() {
        layer.removeAllAnimations()
        removeFromSuperview()
    }
}

// 关联对象：让预览期间的 DemoAnimator 随 holder 存活（flip 的 CADisplayLink 需要强引用）
private var kDemoAnimators: UInt8 = 0
extension UIView {
    var demoAnimators: [DemoAnimator] {
        get { (objc_getAssociatedObject(self, &kDemoAnimators) as? [DemoAnimator]) ?? [] }
        set { objc_setAssociatedObject(self, &kDemoAnimators, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: - 预览动画工厂（对齐 html getCasePreviewHTML + playCardAnim）

enum EffectPreview {

    /// 在 holder（96x60，居中于卡片预览区）内构建内容并启动循环动画
    static func play(id: String, in holder: UIView) {
        let W = holder.bounds.width  > 0 ? holder.bounds.width  : 96
        let H = holder.bounds.height > 0 ? holder.bounds.height : 60
        let cx = W / 2, cy = H / 2

        holder.demoAnimators = []  // 释放上一轮预览的 animator

        func box(_ w: CGFloat, _ h: CGFloat, _ color: UIColor, _ r: CGFloat = 6) -> UIView {
            let v = UIView(frame: CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
            v.backgroundColor = color
            v.layer.cornerRadius = r
            holder.addSubview(v)
            return v
        }
        // 走真实动效库引擎（DemoAnimator → MotionAnimator），入场类效果与发布库 100% 一致
        func lib(_ view: UIView, _ effects: [MotionEffect], _ dur: TimeInterval,
                 _ timing: CAMediaTimingFunction? = nil) {
            let a = DemoAnimator(view: view)
            holder.demoAnimators.append(a)
            a.play(entering: true, effects: effects, duration: dur, timingFunction: timing)
        }
        // 连续型（旋转/跑马灯/加载点/波浪/脉冲/流光等）：无限循环，与 Web 一致
        func loopCont(_ layer: CALayer, _ anim: CAAnimation, _ key: String = "a") {
            anim.repeatCount = .infinity
            anim.isRemovedOnCompletion = false
            layer.add(anim, forKey: key)
        }
        // 只播放一次：强制单向播放并保持最终态（避免 autoreverse 来回后跳回起点）。
        // 需要"来回/回弹"的反馈类动效改用关键帧（结尾自行回到静止态）。
        func loop(_ layer: CALayer, _ anim: CAAnimation, _ key: String = "a") {
            func prep(_ a: CAAnimation) {
                a.autoreverses = false
                a.repeatCount = 1
                a.isRemovedOnCompletion = false
                a.fillMode = .both
            }
            prep(anim)
            if let g = anim as? CAAnimationGroup { g.animations?.forEach(prep) }
            layer.add(anim, forKey: key)
        }
        // 关键帧（来回/回弹型，结尾停在静止态）
        func keyframe(_ path: String, _ values: [Any], _ dur: Double,
                      _ keyTimes: [NSNumber]? = nil,
                      timing: CAMediaTimingFunctionName = .easeInEaseOut) -> CAKeyframeAnimation {
            let a = CAKeyframeAnimation(keyPath: path)
            a.values = values; a.duration = dur; a.keyTimes = keyTimes
            a.timingFunction = CAMediaTimingFunction(name: timing)
            return a
        }
        func basic(_ path: String, _ from: Any, _ to: Any, _ dur: Double,
                   autorev: Bool = true, timing: CAMediaTimingFunctionName = .easeInEaseOut) -> CABasicAnimation {
            let a = CABasicAnimation(keyPath: path)
            a.fromValue = from; a.toValue = to; a.duration = dur
            a.autoreverses = autorev
            a.timingFunction = CAMediaTimingFunction(name: timing)
            return a
        }

        switch id {

        // ---------- 弹窗/浮层 ----------
        case "modal":
            let v = box(64, 44, UIColor.white.withAlphaComponent(0.08), 8)
            v.layer.borderWidth = 1; v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            let bar = UIView(frame: CGRect(x: 16, y: 20, width: 32, height: 5)); bar.backgroundColor = K.primary
            bar.layer.cornerRadius = 2.5; v.addSubview(bar)
            lib(v, [.fade(from: 0, to: 1), .scale(from: 0.4, to: 1)], 0.7)

        case "toast":
            let pill = UIView(frame: CGRect(x: cx-32, y: cy-11, width: 64, height: 22))
            pill.backgroundColor = UIColor.white.withAlphaComponent(0.12); pill.layer.cornerRadius = 6
            let lb = UILabel(frame: pill.bounds); lb.text = "操作成功"; lb.textColor = .white
            lb.font = .systemFont(ofSize: 9); lb.textAlignment = .center; pill.addSubview(lb)
            holder.addSubview(pill)
            lib(pill, [.fade(from: 0, to: 1), .slide(direction: .up, distance: 20)], 0.6)

        case "drawer":
            let wrap = UIView(frame: CGRect(x: cx-32, y: cy-22, width: 64, height: 44))
            wrap.layer.cornerRadius = 6; wrap.clipsToBounds = true
            wrap.layer.borderWidth = 1; wrap.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            let panel = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 44)); panel.backgroundColor = K.primary
            let rest = UIView(frame: CGRect(x: 22, y: 0, width: 42, height: 44)); rest.backgroundColor = UIColor.white.withAlphaComponent(0.04)
            wrap.addSubview(rest); wrap.addSubview(panel); holder.addSubview(wrap)
            // web: 整个抽屉框 translateX(-24)→0 + 淡入, 0.6s（不是只动里面的面板）
            lib(wrap, [.fade(from: 0, to: 1), .slide(direction: .right, distance: 24)], 0.6)

        case "actionsheet":
            // web: 整块 translateY(24)→0 + 淡入, 0.6s（三条同时，不错开）
            let sheet = UIView(frame: CGRect(x: cx-28, y: cy-13, width: 56, height: 26))
            for i in 0..<3 {
                let b = UIView(frame: CGRect(x: 0, y: CGFloat(i)*9, width: 56, height: 8))
                b.backgroundColor = K.primary.withAlphaComponent(i == 0 ? 1 : (i == 1 ? 0.6 : 0.3))
                b.layer.cornerRadius = 2; sheet.addSubview(b)
            }
            holder.addSubview(sheet)
            lib(sheet, [.fade(from: 0, to: 1), .slide(direction: .up, distance: 24)], 0.6)

        case "notification":
            let card = UIView(frame: CGRect(x: cx-32, y: cy-16, width: 64, height: 32))
            card.backgroundColor = UIColor.white.withAlphaComponent(0.06); card.layer.cornerRadius = 6
            let l1 = UIView(frame: CGRect(x: 8, y: 8, width: 48, height: 5)); l1.backgroundColor = K.primary; l1.layer.cornerRadius = 2
            let l2 = UIView(frame: CGRect(x: 8, y: 18, width: 28, height: 4)); l2.backgroundColor = UIColor.white.withAlphaComponent(0.1); l2.layer.cornerRadius = 2
            card.addSubview(l1); card.addSubview(l2); holder.addSubview(card)
            lib(card, [.fade(from: 0, to: 1), .slide(direction: .down, distance: 20)], 0.5)

        case "continue-watching":
            // web: slide-up(450) → hold(1s) → 详情淡出(300) → 收缩成小封面浮窗(500)
            let pill = UIView(frame: CGRect(x: cx-36, y: cy-11, width: 72, height: 22))
            pill.backgroundColor = UIColor.white.withAlphaComponent(0.08); pill.layer.cornerRadius = 10
            pill.layer.masksToBounds = true
            let cover = UIView(frame: CGRect(x: 3, y: 3, width: 16, height: 16)); cover.backgroundColor = K.primary; cover.layer.cornerRadius = 3
            let ln1 = UIView(frame: CGRect(x: 24, y: 5, width: 34, height: 5)); ln1.backgroundColor = UIColor.white.withAlphaComponent(0.85); ln1.layer.cornerRadius = 2
            let ln2 = UIView(frame: CGRect(x: 24, y: 13, width: 24, height: 4)); ln2.backgroundColor = UIColor.white.withAlphaComponent(0.4); ln2.layer.cornerRadius = 2
            pill.addSubview(cover); pill.addSubview(ln1); pill.addSubview(ln2); holder.addSubview(pill)
            // 左对齐锚点，宽度向左收缩（封面留在左侧）
            pill.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            pill.layer.position = CGPoint(x: cx-36, y: cy)
            let cwNow = CACurrentMediaTime()
            // 1) 上滑淡入 450ms
            let slide = CAAnimationGroup(); slide.duration = 0.45; slide.beginTime = cwNow
            slide.animations = [basic("transform.translation.y", 30, 0, 0.45, autorev: false, timing: .easeOut),
                                basic("opacity", 0, 1, 0.45, autorev: false)]
            slide.fillMode = .both; slide.isRemovedOnCompletion = false
            pill.layer.add(slide, forKey: "cwSlide")
            // 3) 详情淡出（begin 1.25s，300ms）
            for (idx, line) in [ln1, ln2].enumerated() {
                let f = basic("opacity", 1, 0, 0.3, autorev: false)
                f.beginTime = cwNow + 1.25; f.fillMode = .both; f.isRemovedOnCompletion = false
                line.layer.add(f, forKey: "cwFade\(idx)")
            }
            // 4) 收缩宽度 + 圆角 + 背景淡出（begin 1.55s，500ms）
            let shrinkW = basic("bounds.size.width", 72, 22, 0.5, autorev: false); shrinkW.beginTime = cwNow + 1.55
            shrinkW.fillMode = .both; shrinkW.isRemovedOnCompletion = false
            let shrinkR = basic("cornerRadius", 10, 6, 0.5, autorev: false); shrinkR.beginTime = cwNow + 1.55
            shrinkR.fillMode = .both; shrinkR.isRemovedOnCompletion = false
            let bgFade = basic("backgroundColor", UIColor.white.withAlphaComponent(0.08).cgColor, UIColor.clear.cgColor, 0.5, autorev: false)
            bgFade.beginTime = cwNow + 1.55; bgFade.fillMode = .both; bgFade.isRemovedOnCompletion = false
            pill.layer.add(shrinkW, forKey: "cwW"); pill.layer.add(shrinkR, forKey: "cwR"); pill.layer.add(bgFade, forKey: "cwBg")

        case "bubble-expand":
            // web: 右对齐、宽度 20→64 向左弹性展开（阻尼谐振子 ζ=0.5 ω=9.0，650ms），文字在后 30% 淡入
            let startW: CGFloat = 20, endW: CGFloat = 64
            let rightEdge = cx + 32
            let bubble = UIView(frame: CGRect(x: rightEdge - startW, y: cy-11, width: startW, height: 22))
            bubble.backgroundColor = K.primary; bubble.layer.cornerRadius = 8; bubble.clipsToBounds = true
            let lb = UILabel(); lb.text = "限时免费"; lb.font = .boldSystemFont(ofSize: 8)
            lb.textColor = .white; lb.textAlignment = .center; lb.alpha = 0; bubble.addSubview(lb)
            holder.addSubview(bubble)
            startBubbleExpand(bubble: bubble, label: lb, rightEdge: rightEdge, startW: startW, endW: endW)

        case "vip-flip":
            // web: rotateX(90deg) scale(0.85) opacity0 → rotateX(0) scale(1) opacity1, 0.7s cubic-bezier(.4,.14,.3,1)
            let v = box(52, 38, K.primary, 6)
            let lb = UILabel(frame: v.bounds); lb.text = "VIP"; lb.textColor = .white
            lb.font = .boldSystemFont(ofSize: 12); lb.textAlignment = .center; v.addSubview(lb)
            func persp(_ deg: CGFloat, _ axisX: Bool, _ s: CGFloat) -> CATransform3D {
                var p = CATransform3DIdentity; p.m34 = -1.0/200
                let r = CATransform3DRotate(p, deg * .pi/180, axisX ? 1:0, axisX ? 0:1, 0)
                return CATransform3DScale(r, s, s, 1)
            }
            let tr = CAKeyframeAnimation(keyPath: "transform")
            tr.values = [persp(90, true, 0.85), persp(0, true, 1)]; tr.keyTimes = [0, 1]; tr.duration = 0.7
            tr.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1)
            let g = CAAnimationGroup(); g.duration = 0.7
            g.animations = [tr, basic("opacity", 0, 1, 0.7, autorev: false)]
            loop(v.layer, g)

        // ---------- 页面转场 ----------
        case "fade-in":
            let v = box(48, 32, K.primary, 6)
            lib(v, [.fade(from: 0, to: 1)], 0.8)

        case "blur-in":
            // web: blur(12px) opacity .6 → blur(0) opacity 1 —— 保持可见、突出"由糊变清"，区别于纯淡入
            // 纯色块无法体现模糊，需内部细节（对齐 web 的图标），且时长拉长让磨砂消散可见
            let v = box(46, 30, K.primary, 4)
            let icon = UIImageView(image: UIImage(systemName: "photo"))
            icon.tintColor = .white; icon.contentMode = .scaleAspectFit
            icon.frame = CGRect(x: v.bounds.midX - 10, y: v.bounds.midY - 8, width: 20, height: 16)
            v.addSubview(icon)
            lib(v, [.fade(from: 0.6, to: 1), .blur(from: 14, to: 0)], 1.2)

        case "flip-in":
            // 库 flipYIn：rotateY 90°→0° + 淡入（真实 MotionAnimator 引擎）
            let v = box(40, 28, K.primary, 4)
            lib(v, [.fade(from: 0, to: 1), .flip(axis: .y, from: 90, to: 0, perspective: 200)], 0.9)

        case "collapse":
            // web: 整块 scaleY(0)→scaleY(1) + opacity, 0.7s ease（从顶部展开停住）
            let stack = UIView(frame: CGRect(x: cx-24, y: cy-13, width: 48, height: 26))
            let chs: [CGFloat] = [6, 10, 6]
            var cy0: CGFloat = 0
            for i in 0..<3 {
                let b = UIView(frame: CGRect(x: 0, y: cy0, width: 48, height: chs[i]))
                b.backgroundColor = K.primary.withAlphaComponent(i == 1 ? 0.4 : 1); b.layer.cornerRadius = 2
                stack.addSubview(b); cy0 += chs[i] + 2
            }
            stack.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            stack.layer.position = CGPoint(x: cx, y: cy-13)
            holder.addSubview(stack)
            let gc = CAAnimationGroup(); gc.duration = 0.7
            gc.animations = [basic("transform.scale.y", 0.0, 1, 0.7, autorev: false),
                             basic("opacity", 0, 1, 0.7, autorev: false)]
            loop(stack.layer, gc)

        case "slide-in":
            // web: translateX(20)→0 + 淡入。库 slide .left 的初始位移即 +distance
            let v = box(48, 32, K.primary, 6)
            lib(v, [.fade(from: 0, to: 1), .slide(direction: .left, distance: 20)], 0.5)

        case "bounce-in":
            // 库预设 bounce-in：scale 0.3→1 + 淡入，配 bounce 缓动过冲弹入
            let v = box(44, 32, K.primary, 6)
            lib(v, [.fade(from: 0, to: 1), .scale(from: 0.3, to: 1)], 0.6, EasingCurves.bounce)

        case "zoom-slide-in":
            // 库预设 zoom-slide-in：scale 0.9→1 + 上滑 32 + 淡入（卡片从下方滑近放大）
            let v = box(48, 32, K.primary, 6)
            lib(v, [.fade(from: 0, to: 1), .scale(from: 0.9, to: 1), .slide(direction: .up, distance: 32)], 0.6)

        case "spin-in":
            // 库预设 spin-in：rotate -180→0 + 淡入（趣味旋入）
            let v = box(36, 36, K.primary, 8)
            lib(v, [.fade(from: 0, to: 1), .rotate(from: -180, to: 0)], 0.7, EasingCurves.expressive)

        // ---------- 操作反馈 ----------
        case "press":
            let v = box(56, 30, K.primary, 8)
            let lb = UILabel(frame: v.bounds); lb.text = "按钮"; lb.textColor = .white; lb.font = .boldSystemFont(ofSize: 11); lb.textAlignment = .center; v.addSubview(lb)
            // web: scale 1→0.8（按下 0.2s）→ 1（回弹 0.5s）
            loop(v.layer, keyframe("transform.scale", [1, 0.8, 1], 0.7, [0, 0.28, 1]))

        case "shake":
            // web: cShake 0.6s ease 跑 3 次 —— X 0→-4(25%)→4(75%)→0
            let v = box(56, 28, .clear, 6); v.layer.borderWidth = 1.5; v.layer.borderColor = K.primary.cgColor
            let a = CAKeyframeAnimation(keyPath: "transform.translation.x")
            a.values = [0, -4, 4, 0]; a.keyTimes = [0, 0.25, 0.75, 1]; a.duration = 0.6
            a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            a.repeatCount = 3; a.isRemovedOnCompletion = false; a.fillMode = .both
            v.layer.add(a, forKey: "shake")

        case "success":
            let c = UIView(frame: CGRect(x: cx-21, y: cy-21, width: 42, height: 42))
            c.backgroundColor = K.primary.withAlphaComponent(0.1); c.layer.cornerRadius = 21
            c.layer.borderWidth = 2; c.layer.borderColor = K.primary.cgColor
            let lb = UILabel(frame: c.bounds); lb.text = "✓"; lb.textColor = K.primary; lb.font = .boldSystemFont(ofSize: 20); lb.textAlignment = .center; c.addSubview(lb)
            holder.addSubview(c)
            // 库 scaleFadeIn：scale 0→1 + 淡入（真实引擎）
            lib(c, [.fade(from: 0, to: 1), .scale(from: 0, to: 1)], 0.7)

        case "pulse":
            let dot = UIView(frame: CGRect(x: cx-8, y: cy-8, width: 16, height: 16)); dot.backgroundColor = K.primary; dot.layer.cornerRadius = 8
            holder.addSubview(dot)
            let ring = CALayer(); ring.frame = dot.frame; ring.cornerRadius = 8; ring.borderWidth = 2; ring.borderColor = K.primary.cgColor
            holder.layer.insertSublayer(ring, below: dot.layer)
            // web: 圆点 scale 1→1.15→1 + 外圈 box-shadow 0→8px 扩散淡出, 1.2s 无限
            let g = CAAnimationGroup(); g.duration = 1.2; g.animations = [
                basic("transform.scale", 1, 2.2, 1.2, autorev: false), basic("opacity", 0.7, 0, 1.2, autorev: false)]
            loopCont(ring, g)
            loopCont(dot.layer, keyframe("transform.scale", [1, 1.15, 1], 1.2, [0, 0.5, 1]))

        case "ripple":
            let btn = box(40, 28, K.primary, 6)
            let lb = UILabel(frame: btn.bounds); lb.text = "点击"; lb.font = .systemFont(ofSize: 9); lb.textColor = .white; lb.textAlignment = .center; btn.addSubview(lb)
            let r = CALayer(); r.frame = CGRect(x: btn.bounds.midX-2, y: btn.bounds.midY-2, width: 4, height: 4)
            r.cornerRadius = 2; r.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor; btn.layer.addSublayer(r)
            let g = CAAnimationGroup(); g.duration = 1.2; g.animations = [
                basic("transform.scale", 1, 12, 1.2, autorev: false), basic("opacity", 0.6, 0, 1.2, autorev: false)]
            loopCont(r, g)

        // ---------- 加载状态 ----------
        case "spinner":
            let ring = CAShapeLayer(); let sz: CGFloat = 28
            ring.frame = CGRect(x: cx-sz/2, y: cy-sz/2, width: sz, height: sz)
            ring.path = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: sz-4, height: sz-4)).cgPath
            ring.fillColor = UIColor.clear.cgColor; ring.lineWidth = 3
            ring.strokeColor = K.primary.cgColor; ring.strokeStart = 0; ring.strokeEnd = 0.75
            holder.layer.addSublayer(ring)
            // web: cSpin 1.2s linear infinite
            let a = basic("transform.rotation", 0, CGFloat.pi*2, 1.2, autorev: false, timing: .linear)
            loopCont(ring, a)

        case "progress":
            let track = UIView(frame: CGRect(x: cx-26, y: cy-3, width: 52, height: 6)); track.backgroundColor = UIColor.white.withAlphaComponent(0.15); track.layer.cornerRadius = 3; track.clipsToBounds = true
            let fill = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 6)); fill.backgroundColor = K.primary; fill.layer.cornerRadius = 3
            fill.layer.anchorPoint = CGPoint(x: 0, y: 0.5); fill.layer.position = CGPoint(x: 0, y: 3)
            track.addSubview(fill); holder.addSubview(track)
            // web: width 0→100%, 2s ease（scale.x 等效，进度到满停住）
            let a = basic("transform.scale.x", 0, 1, 2.0, autorev: false, timing: .easeInEaseOut)
            loop(fill.layer, a)

        case "typing":
            // web: 每点 cPulse 1s ease-in-out infinite，延迟 i*0.2s —— scale 1→.88→1, opacity 1→.5→1
            for i in 0..<3 {
                let d = UIView(frame: CGRect(x: cx-16 + CGFloat(i)*12, y: cy-4, width: 8, height: 8)); d.backgroundColor = K.primary; d.layer.cornerRadius = 4
                holder.addSubview(d)
                let g = CAAnimationGroup(); g.duration = 1.0; g.beginTime = CACurrentMediaTime() + Double(i)*0.2
                g.animations = [keyframe("transform.scale", [1, 0.88, 1], 1.0, [0,0.5,1]),
                                keyframe("opacity", [1, 0.5, 1], 1.0, [0,0.5,1])]
                loopCont(d.layer, g)
            }

        case "wave":
            // web: scaleY 关键帧 [h1,1,h2,0.9,h1]，heights=[0.4,1,0.3,0.85,0.55]，时长 300+i*40+400，延迟 i*80
            let heights: [CGFloat] = [0.4, 1, 0.3, 0.85, 0.55]
            let barH: CGFloat = 22
            for i in 0..<5 {
                let b = UIView(frame: CGRect(x: cx-11 + CGFloat(i)*5, y: cy - barH/2, width: 3, height: barH)); b.backgroundColor = K.primary; b.layer.cornerRadius = 1.5
                b.layer.anchorPoint = CGPoint(x: 0.5, y: 1); b.layer.position = CGPoint(x: b.layer.position.x, y: cy + barH/2)
                holder.addSubview(b)
                let h1 = heights[i], h2 = heights[(i+2)%5]
                let a = keyframe("transform.scale.y", [h1, 1, h2, 0.9, h1], Double(700 + i*40)/1000.0, [0, 0.25, 0.5, 0.75, 1])
                a.beginTime = CACurrentMediaTime() + Double(i)*0.08
                loopCont(b.layer, a)
            }

        case "count-up":
            let lb = UILabel(frame: CGRect(x: cx-40, y: cy-14, width: 80, height: 28)); lb.textAlignment = .center
            lb.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold); lb.textColor = K.primaryLight; lb.text = "0"
            holder.addSubview(lb)
            startCountUp(label: lb, target: 8642)

        // ---------- 列表/编排 ----------
        case "stagger":
            let ws: [CGFloat] = [44, 36, 28]
            for i in 0..<3 {
                let b = UIView(frame: CGRect(x: cx-22, y: cy-11 + CGFloat(i)*8, width: ws[i], height: 6)); b.backgroundColor = K.primary.withAlphaComponent(i==0 ?1:(i==1 ?0.6:0.3)); b.layer.cornerRadius = 3
                holder.addSubview(b)
                // web: 每条 translateY(12)→0 + 淡入 0.5s，延迟 i*0.1s
                let g = CAAnimationGroup(); g.duration = 1.8; g.beginTime = CACurrentMediaTime() + Double(i)*0.1
                g.animations = [basic("transform.translation.y", 12, 0, 0.5, autorev: false, timing: .easeOut), basic("opacity", 0, 1, 0.5, autorev: false)]
                loop(b.layer, g)
            }

        case "reorder":
            for i in 0..<3 {
                let b = UIView(frame: CGRect(x: cx-22, y: cy-11 + CGFloat(i)*8, width: 44, height: 7)); b.backgroundColor = i==1 ? K.primaryLight : K.primary.withAlphaComponent(i==2 ?0.5:1); b.layer.cornerRadius = 3
                holder.addSubview(b)
                // web: cBounce（上跳 -6）跑 2 次
                if i == 1 { loop(b.layer, keyframe("transform.translation.y", [0, -6, 0, -6, 0], 1.6, [0, 0.25, 0.5, 0.75, 1])) }
            }

        case "swipe-delete":
            let row = UIView(frame: CGRect(x: cx-28, y: cy-12, width: 56, height: 24)); row.layer.cornerRadius = 4; row.clipsToBounds = true
            let red = UIView(frame: CGRect(x: 56, y: 0, width: 24, height: 24)); red.backgroundColor = UIColor(hex: 0xFF4D4F)
            let front = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 24)); front.backgroundColor = K.primary; front.layer.cornerRadius = 4
            row.addSubview(red); row.addSubview(front); holder.addSubview(row)
            // web: translateX 0→-20, 0.7s ease（停在 -20）
            loop(front.layer, basic("transform.translation.x", 0, -20, 0.7, autorev: false, timing: .easeInEaseOut))

        case "insert":
            for i in 0..<3 {
                let dashed = (i == 1)
                let b = UIView(frame: CGRect(x: cx-22, y: cy-12 + CGFloat(i)*8, width: 44, height: dashed ?8:6))
                b.layer.cornerRadius = 3
                if dashed { b.layer.borderWidth = 1.5; b.layer.borderColor = K.primary.withAlphaComponent(0.5).cgColor } else { b.backgroundColor = K.primary }
                holder.addSubview(b)
                if dashed {
                    lib(b, [.fade(from: 0, to: 1), .scale(from: 0.5, to: 1)], 0.6)
                }
            }

        case "sequence":
            // web: d0 淡入(0.3s) → d1 cSeqPop 过冲(scale .3→1.1→1, 0.8s 延迟0.3) → d2 淡入(0.6s 延迟1.2)
            let a1 = UIView(frame: CGRect(x: cx-22, y: cy-14, width: 44, height: 6)); a1.backgroundColor = UIColor.white.withAlphaComponent(0.1); a1.layer.cornerRadius = 3; a1.alpha = 0; holder.addSubview(a1)
            let a2 = UIView(frame: CGRect(x: cx-22, y: cy-5, width: 44, height: 14)); a2.backgroundColor = K.primary; a2.layer.cornerRadius = 4; a2.alpha = 0; holder.addSubview(a2)
            let a3 = UIView(frame: CGRect(x: cx-22, y: cy+12, width: 20, height: 6)); a3.backgroundColor = K.primary; a3.layer.cornerRadius = 3; a3.alpha = 0; holder.addSubview(a3)
            let sqNow = CACurrentMediaTime()
            let f0 = basic("opacity", 0, 1, 0.3, autorev: false); f0.beginTime = sqNow; f0.fillMode = .both; f0.isRemovedOnCompletion = false
            a1.layer.add(f0, forKey: "s0")
            let pop = CAAnimationGroup(); pop.duration = 0.8; pop.beginTime = sqNow + 0.3; pop.fillMode = .both; pop.isRemovedOnCompletion = false
            pop.animations = [keyframe("transform.scale", [0.3, 1.1, 1], 0.8, [0, 0.6, 1]),
                              keyframe("opacity", [0, 1, 1], 0.8, [0, 0.6, 1])]
            a2.layer.add(pop, forKey: "s1")
            let f2 = basic("opacity", 0, 1, 0.6, autorev: false); f2.beginTime = sqNow + 1.2; f2.fillMode = .both; f2.isRemovedOnCompletion = false
            a3.layer.add(f2, forKey: "s2")

        case "marquee":
            let strip = UIView(frame: CGRect(x: cx-26, y: cy-8, width: 52, height: 16)); strip.clipsToBounds = true; holder.addSubview(strip)
            let inner = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 16)); strip.addSubview(inner)
            for i in 0..<5 { let s = UIView(frame: CGRect(x: CGFloat(i)*20, y: 0, width: 16, height: 16)); s.backgroundColor = K.primary.withAlphaComponent(i%2==0 ?1:0.6); s.layer.cornerRadius = 3; inner.addSubview(s) }
            // web: cMarquee 2.5s linear infinite（位移 40）
            loopCont(inner.layer, basic("transform.translation.x", 0, -40, 2.5, autorev: false, timing: .linear))

        // ---------- 强调/引导 ----------
        case "float":
            let c = UIView(frame: CGRect(x: cx-18, y: cy-18, width: 36, height: 36)); c.backgroundColor = K.primary; c.layer.cornerRadius = 18
            holder.addSubview(c)
            // web: cFloat 2s ease-in-out infinite —— Y 0→-5→0
            loopCont(c.layer, keyframe("transform.translation.y", [0, -5, 0], 2.0, [0, 0.5, 1]))

        case "vip-shimmer":
            let card = UIView(frame: CGRect(x: cx-40, y: cy-18, width: 80, height: 36)); card.backgroundColor = UIColor(hex: 0x132D5E); card.layer.cornerRadius = 6; card.clipsToBounds = true
            card.layer.borderWidth = 1; card.layer.borderColor = K.primary.withAlphaComponent(0.3).cgColor
            let lb = UILabel(frame: card.bounds); lb.text = "VIP"; lb.textColor = K.primaryLight; lb.font = .boldSystemFont(ofSize: 12); lb.textAlignment = .center; card.addSubview(lb)
            // web: cShimmerSweep 3s ease-in-out infinite —— 斜光带 rotate(-25°) 从左外扫到右外
            let sweep = CAGradientLayer(); sweep.frame = CGRect(x: 0, y: -10, width: 28, height: 56)
            sweep.startPoint = CGPoint(x: 0, y: 0.5); sweep.endPoint = CGPoint(x: 1, y: 0.5)
            sweep.colors = [UIColor.clear.cgColor, K.primaryLight.withAlphaComponent(0.35).cgColor, UIColor.clear.cgColor]
            sweep.transform = CATransform3DMakeRotation(-25 * .pi/180, 0, 0, 1)
            card.layer.addSublayer(sweep); holder.addSubview(card)
            let a = basic("position.x", -20, 100, 3.0, autorev: false, timing: .easeInEaseOut)
            loopCont(sweep, a)

        case "spotlight":
            let ring = CALayer(); ring.frame = CGRect(x: cx-18, y: cy-18, width: 36, height: 36); ring.cornerRadius = 18
            ring.backgroundColor = K.primary.withAlphaComponent(0.18).cgColor; holder.layer.addSublayer(ring)
            let tip = box(40, 20, K.primary, 4); let lb = UILabel(frame: tip.bounds); lb.text = "发布"; lb.font = .systemFont(ofSize: 9); lb.textColor = .white; lb.textAlignment = .center; tip.addSubview(lb)
            // web: cPulse 2s ease-in-out infinite — scale 1→.88→1, opacity 1→.5→1（连续脉冲）
            func pulse() -> CAAnimationGroup {
                let g = CAAnimationGroup(); g.duration = 2.0
                g.animations = [keyframe("transform.scale", [1, 0.88, 1], 2.0, [0,0.5,1]),
                                keyframe("opacity", [1, 0.5, 1], 2.0, [0,0.5,1])]
                return g
            }
            loopCont(ring, pulse())
            loopCont(tip.layer, pulse())

        case "zoom-in":
            let v = box(40, 40, K.primary, 6)
            lib(v, [.fade(from: 0, to: 1), .scale(from: 0.5, to: 1)], 0.6)

        // ---------- 手势交互 ----------
        case "drag-spring":
            let v = box(36, 36, K.primary, 8)
            loop(v.layer, keyframe("transform.translation.x", [0, 20, -10, 5, 0], 1.0, [0, 0.3, 0.6, 0.82, 1]))

        case "swipe-card":
            let back = UIView(frame: CGRect(x: cx-14, y: cy-20, width: 32, height: 40)); back.backgroundColor = UIColor.white.withAlphaComponent(0.12); back.layer.cornerRadius = 6; holder.addSubview(back)
            let front = UIView(frame: CGRect(x: cx-18, y: cy-20, width: 32, height: 40)); front.backgroundColor = K.primary; front.layer.cornerRadius = 6; holder.addSubview(front)
            let a = CAKeyframeAnimation(keyPath: "transform")
            let t0 = CATransform3DIdentity
            let t1 = CATransform3DRotate(CATransform3DMakeTranslation(24, 0, 0), 0.14, 0, 0, 1)
            a.values = [t0, t1, t0]; a.keyTimes = [0, 0.55, 1]; a.duration = 1.6
            loop(front.layer, a)

        case "pinch-zoom":
            // web: scale(0.4)→scale(1), 0.7s cubic-bezier(.4,.14,.3,1)（放大后停在 1）
            let v = box(36, 36, K.primary, 6)
            let a = CABasicAnimation(keyPath: "transform.scale")
            a.fromValue = 0.4; a.toValue = 1; a.duration = 0.7; a.autoreverses = false
            a.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.14, 0.3, 1)
            loop(v.layer, a)

        case "long-press":
            let v = box(36, 36, K.primary, 8); holder.addSubview(v)
            let ring = CALayer(); ring.frame = CGRect(x: cx-23, y: cy-23, width: 46, height: 46); ring.cornerRadius = 12; ring.borderWidth = 2; ring.borderColor = K.primary.withAlphaComponent(0.3).cgColor
            holder.layer.insertSublayer(ring, below: v.layer)
            // web: scale(1)→scale(1.15), 0.8s ease（放大后停在 1.15）
            loop(v.layer, basic("transform.scale", 1, 1.15, 0.8, autorev: false))

        default:
            let v = box(40, 28, K.primary, 6)
            loop(v.layer, basic("opacity", 0.4, 1, 0.8, autorev: true))
        }
    }

    /// 气泡展开：复刻 web springBounce（阻尼谐振子），右对齐向左展开 + 文字后 30% 淡入
    private static func startBubbleExpand(bubble: UIView, label: UILabel, rightEdge: CGFloat,
                                          startW: CGFloat, endW: CGFloat) {
        let dur = 0.65
        var t0: CFTimeInterval = 0
        let y = bubble.frame.origin.y, h = bubble.frame.height
        weak var weakBubble = bubble
        func spring(_ t: Double) -> Double {
            if t <= 0 { return 0 }; if t >= 1 { return 1 }
            let z = 0.5, w = 9.0
            let wd = w * (1 - z*z).squareRoot()
            let env = exp(-z*w*t)
            return 1 - env * (cos(wd*t) + (z/(1-z*z).squareRoot()) * sin(wd*t))
        }
        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            guard let b = weakBubble, b.superview != nil else { timer.invalidate(); return }
            if t0 == 0 { t0 = CACurrentMediaTime() }
            let p = min((CACurrentMediaTime() - t0) / dur, 1)
            let s = CGFloat(spring(p))
            let w = max(startW, startW + (endW - startW) * s)
            b.frame = CGRect(x: rightEdge - w, y: y, width: w, height: h)   // 右边固定，向左展开
            label.frame = CGRect(x: w - 58, y: 0, width: 54, height: h)     // 文字贴右侧
            if p > 0.7 { label.alpha = CGFloat(min((p - 0.7) / 0.3, 1)) }
            if p >= 1 { b.frame = CGRect(x: rightEdge - endW, y: y, width: endW, height: h); label.alpha = 1; timer.invalidate() }
        }
    }

    /// 数字滚动（Timer 驱动，label 移除后自动停止）
    private static func startCountUp(label: UILabel, target: Int) {
        let start = CACurrentMediaTime()
        let dur = 1.5
        Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak label] timer in
            guard let lb = label, lb.superview != nil else { timer.invalidate(); return }
            let t = (CACurrentMediaTime() - start) / dur
            let e = 1 - pow(1 - min(t, 1), 3)   // easeOutCubic，滚一次停住
            lb.text = NumberFormatter.localizedString(from: NSNumber(value: Int(Double(target) * e)), number: .decimal)
            if t >= 1 { lb.text = NumberFormatter.localizedString(from: NSNumber(value: target), number: .decimal); timer.invalidate() }
        }
    }
}
