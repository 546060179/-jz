/**
 * 业务动效组件的默认参数（单一事实源）。
 *
 * Web(React/Vue)组件从此处取默认值；iOS/Android 各自的默认值通过
 * `contract/motion-contract.json` 的契约测试与这里保持一致，防止三端漂移。
 */

/** BubbleExpand 默认参数 */
export const BUBBLE_EXPAND_DEFAULTS = {
  /** 阻尼比 */
  zeta: 0.5,
  /** 角频率 */
  omega: 9.0,
  /** 展开时长（ms） */
  expandDuration: 650,
  /** 文字淡入时长（ms） */
  textFadeDuration: 300,
} as const;

/** ContinueWatching 5 阶段默认时长（ms） */
export const CONTINUE_WATCHING_TIMING = {
  slideUpDuration: 450,
  collapseDelay: 3000,
  fadeOutDuration: 300,
  shrinkDuration: 400,
  morphDuration: 550,
} as const;
