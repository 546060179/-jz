/**
 * Motion Design Tokens（动效设计令牌）
 *
 * 参考 https://www.designsystems.com/5-steps-for-including-motion-design-in-your-system/
 * 建立系统化的动效基础构建块：Timing Scales、Easing Curves、Motion Intents。
 */

// ============================================================
// 1. Timing Scales — 类似排版 h1-h5 的时间刻度体系
// ============================================================

/** 时间刻度名称 */
export type TimingScale = 't1' | 't2' | 't3' | 't4' | 't5';

/**
 * 时间刻度映射（ms）
 *
 * - t1 (extra-fast): 微交互，按钮状态切换，小图标
 * - t2 (fast): 小组件动画，tooltip，badge
 * - t3 (normal): 标准过渡，卡片，面板
 * - t4 (slow): 大面积过渡，页面切换
 * - t5 (extra-slow): 复杂编排，全屏过渡
 */
export const TIMING_SCALES: Record<TimingScale, number> = {
  t1: 100,
  t2: 150,
  t3: 300,
  t4: 500,
  t5: 700,
} as const;

/** 时间刻度的语义别名 */
export const TIMING_ALIASES = {
  'extra-fast': 't1',
  'fast': 't2',
  'normal': 't3',
  'slow': 't4',
  'extra-slow': 't5',
} as const satisfies Record<string, TimingScale>;

export type TimingAlias = keyof typeof TIMING_ALIASES;

// ============================================================
// 2. Distance Scales — 位移距离刻度体系
// ============================================================

/** 距离刻度名称 */
export type DistanceScale = 'd1' | 'd2' | 'd3' | 'd4' | 'd5';

/**
 * 距离刻度映射（px）
 *
 * - d1 (micro): 微移动，图标抖动、按钮按压反馈
 * - d2 (small): 小位移，tooltip 弹出、badge 滑入
 * - d3 (medium): 标准位移，卡片滑动、面板展开
 * - d4 (large): 大位移，抽屉滑出、页面切换
 * - d5 (full): 全屏级位移，全屏过渡、底部弹窗
 */
export const DISTANCE_SCALES: Record<DistanceScale, number> = {
  d1: 4,
  d2: 8,
  d3: 16,
  d4: 32,
  d5: 64,
} as const;

/** 距离刻度的语义别名 */
export const DISTANCE_ALIASES = {
  'micro': 'd1',
  'small': 'd2',
  'medium': 'd3',
  'large': 'd4',
  'full': 'd5',
} as const satisfies Record<string, DistanceScale>;

export type DistanceAlias = keyof typeof DISTANCE_ALIASES;

// ============================================================
// 3. Easing Curves — 区分 productive 和 expressive 缓动
// ============================================================

/** 缓动类型名称 */
export type EasingName =
  | 'productive'
  | 'expressive'
  | 'enter'
  | 'exit'
  | 'linear';

/**
 * 缓动曲线映射（CSS cubic-bezier）
 *
 * - productive: 功能性动效，快速精准（适合 exit、关闭、收起）
 * - expressive: 表现性动效，有弹性和个性（适合 enter、展开、强调）
 * - enter: 元素进入画面（ease-out 风格，快速减速）
 * - exit: 元素离开画面（ease-in 风格，快速加速）
 * - linear: 匀速，适合循环动画或进度条
 */
export const EASING_CURVES: Record<EasingName, string> = {
  productive: 'cubic-bezier(0.2, 0, 0.38, 0.9)',
  expressive: 'cubic-bezier(0.4, 0.14, 0.3, 1)',
  enter: 'cubic-bezier(0, 0, 0.3, 1)',
  exit: 'cubic-bezier(0.4, 0, 1, 1)',
  linear: 'linear',
} as const;

// ============================================================
// 4. Motion Intent — 动效意图/原则
// ============================================================

/**
 * 动效意图类型
 *
 * - enter: 元素进入视图（淡入、滑入、缩放入）
 * - exit: 元素离开视图（淡出、滑出、缩放出）
 * - focus: 吸引注意力（脉冲、高亮、抖动）
 * - feedback: 操作反馈（按下、成功、错误）
 * - delight: 品牌个性（弹跳、旋转、彩蛋）
 */
export type MotionIntent = 'enter' | 'exit' | 'focus' | 'feedback' | 'delight';

/**
 * 每种意图的推荐默认配置
 */
export const INTENT_DEFAULTS: Record<MotionIntent, { timing: TimingScale; easing: EasingName }> = {
  enter:    { timing: 't3', easing: 'enter' },
  exit:     { timing: 't2', easing: 'exit' },
  focus:    { timing: 't2', easing: 'expressive' },
  feedback: { timing: 't1', easing: 'productive' },
  delight:  { timing: 't4', easing: 'expressive' },
} as const;
