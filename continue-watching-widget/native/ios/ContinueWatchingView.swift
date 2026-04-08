import UIKit

// MARK: - Animation Timing
struct CWTiming {
    var slideUpDuration: TimeInterval = 0.45
    var collapseDelay: TimeInterval = 3.0
    var fadeOutDuration: TimeInterval = 0.3
    var shrinkDuration: TimeInterval = 0.4
    var morphDuration: TimeInterval = 0.55
    var dismissDuration: TimeInterval = 0.3
}

// MARK: - Animation Phase
enum CWPhase {
    case hidden, slidingUp, banner, fadingContent, shrinking, morphing, widget, dismissing
}

// MARK: - Easing Functions
private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    a + (b - a) * t
}
private func easeOutCubic(_ t: CGFloat) -> CGFloat {
    1 - pow(1 - t, 3)
}
private func easeInOutCubic(_ t: CGFloat) -> CGFloat {
    t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
}
private func easeOutBack(_ t: CGFloat) -> CGFloat {
    let c1: CGFloat = 1.70158
    let c3 = c1 + 1
    return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2)
}

// MARK: - Delegate
protocol ContinueWatchingDelegate: AnyObject {
    func continueWatchingDidShow()
    func continueWatchingDidCollapse()
    func continueWatchingDidDismiss()
    func continueWatchingDidTapPlay()
}

extension ContinueWatchingDelegate {
    func continueWatchingDidShow() {}
    func continueWatchingDidCollapse() {}
    func continueWatchingDidDismiss() {}
    func continueWatchingDidTapPlay() {}
}

// MARK: - ContinueWatchingView
class ContinueWatchingView: UIView {

    // MARK: Config
    var timing = CWTiming()
    var coverSize = CGSize(width: 44.35, height: 60)
    var widgetSize = CGSize(width: 90, height: 120)
    /// Widget position relative to parent's bottom-left
    var widgetOffset = CGPoint(x: 0, y: 91)
    /// Bottom inset (e.g. tab bar height)
    var bottomInset: CGFloat = 83

    weak var delegate: ContinueWatchingDelegate?

    // MARK: State
    private(set) var phase: CWPhase = .hidden

    // MARK: Subviews
    private let bannerContainer = UIView()
    private let coverImageView = UIImageView()
    private let infoStack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let playButton = UIButton(type: .custom)
    private let closeButton = UIButton(type: .custom)
    private let widgetPlayButton = UIButton(type: .custom)
    private let widgetCloseButton = UIButton(type: .custom)

    // MARK: Animation
    private var displayLink: CADisplayLink?
    private var animPhase: String = ""
    private var phaseStartTime: CFTimeInterval = 0
    private var collapseTimer: Timer?

    // MARK: Computed
    private var bannerHeight: CGFloat { coverSize.height + 8 }
    private var collapsedWidth: CGFloat { coverSize.width + 8 }
    private var collapsedHeight: CGFloat { coverSize.height + 8 }
    private var parentWidth: CGFloat { superview?.bounds.width ?? 375 }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        isUserInteractionEnabled = false
        clipsToBounds = false

        // Banner container
        bannerContainer.backgroundColor = UIColor(red: 38/255, green: 40/255, blue: 46/255, alpha: 1)
        bannerContainer.layer.cornerRadius = 8
        bannerContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bannerContainer.clipsToBounds = true
        bannerContainer.isHidden = true
        addSubview(bannerContainer)

        // Cover
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        bannerContainer.addSubview(coverImageView)

        // Info stack
        infoStack.axis = .vertical
        infoStack.spacing = 2
        bannerContainer.addSubview(infoStack)

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.lineBreakMode = .byTruncatingTail
        infoStack.addArrangedSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 159/255, green: 159/255, blue: 162/255, alpha: 1)
        infoStack.addArrangedSubview(subtitleLabel)

        // Play button (orange circle)
        playButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)
        bannerContainer.addSubview(playButton)

        // Close button (X)
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        bannerContainer.addSubview(closeButton)

        // Widget play button
        widgetPlayButton.alpha = 0
        widgetPlayButton.isHidden = true
        widgetPlayButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)
        bannerContainer.addSubview(widgetPlayButton)

        // Widget close button
        widgetCloseButton.alpha = 0
        widgetCloseButton.isHidden = true
        widgetCloseButton.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        bannerContainer.addSubview(widgetCloseButton)

        // Draw button images
        drawPlayButton()
        drawCloseButton()
        drawWidgetButtons()
    }

    // MARK: - Configure
    func configure(cover: UIImage?, title: String, subtitle: String? = nil) {
        coverImageView.image = cover
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }

    // MARK: - Layout (banner state)
    private func layoutBanner() {
        let w = parentWidth
        let h = bannerHeight
        bannerContainer.frame = CGRect(
            x: 0,
            y: bounds.height - bottomInset - h,
            width: w,
            height: h
        )
        let pad: CGFloat = 4
        coverImageView.frame = CGRect(x: pad, y: pad, width: coverSize.width, height: coverSize.height)
        let infoX = coverImageView.frame.maxX + 12
        let btnSize: CGFloat = 32
        let closeSize: CGFloat = 20
        let rightPad: CGFloat = 16
        let playX = w - rightPad - closeSize - 12 - btnSize
        infoStack.frame = CGRect(x: infoX, y: pad, width: playX - infoX - 8, height: coverSize.height)
        playButton.frame = CGRect(x: playX, y: (h - btnSize) / 2, width: btnSize, height: btnSize)
        closeButton.frame = CGRect(x: w - rightPad - closeSize, y: (h - closeSize) / 2, width: closeSize, height: closeSize)
    }

    // MARK: - Public API

    func show() {
        guard phase == .hidden else { return }
        phase = .slidingUp
        bannerContainer.isHidden = false
        isUserInteractionEnabled = true
        layoutBanner()
        // Start off-screen
        bannerContainer.transform = CGAffineTransform(translationX: 0, y: bannerHeight)
        bannerContainer.alpha = 0
        startAnimation("slide-up")
    }

    func collapse() {
        guard phase == .banner else { return }
        collapseTimer?.invalidate()
        stopAnimation()
        phase = .fadingContent
        startAnimation("fade-content")
    }

    func dismiss() {
        guard phase == .widget else { return }
        phase = .dismissing
        bannerContainer.isUserInteractionEnabled = false
        startAnimation("dismiss")
    }

    // MARK: - Animation Engine (CADisplayLink)

    private func startAnimation(_ startPhase: String) {
        animPhase = startPhase
        phaseStartTime = 0
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        guard phase != .hidden else { stopAnimation(); return }

        let now = link.timestamp
        if phaseStartTime == 0 { phaseStartTime = now }
        let elapsed = CGFloat(now - phaseStartTime)

        switch animPhase {
        case "slide-up":
            tickSlideUp(elapsed)
        case "fade-content":
            tickFadeContent(elapsed)
        case "shrink":
            tickShrink(elapsed, now: now)
        case "morph":
            tickMorph(elapsed, now: now)
        case "dismiss":
            tickDismiss(elapsed)
        default:
            stopAnimation()
        }
    }

    // MARK: Phase: Slide Up
    private func tickSlideUp(_ elapsed: CGFloat) {
        let t = min(elapsed / CGFloat(timing.slideUpDuration), 1)
        let e = easeOutCubic(t)
        bannerContainer.transform = CGAffineTransform(translationX: 0, y: (1 - e) * bannerHeight)
        bannerContainer.alpha = min(t * 3, 1)

        if t >= 1 {
            bannerContainer.transform = .identity
            bannerContainer.alpha = 1
            phase = .banner
            stopAnimation()
            delegate?.continueWatchingDidShow()
            // Auto-collapse
            collapseTimer = Timer.scheduledTimer(withTimeInterval: timing.collapseDelay, repeats: false) { [weak self] _ in
                guard let self, self.phase == .banner else { return }
                self.phase = .fadingContent
                self.startAnimation("fade-content")
            }
        }
    }

    // MARK: Phase: Fade Content
    private func tickFadeContent(_ elapsed: CGFloat) {
        let t = min(elapsed / CGFloat(timing.fadeOutDuration), 1)
        let e = easeOutCubic(t)
        infoStack.alpha = 1 - e
        playButton.alpha = 1 - e
        closeButton.alpha = 1 - e

        if t >= 1 {
            // DON'T hide — keep elements in layout so banner looks the same
            // as HTML (opacity:0 elements still occupy space).
            // Just ensure they're fully transparent.
            infoStack.alpha = 0
            playButton.alpha = 0
            closeButton.alpha = 0
            animPhase = "shrink"
            phaseStartTime = 0
            phase = .shrinking
        }
    }

    // MARK: Phase: Shrink
    // HTML behavior: the flex container shrinks from 375→52.35 with overflow:hidden.
    // padding transitions from (4,16,4,4) to (0,0,0,0).
    // Cover stays at coverSize but its position shifts as padding changes.
    // Container clips from the right side like a curtain closing.
    private func tickShrink(_ elapsed: CGFloat, now: CFTimeInterval) {
        let t = min(elapsed / CGFloat(timing.shrinkDuration), 1)
        let e = easeInOutCubic(t)

        let w = lerp(parentWidth, collapsedWidth, e)
        let h = lerp(bannerHeight, collapsedHeight, e)
        let y = bounds.height - bottomInset - h

        bannerContainer.frame = CGRect(x: 0, y: y, width: w, height: h)

        // Padding transitions from banner padding to zero (matching HTML)
        let padTop = lerp(4, 0, e)
        let padLeft = lerp(4, 0, e)

        // Cover moves with padding but keeps its size
        coverImageView.frame = CGRect(x: padLeft, y: padTop, width: coverSize.width, height: coverSize.height)

        // Corner radius transition: first half stays 8px top corners only,
        // second half transitions to all corners and radius 8→4
        let radius: CGFloat = t < 0.5 ? 8 : lerp(8, 4, (t - 0.5) * 2)
        bannerContainer.layer.cornerRadius = radius
        bannerContainer.layer.maskedCorners = t < 0.5
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        // Background fade: solid in first half, fades to transparent in second half
        let bgAlpha = lerp(1, 0, max(0, (t - 0.5) * 2))
        bannerContainer.backgroundColor = UIColor(red: 38/255, green: 40/255, blue: 46/255, alpha: bgAlpha)

        if t >= 1 {
            animPhase = "morph"
            phaseStartTime = 0
            phase = .morphing
            bannerContainer.backgroundColor = .clear
            bannerContainer.clipsToBounds = false
            // DON'T snap cover — let morph phase handle the smooth transition
            // Cover stays at (0, 0, coverSize.width, coverSize.height)
            coverImageView.layer.cornerRadius = 4
            // Hide the other elements now
            infoStack.isHidden = true
            playButton.isHidden = true
            closeButton.isHidden = true
        }
    }

    // MARK: Phase: Morph to Widget
    // Cover smoothly grows from coverSize to widgetSize while container also grows.
    private func tickMorph(_ elapsed: CGFloat, now: CFTimeInterval) {
        let t = min(elapsed / CGFloat(timing.morphDuration), 1)
        let e = easeOutBack(t)
        let eSmooth = easeOutCubic(t)

        let startBottom = bottomInset
        let endBottom = bottomInset + 8

        let x = lerp(0, widgetOffset.x, e)
        let bottom = lerp(startBottom, endBottom, e)
        let w = lerp(collapsedWidth, widgetSize.width, e)
        let h = lerp(collapsedHeight, widgetSize.height, e)
        let y = bounds.height - bottom - h

        bannerContainer.frame = CGRect(x: x, y: y, width: w, height: h)

        // Cover fills the container at every frame
        coverImageView.frame = bannerContainer.bounds

        let radius = lerp(4, 8, eSmooth)
        bannerContainer.layer.cornerRadius = radius
        coverImageView.layer.cornerRadius = radius

        // Shadow — must set shadowPath for correct rendering with clipsToBounds=false
        bannerContainer.layer.shadowColor = UIColor.black.cgColor
        bannerContainer.layer.shadowOffset = CGSize(width: 4, height: 4)
        bannerContainer.layer.shadowRadius = 16
        bannerContainer.layer.shadowOpacity = Float(eSmooth * 0.4)
        bannerContainer.layer.shadowPath = UIBezierPath(
            roundedRect: bannerContainer.bounds, cornerRadius: radius
        ).cgPath

        // Border
        bannerContainer.layer.borderWidth = 1
        bannerContainer.layer.borderColor = UIColor.white.withAlphaComponent(eSmooth * 0.15).cgColor

        if t >= 1 {
            phase = .widget
            stopAnimation()
            bannerContainer.isUserInteractionEnabled = true
            delegate?.continueWatchingDidCollapse()
            // Show widget buttons
            widgetPlayButton.isHidden = false
            widgetCloseButton.isHidden = false
            layoutWidgetButtons()
            UIView.animate(withDuration: 0.35) {
                self.widgetPlayButton.alpha = 1
                self.widgetCloseButton.alpha = 1
            }
        }
    }

    // MARK: Phase: Dismiss
    private func tickDismiss(_ elapsed: CGFloat) {
        let t = min(elapsed / CGFloat(timing.dismissDuration), 1)
        let e = easeOutCubic(t)

        bannerContainer.alpha = 1 - e
        let scale = lerp(1, 0.7, e)
        let ty = lerp(0, 30, e)
        bannerContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(translationX: 0, y: ty))

        if t >= 1 {
            phase = .hidden
            stopAnimation()
            bannerContainer.isHidden = true
            bannerContainer.transform = .identity
            bannerContainer.alpha = 1
            isUserInteractionEnabled = false
            resetSubviews()
            delegate?.continueWatchingDidDismiss()
        }
    }

    // MARK: - Helpers

    private func resetSubviews() {
        infoStack.isHidden = false
        infoStack.alpha = 1
        playButton.isHidden = false
        playButton.alpha = 1
        closeButton.isHidden = false
        closeButton.alpha = 1
        widgetPlayButton.isHidden = true
        widgetPlayButton.alpha = 0
        widgetCloseButton.isHidden = true
        widgetCloseButton.alpha = 0
        bannerContainer.clipsToBounds = true
        bannerContainer.layer.shadowOpacity = 0
        bannerContainer.layer.borderWidth = 0
        bannerContainer.backgroundColor = UIColor(red: 38/255, green: 40/255, blue: 46/255, alpha: 1)
        bannerContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bannerContainer.layer.cornerRadius = 8
    }

    private func layoutWidgetButtons() {
        let b = bannerContainer.bounds
        widgetPlayButton.frame = CGRect(x: (b.width - 38) / 2, y: (b.height - 38) / 2, width: 38, height: 38)
        widgetCloseButton.frame = CGRect(x: b.width - 11, y: -7, width: 18, height: 18)
    }

    // MARK: - Actions
    @objc private func onPlay() {
        delegate?.continueWatchingDidTapPlay()
    }
    @objc private func onClose() {
        collapse()
    }
    @objc private func onDismiss() {
        dismiss()
    }

    // MARK: - Draw Buttons
    private func drawPlayButton() {
        let size: CGFloat = 32
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            UIColor(red: 246/255, green: 97/255, blue: 15/255, alpha: 1).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 13, y: 9.5))
            path.addLine(to: CGPoint(x: 13, y: 22.5))
            path.addLine(to: CGPoint(x: 24, y: 16))
            path.close()
            path.fill()
        }
        playButton.setImage(img, for: .normal)
    }

    private func drawCloseButton() {
        let size: CGFloat = 20
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            let c = ctx.cgContext
            c.setStrokeColor(UIColor(red: 159/255, green: 159/255, blue: 162/255, alpha: 1).cgColor)
            c.setLineWidth(1.5)
            c.setLineCap(.round)
            c.move(to: CGPoint(x: 4, y: 4))
            c.addLine(to: CGPoint(x: 16, y: 16))
            c.move(to: CGPoint(x: 16, y: 4))
            c.addLine(to: CGPoint(x: 4, y: 16))
            c.strokePath()
        }
        closeButton.setImage(img, for: .normal)
    }

    private func drawWidgetButtons() {
        // Widget play
        let playSize: CGFloat = 38
        let pr = UIGraphicsImageRenderer(size: CGSize(width: playSize, height: playSize))
        let playImg = pr.image { ctx in
            UIColor.black.withAlphaComponent(0.45).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: playSize, height: playSize))
            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 15.5, y: 11))
            path.addLine(to: CGPoint(x: 15.5, y: 27))
            path.addLine(to: CGPoint(x: 28, y: 19))
            path.close()
            path.fill()
        }
        widgetPlayButton.setImage(playImg, for: .normal)

        // Widget close
        let closeSize: CGFloat = 18
        let cr = UIGraphicsImageRenderer(size: CGSize(width: closeSize, height: closeSize))
        let closeImg = cr.image { ctx in
            let c = ctx.cgContext
            UIColor.black.withAlphaComponent(0.55).setFill()
            c.fillEllipse(in: CGRect(x: 0, y: 0, width: closeSize, height: closeSize))
            c.setStrokeColor(UIColor.white.cgColor)
            c.setLineWidth(1.2)
            c.setLineCap(.round)
            c.move(to: CGPoint(x: 5.5, y: 5.5))
            c.addLine(to: CGPoint(x: 12.5, y: 12.5))
            c.move(to: CGPoint(x: 12.5, y: 5.5))
            c.addLine(to: CGPoint(x: 5.5, y: 12.5))
            c.strokePath()
        }
        widgetCloseButton.setImage(closeImg, for: .normal)
    }

    deinit {
        stopAnimation()
        collapseTimer?.invalidate()
    }
}
