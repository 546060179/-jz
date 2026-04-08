import UIKit

/// 动效效果类型 — 对齐 Web 端 @fade-animation/core effects.ts

/// 滑动方向
enum SlideDirection {
    case up, down, left, right
}

/// 翻转轴方向
enum FlipAxis {
    case x, y
}

/// 折叠目标高度
enum CollapseHeight {
    /// 固定高度值
    case fixed(CGFloat)
    /// 自动测量当前高度
    case auto
}

/// 效果枚举
enum MotionEffect {
    /// 淡入淡出效果
    case fade(from: CGFloat? = nil, to: CGFloat? = nil)
    /// 缩放效果
    case scale(from: CGFloat? = nil, to: CGFloat? = nil)
    /// 滑动效果
    case slide(direction: SlideDirection = .up, distance: CGFloat = 16)
    /// 旋转效果
    case rotate(from: CGFloat? = nil, to: CGFloat? = nil)
    /// 模糊效果
    case blur(from: CGFloat? = nil, to: CGFloat? = nil)
    /// 3D 翻转效果
    case flip(axis: FlipAxis = .y, from: CGFloat = 0, to: CGFloat = 180, perspective: CGFloat = 800, backfaceVisibility: String = "hidden")
    /// 折叠展开效果
    case collapse(collapsedHeight: CollapseHeight = .fixed(0))
}

/// 效果预设 — 对齐 Web 端 EFFECT_PRESETS
enum EffectPresets {
    static let fadeIn: [MotionEffect] = [.fade(from: 0, to: 1)]
    static let fadeOut: [MotionEffect] = [.fade(from: 1, to: 0)]

    static let scaleFadeIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .scale(from: 0.95, to: 1)
    ]
    static let scaleFadeOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .scale(from: 1, to: 0.95)
    ]

    static let slideUpIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .up, distance: 16)
    ]
    static let slideDownOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .slide(direction: .down, distance: 16)
    ]
    static let slideLeftIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .left, distance: 16)
    ]
    static let slideRightIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .right, distance: 16)
    ]

    static let flipXIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .flip(axis: .x, from: 90, to: 0)
    ]
    static let flipXOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .flip(axis: .x, from: 0, to: 90)
    ]
    static let flipYIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .flip(axis: .y, from: 90, to: 0)
    ]
    static let flipYOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .flip(axis: .y, from: 0, to: 90)
    ]

    static let collapseIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .collapse(collapsedHeight: .fixed(0))
    ]
    static let collapseOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .collapse(collapsedHeight: .fixed(0))
    ]
}
