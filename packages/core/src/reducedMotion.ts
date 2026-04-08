import { TIMING_SCALES } from './tokens';

/**
 * 动效级别
 *
 * - full: 完整动效，所有动画正常播放
 * - reduced: 减弱动效，保留过渡感但缩短时长到 t1 级别（100ms）
 * - none: 完全跳过动画，duration 和 delay 均为 0
 */
export type MotionLevel = 'full' | 'reduced' | 'none';

/** 全局动效级别覆盖，undefined 表示跟随系统偏好 */
let globalMotionLevel: MotionLevel | undefined;

/**
 * 设置全局动效级别。
 * 设置后将覆盖系统 prefers-reduced-motion 检测。
 * 传入 undefined 恢复为跟随系统偏好。
 */
export function setMotionLevel(level: MotionLevel | undefined): void {
  globalMotionLevel = level;
}

/** 获取当前全局动效级别设置 */
export function getMotionLevel(): MotionLevel | undefined {
  return globalMotionLevel;
}

/**
 * 检测当前用户是否启用了 reduced-motion 偏好。
 *
 * - 使用 window.matchMedia('(prefers-reduced-motion: reduce)') 检测
 * - SSR 环境下（无 window 对象）返回 false
 */
export function getReducedMotionPreference(): boolean {
  if (typeof window === 'undefined') {
    return false;
  }

  try {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  } catch {
    return false;
  }
}

/**
 * 解析当前生效的动效级别。
 *
 * 优先级：全局设置 > 系统偏好 > full
 */
export function resolveMotionLevel(): MotionLevel {
  if (globalMotionLevel !== undefined) {
    return globalMotionLevel;
  }
  return getReducedMotionPreference() ? 'none' : 'full';
}

/** reduced 模式下的最大时长（ms） */
export const REDUCED_MAX_DURATION = TIMING_SCALES.t1; // 100ms
