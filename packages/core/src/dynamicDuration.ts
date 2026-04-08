import { TIMING_SCALES } from './tokens';

/**
 * 动态时长计算。
 *
 * 根据元素移动距离和/或尺寸自动推算合理的动画时长。
 * 参考设计系统文章中 "Dynamic Duration" 概念：
 * 小元素/短距离用快速时长，大元素/长距离用慢速时长。
 *
 * 策略：
 * - 基于距离：每 100px 移动距离对应约 100ms
 * - 基于尺寸：小组件 (< 100px) → t1-t2，中等 (100-400px) → t3，大面积 (> 400px) → t4-t5
 * - 结果 clamp 在 t1 (100ms) 到 t5 (700ms) 之间
 */

interface DynamicDurationOptions {
  /** 元素移动距离（px） */
  distance?: number;
  /** 元素尺寸（px），取宽高中较大值 */
  size?: number;
}

/**
 * 根据距离和/或尺寸计算推荐动画时长。
 *
 * @param options 距离和尺寸参数
 * @returns 推荐时长（ms），clamp 在 100-700ms 之间
 *
 * @example
 * dynamicDuration({ distance: 200 }) // → 200ms
 * dynamicDuration({ size: 50 })      // → 100ms (小组件)
 * dynamicDuration({ size: 300 })     // → 300ms (中等)
 * dynamicDuration({ size: 800 })     // → 700ms (大面积，clamped)
 * dynamicDuration({ distance: 150, size: 200 }) // → 取较大值 200ms
 */
export function dynamicDuration(options: DynamicDurationOptions): number {
  const { distance, size } = options;
  const min = TIMING_SCALES.t1; // 100ms
  const max = TIMING_SCALES.t5; // 700ms

  let durationFromDistance = 0;
  let durationFromSize = 0;

  if (distance !== undefined && distance > 0) {
    // 每 100px ≈ 100ms，最低 100ms
    durationFromDistance = Math.max(min, distance);
  }

  if (size !== undefined && size > 0) {
    if (size < 100) {
      durationFromSize = TIMING_SCALES.t1; // 100ms
    } else if (size < 200) {
      durationFromSize = TIMING_SCALES.t2; // 150ms
    } else if (size < 400) {
      durationFromSize = TIMING_SCALES.t3; // 300ms
    } else if (size < 600) {
      durationFromSize = TIMING_SCALES.t4; // 500ms
    } else {
      durationFromSize = TIMING_SCALES.t5; // 700ms
    }
  }

  // 取两者中较大值，如果都没提供则返回默认 t3
  const result = Math.max(durationFromDistance, durationFromSize);
  if (result === 0) return TIMING_SCALES.t3;

  return Math.min(max, Math.round(result));
}
