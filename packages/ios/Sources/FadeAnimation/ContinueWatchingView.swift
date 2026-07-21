import UIKit

/// ContinueWatchingView 的动画时长配置
public struct CWTiming {
    /// 滑入时长(秒),默认 0.45
    public var slideUpDuration: TimeInterval = 0.45
    /// 展示多久后自动收缩(秒),默认 3.0
    public var collapseDelay: TimeInterval = 3.0
    /// 详情文字淡出时长(秒),默认 0.3
    public var fadeOutDuration: TimeInterval = 0.3
    /// 横条收缩时长(秒),默认 0.4
    public var shrinkDuration: TimeInterval = 0.4
    /// 变形为小浮窗时长(秒),默认 0.55
    public var morphDuration: TimeInterval = 0.55
    public init() {}
}

/// ContinueWatchingView 生命周期回调
public protocol ContinueWatchingViewDelegate: AnyObject {
    func continueWatchingDidTapPlay(_ view: ContinueWatchingView)
    func continueWatchingDidDismiss(_ view: ContinueWatchingView)
    func continueWatchingDidCollapse(_ view: ContinueWatchingView)
}

/// ContinueWatchingView — "最近播放"浮层
///
/// 底部滑入的继续播放提示条,展示封面 + 标题 + 集数,停留数秒后自动收缩为只剩封面的
/// 小浮窗。对齐 `docs/components.html` 中 continue-watching 的 5 阶段动画序列:
/// slide-up → banner(停留) → 详情淡出 → 横条收缩 → 变形为小浮窗。
///
/// ```swift
/// let bar = ContinueWatchingView()
/// bar.configure(cover: UIImage(named: "cover"), title: "Genius Baby", subtitle: "EP.1 / EP.100")
/// bar.delegate = self
/// view.addSubview(bar)
/// bar.show()
/// ```
public class ContinueWatchingView: UIView {

    /// 动画阶段
    public enum CWPhase {
        case hidden, slidingUp, banner, fadingContent, shrinking, morphing, widget
    }

    public var timing = CWTiming()
    public weak var delegate: ContinueWatchingViewDelegate?
    public private(set) var phase: CWPhase = .hidden

    private let coverView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textStack = UIView()

    private var fullWidth: CGFloat = 0
    private var collapsedWidth: CGFloat = 0
    private var baseFrame: CGRect = .zero
    private var pendingWork: [DispatchWorkItem] = []

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor(red: 38/255.0, green: 40/255.0, blue: 46/255.0, alpha: 1)
        layer.cornerRadius = 12
        clipsToBounds = true

        coverView.backgroundColor = UIColor(red: 0x18/255.0, green: 0x6C/255.0, blue: 0xE5/255.0, alpha: 1)
        coverView.layer.cornerRadius = 6
        coverView.clipsToBounds = true
        coverView.contentMode = .scaleAspectFill
        addSubview(coverView)

        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = .systemFont(ofSize: 12)
        textStack.addSubview(titleLabel)
        textStack.addSubview(subtitleLabel)
        addSubview(textStack)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - 配置

    public func configure(cover: UIImage?, title: String, subtitle: String) {
        coverView.image = cover
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        let coverSize = h - 12
        coverView.frame = CGRect(x: 6, y: 6, width: coverSize, height: coverSize)
        let textX = coverView.frame.maxX + 10
        textStack.frame = CGRect(x: textX, y: 0, width: max(0, bounds.width - textX - 12), height: h)
        titleLabel.frame = CGRect(x: 0, y: h/2 - 18, width: textStack.bounds.width, height: 18)
        subtitleLabel.frame = CGRect(x: 0, y: h/2 + 2, width: textStack.bounds.width, height: 16)
    }

    // MARK: - 播放 5 阶段序列

    /// 触发进入 + 自动收缩序列
    public func show() {
        cancelPending()
        fullWidth = bounds.width > 0 ? bounds.width : 300
        collapsedWidth = (bounds.height > 0 ? bounds.height - 12 : 44) + 12
        baseFrame = frame

        // 初始:下移 + 透明
        phase = .slidingUp
        transform = CGAffineTransform(translationX: 0, y: 30)
        alpha = 0

        // 阶段1: slide-up
        let slide = UIViewPropertyAnimator(duration: timing.slideUpDuration,
                                           controlPoint1: CGPoint(x: 0, y: 0),
                                           controlPoint2: CGPoint(x: 0.3, y: 1)) { [weak self] in
            self?.transform = .identity
            self?.alpha = 1
        }
        slide.addCompletion { [weak self] _ in self?.phase = .banner }
        slide.startAnimation()

        // 阶段2→3: 停留后详情淡出
        schedule(after: timing.slideUpDuration + timing.collapseDelay) { [weak self] in
            guard let self = self else { return }
            self.phase = .fadingContent
            UIView.animate(withDuration: self.timing.fadeOutDuration) {
                self.textStack.alpha = 0
            } completion: { _ in
                self.shrinkAndMorph()
            }
        }
    }

    private func shrinkAndMorph() {
        // 阶段4: 横条收缩为封面宽(左对齐,封面留左)
        phase = .shrinking
        let shrink = UIViewPropertyAnimator(duration: timing.shrinkDuration,
                                            controlPoint1: CGPoint(x: 0.42, y: 0),
                                            controlPoint2: CGPoint(x: 0.58, y: 1)) { [weak self] in
            guard let self = self else { return }
            var f = self.baseFrame
            f.size.width = self.collapsedWidth
            self.frame = f
        }
        shrink.addCompletion { [weak self] _ in
            guard let self = self else { return }
            // 阶段5: 变形为小浮窗(圆角 + 阴影)
            self.phase = .morphing
            let morph = UIViewPropertyAnimator(duration: self.timing.morphDuration,
                                               controlPoint1: CGPoint(x: 0.34, y: 1.56),
                                               controlPoint2: CGPoint(x: 0.64, y: 1)) {
                self.layer.cornerRadius = 10
            }
            morph.addCompletion { _ in
                self.clipsToBounds = false
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOpacity = 0.3
                self.layer.shadowRadius = 12
                self.layer.shadowOffset = CGSize(width: 2, height: 2)
                self.phase = .widget
                self.delegate?.continueWatchingDidCollapse(self)
            }
            morph.startAnimation()
        }
        shrink.startAnimation()
    }

    // MARK: - 交互

    @objc private func handleTap() {
        if phase == .widget {
            delegate?.continueWatchingDidTapPlay(self)
        } else {
            delegate?.continueWatchingDidTapPlay(self)
        }
    }

    /// 立即关闭
    public func dismiss() {
        cancelPending()
        UIView.animate(withDuration: timing.fadeOutDuration, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 30)
        }, completion: { _ in
            self.phase = .hidden
            self.delegate?.continueWatchingDidDismiss(self)
        })
    }

    // MARK: - 调度工具

    private func schedule(after seconds: TimeInterval, _ block: @escaping () -> Void) {
        let work = DispatchWorkItem(block: block)
        pendingWork.append(work)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }

    private func cancelPending() {
        pendingWork.forEach { $0.cancel() }
        pendingWork.removeAll()
    }

    deinit { cancelPending() }
}
