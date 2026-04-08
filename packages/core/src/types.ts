import type { TimingScale, TimingAlias, EasingName, MotionIntent } from './tokens';

/** 预设速度类型（向后兼容） */
export type PresetSpeed = 'fast' | 'normal' | 'slow';

/** 组件 Props 接口（React 和 Vue 共用类型定义） */
export interface FadeProps {
  /** 控制动画方向：true 为淡入，false 为淡出，默认 true */
  in?: boolean;
  /** 动画持续时长（ms），默认 300ms */
  duration?: number;
  /** 动画延迟时间（ms），默认 0ms */
  delay?: number;
  /** CSS 缓动函数，支持字符串或命名缓动 */
  easing?: string | EasingName;
  /** 预设速度方案（向后兼容） */
  preset?: PresetSpeed;
  /** 时间刻度（新 token 体系），优先级高于 preset */
  timing?: TimingScale | TimingAlias;
  /** 动效意图，自动推导 timing 和 easing 默认值 */
  intent?: MotionIntent;
  /** 动画结束回调 */
  onAnimationEnd?: () => void;
  /** 自定义 CSS 类名，透传到根 DOM 元素 */
  className?: string;
}

/** 内部解析后的配置（所有字段已确定） */
export interface ResolvedFadeConfig {
  duration: number;
  delay: number;
  easing: string;
  reducedMotion: boolean;
}

/** 编排配置 */
export interface StaggerOptions {
  /** 每个子元素之间的延迟间隔（ms） */
  interval: number;
  /** 起始延迟（ms），默认 0 */
  baseDelay?: number;
  /** 编排方向 */
  direction?: 'forward' | 'reverse' | 'center';
}
