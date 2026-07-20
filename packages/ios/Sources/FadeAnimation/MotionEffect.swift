import UIKit

/// 动效效果类型 — 对齐 Web 端 @fade-animation/core effects.ts

/// 滑动方向
public enum SlideDirection {
    case up, down, left, right
}

/// 翻转轴方向
public enum FlipAxis {
    case x, y
}

/// 折叠目标高度
public enum CollapseHeight {
    /// 固定高度值
    case fixed(CGFloat)
    /// 自动测量当前高度
    case auto
}

/// 效果枚举
public enum MotionEffect {
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
public enum EffectPresets {
    public static let fadeIn: [MotionEffect] = [.fade(from: 0, to: 1)]
    public static let fadeOut: [MotionEffect] = [.fade(from: 1, to: 0)]

    public static let scaleFadeIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .scale(from: 0.95, to: 1)
    ]
    public static let scaleFadeOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .scale(from: 1, to: 0.95)
    ]

    public static let slideUpIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .up, distance: 16)
    ]
    public static let slideDownOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .slide(direction: .down, distance: 16)
    ]
    public static let slideLeftIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .left, distance: 16)
    ]
    public static let slideRightIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .slide(direction: .right, distance: 16)
    ]

    public static let flipXIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .flip(axis: .x, from: 90, to: 0)
    ]
    public static let flipXOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .flip(axis: .x, from: 0, to: 90)
    ]
    public static let flipYIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .flip(axis: .y, from: 90, to: 0)
    ]
    public static let flipYOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .flip(axis: .y, from: 0, to: 90)
    ]

    public static let collapseIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .collapse(collapsedHeight: .fixed(0))
    ]
    public static let collapseOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .collapse(collapsedHeight: .fixed(0))
    ]

    // --- Rotate + Fade presets ---
    public static let rotateFadeIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .rotate(from: -10, to: 0)
    ]
    public static let rotateFadeOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .rotate(from: 0, to: 10)
    ]

    // --- Blur + Fade presets ---
    public static let blurFadeIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .blur(from: 8, to: 0)
    ]
    public static let blurFadeOut: [MotionEffect] = [
        .fade(from: 1, to: 0),
        .blur(from: 0, to: 8)
    ]

    // --- 新增：弹性/缩放/旋转进入（对齐 Web EFFECT_PRESETS）---
    /// 弹性缩放进入（scale 0.3→1，建议配 EasingCurves.bounce 出过冲弹入）
    public static let bounceIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .scale(from: 0.3, to: 1)
    ]
    /// 缩放进入（scale 0.5→1，图片/卡片聚焦入场）
    public static let zoomIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .scale(from: 0.5, to: 1)
    ]
    /// 缩放上滑进入（scale 0.9→1 + 上滑 32）
    public static let zoomSlideIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .scale(from: 0.9, to: 1),
        .slide(direction: .up, distance: 32)
    ]
    /// 旋转进入（rotate -180→0 + 淡入）
    public static let spinIn: [MotionEffect] = [
        .fade(from: 0, to: 1),
        .rotate(from: -180, to: 0)
    ]
}
