import type { PresetSpeed } from './types';
import { TIMING_SCALES } from './tokens';

/**
 * 预设速度映射（ms）— 向后兼容
 * 新代码建议使用 TIMING_SCALES (t1-t5) 替代
 */
export const PRESET_SPEEDS: Record<PresetSpeed, number> = {
  fast: TIMING_SCALES.t2,   // 150ms
  normal: TIMING_SCALES.t3, // 300ms
  slow: TIMING_SCALES.t4,   // 500ms (原 600ms，对齐 timing scale)
} as const;

/** 默认配置值 */
export const DEFAULTS = {
  in: true,
  duration: TIMING_SCALES.t3, // 300ms
  delay: 0,
  easing: 'ease',
  preset: 'normal' as PresetSpeed,
} as const;
