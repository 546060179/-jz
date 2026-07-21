/**
 * Motion Effects 体系
 *
 * 通用效果系统：fade、scale、slide、rotate、blur 及其组合。
 */

/** 单一效果类型 */
export type EffectType = 'fade' | 'scale' | 'slide' | 'rotate' | 'blur' | 'flip' | 'collapse';

/** Fade 效果参数 */
export interface FadeEffect {
  type: 'fade';
  from?: number;
  to?: number;
}

/** Scale 效果参数 */
export interface ScaleEffect {
  type: 'scale';
  from?: number;
  to?: number;
}

/** Slide 效果参数 */
export interface SlideEffect {
  type: 'slide';
  direction?: 'up' | 'down' | 'left' | 'right';
  distance?: number;
}

/** Rotate 效果参数 */
export interface RotateEffect {
  type: 'rotate';
  /** 起始角度（deg），默认 -10（enter）或 0（exit） */
  from?: number;
  /** 目标角度（deg），默认 0（enter）或 10（exit） */
  to?: number;
}

/** Blur 效果参数 */
export interface BlurEffect {
  type: 'blur';
  /** 起始模糊半径（px），默认 8（enter）或 0（exit） */
  from?: number;
  /** 目标模糊半径（px），默认 0（enter）或 8（exit） */
  to?: number;
}

/** Flip 效果参数（3D 翻转） */
export interface FlipEffect {
  type: 'flip';
  /** 翻转轴方向，"x" 绕 X 轴（垂直翻转），"y" 绕 Y 轴（水平翻转），默认 "y" */
  axis?: 'x' | 'y';
  /** 起始角度（deg），默认 0 */
  from?: number;
  /** 目标角度（deg），默认 180 */
  to?: number;
  /** 透视距离（px），默认 800 */
  perspective?: number;
  /** 背面可见性，默认 "hidden" */
  backfaceVisibility?: 'visible' | 'hidden';
  /** 翻转状态布尔值，true 时自动 0→180，false 时自动 180→0；from/to 优先 */
  flipped?: boolean;
}

/** Collapse 效果参数（折叠展开） */
export interface CollapseEffect {
  type: 'collapse';
  /** 折叠后的目标高度（px），默认 0 */
  collapsedHeight?: number;
}

/** 效果联合类型 */
export type MotionEffect = FadeEffect | ScaleEffect | SlideEffect | RotateEffect | BlurEffect | FlipEffect | CollapseEffect;

/** 效果预设：常用组合 */
export const EFFECT_PRESETS = {
  'fade-in': [{ type: 'fade', from: 0, to: 1 }] as MotionEffect[],
  'fade-out': [{ type: 'fade', from: 1, to: 0 }] as MotionEffect[],
  'scale-fade-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'scale', from: 0.95, to: 1 },
  ] as MotionEffect[],
  'scale-fade-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'scale', from: 1, to: 0.95 },
  ] as MotionEffect[],
  'slide-up-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'slide', direction: 'up', distance: 16 },
  ] as MotionEffect[],
  'slide-down-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'slide', direction: 'down', distance: 16 },
  ] as MotionEffect[],
  'slide-left-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'slide', direction: 'left', distance: 16 },
  ] as MotionEffect[],
  'slide-right-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'slide', direction: 'right', distance: 16 },
  ] as MotionEffect[],
  /** 旋转淡入 */
  'rotate-fade-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'rotate', from: -10, to: 0 },
  ] as MotionEffect[],
  /** 旋转淡出 */
  'rotate-fade-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'rotate', from: 0, to: 10 },
  ] as MotionEffect[],
  /**
   * 模糊淡入 — "由糊变清"聚焦入场。
   * 刻意从较高透明度(0.6)起步而非 0：纯淡入是 opacity 0→1，若 blur-in 也从 0 淡入
   * 就会与纯淡入难以区分。保留初始 0.6 透明度 + 较大初始模糊(14px)，让"去模糊"成为主视觉，
   * 与 fade-in 清晰区分。五端(Web/iOS/Android)同款参数。
   */
  'blur-fade-in': [
    { type: 'fade', from: 0.6, to: 1 },
    { type: 'blur', from: 14, to: 0 },
  ] as MotionEffect[],
  /** 模糊淡出 — 去焦离场（透明度归零 + 逐渐模糊） */
  'blur-fade-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'blur', from: 0, to: 14 },
  ] as MotionEffect[],
  /** 绕 X 轴翻转淡入（90deg→0deg） */
  'flip-x-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'flip', axis: 'x', from: 90, to: 0 },
  ] as MotionEffect[],
  /** 绕 X 轴翻转淡出（0deg→90deg） */
  'flip-x-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'flip', axis: 'x', from: 0, to: 90 },
  ] as MotionEffect[],
  /** 绕 Y 轴翻转淡入（90deg→0deg） */
  'flip-y-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'flip', axis: 'y', from: 90, to: 0 },
  ] as MotionEffect[],
  /** 绕 Y 轴翻转淡出（0deg→90deg） */
  'flip-y-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'flip', axis: 'y', from: 0, to: 90 },
  ] as MotionEffect[],
  /** 折叠展开淡入（collapsedHeight=0） */
  'collapse-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'collapse', collapsedHeight: 0 },
  ] as MotionEffect[],
  /** 折叠收起淡出（collapsedHeight=0） */
  'collapse-out': [
    { type: 'fade', from: 1, to: 0 },
    { type: 'collapse', collapsedHeight: 0 },
  ] as MotionEffect[],
  /** 弹性缩放进入（scale 0.3→1，建议配 easing="bounce" 出过冲弹入） */
  'bounce-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'scale', from: 0.3, to: 1 },
  ] as MotionEffect[],
  /** 缩放进入（scale 0.5→1，比 scale-fade-in 幅度更大，图片/卡片聚焦入场） */
  'zoom-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'scale', from: 0.5, to: 1 },
  ] as MotionEffect[],
  /** 缩放上滑进入（卡片从下方滑近并放大：scale 0.9→1 + slide up 32） */
  'zoom-slide-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'scale', from: 0.9, to: 1 },
    { type: 'slide', direction: 'up', distance: 32 },
  ] as MotionEffect[],
  /** 旋转进入（rotate -180→0 + 淡入，趣味旋入，建议配 easing="expressive"） */
  'spin-in': [
    { type: 'fade', from: 0, to: 1 },
    { type: 'rotate', from: -180, to: 0 },
  ] as MotionEffect[],
} as const;

export type EffectPresetName = keyof typeof EFFECT_PRESETS;

/**
 * 序列动画步骤
 */
export interface SequenceStep {
  /** 效果列表 */
  effects: MotionEffect[];
  /** 该步骤的持续时长（ms），不设则使用全局 duration */
  duration?: number;
  /** 该步骤的延迟（ms），相对于上一步结束 */
  delay?: number;
}
