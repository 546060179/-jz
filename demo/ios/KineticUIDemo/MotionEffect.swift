import UIKit

// MARK: - 效果类型定义（对齐 Web 端 @fade-animation/core）

enum SlideDirection {
    case up, down, left, right
}

enum FlipAxis {
    case x, y
}

enum CollapseHeight {
    case fixed(CGFloat)
    case auto
}

enum MotionEffect {
    case fade(from: CGFloat? = nil, to: CGFloat? = nil)
    case scale(from: CGFloat? = nil, to: CGFloat? = nil)
    case slide(direction: SlideDirection = .up, distance: CGFloat = 16)
    case rotate(from: CGFloat? = nil, to: CGFloat? = nil)
    case blur(from: CGFloat? = nil, to: CGFloat? = nil)
    case flip(axis: FlipAxis = .y, from: CGFloat = 0, to: CGFloat = 180, perspective: CGFloat = 800, backfaceVisibility: String = "hidden")
    case collapse(collapsedHeight: CollapseHeight = .fixed(0))
}

// MARK: - 18 种预设（完整覆盖 Kinetic UI 动效库）

enum EffectPresets {
    static let fadeIn: [MotionEffect] = [.fade(from: 0, to: 1)]
    static let fadeOut: [MotionEffect] = [.fade(from: 1, to: 0)]

    static let scaleFadeIn: [MotionEffect] = [.fade(from: 0, to: 1), .scale(from: 0.95, to: 1)]
    static let scaleFadeOut: [MotionEffect] = [.fade(from: 1, to: 0), .scale(from: 1, to: 0.95)]

    static let slideUpIn: [MotionEffect] = [.fade(from: 0, to: 1), .slide(direction: .up, distance: 16)]
    static let slideDownOut: [MotionEffect] = [.fade(from: 1, to: 0), .slide(direction: .down, distance: 16)]
    static let slideLeftIn: [MotionEffect] = [.fade(from: 0, to: 1), .slide(direction: .left, distance: 16)]
    static let slideRightIn: [MotionEffect] = [.fade(from: 0, to: 1), .slide(direction: .right, distance: 16)]

    static let rotateFadeIn: [MotionEffect] = [.fade(from: 0, to: 1), .rotate(from: -10, to: 0)]
    static let rotateFadeOut: [MotionEffect] = [.fade(from: 1, to: 0), .rotate(from: 0, to: 10)]

    static let blurFadeIn: [MotionEffect] = [.fade(from: 0.6, to: 1), .blur(from: 14, to: 0)]
    static let blurFadeOut: [MotionEffect] = [.fade(from: 1, to: 0), .blur(from: 0, to: 14)]

    static let flipXIn: [MotionEffect] = [.fade(from: 0, to: 1), .flip(axis: .x, from: 90, to: 0)]
    static let flipXOut: [MotionEffect] = [.fade(from: 1, to: 0), .flip(axis: .x, from: 0, to: 90)]
    static let flipYIn: [MotionEffect] = [.fade(from: 0, to: 1), .flip(axis: .y, from: 90, to: 0)]
    static let flipYOut: [MotionEffect] = [.fade(from: 1, to: 0), .flip(axis: .y, from: 0, to: 90)]

    static let collapseIn: [MotionEffect] = [.fade(from: 0, to: 1), .collapse(collapsedHeight: .fixed(0))]
    static let collapseOut: [MotionEffect] = [.fade(from: 1, to: 0), .collapse(collapsedHeight: .fixed(0))]
}
