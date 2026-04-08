import type { FadeProps, PresetSpeed, ResolvedFadeConfig } from './types';
import type { TimingScale, TimingAlias, EasingName } from './tokens';
import { TIMING_SCALES, TIMING_ALIASES, EASING_CURVES, INTENT_DEFAULTS } from './tokens';
import { PRESET_SPEEDS, DEFAULTS } from './constants';
import { resolveMotionLevel, REDUCED_MAX_DURATION } from './reducedMotion';

/** 检查是否为有效的 TimingScale */
function isTimingScale(v: string): v is TimingScale {
  return v in TIMING_SCALES;
}

/** 检查是否为有效的 TimingAlias */
function isTimingAlias(v: string): v is TimingAlias {
  return v in TIMING_ALIASES;
}

/** 检查是否为命名缓动 */
function isEasingName(v: string): v is EasingName {
  return v in EASING_CURVES;
}

/**
 * 解析用户传入的 FadeProps，返回所有字段已确定的 ResolvedFadeConfig。
 *
 * 优先级规则（duration）：
 * 1. 自定义 duration（最高优先级）
 * 2. timing token (t1-t5 或 extra-fast 等别名)
 * 3. preset（向后兼容的 fast/normal/slow）
 * 4. intent 推导的默认 timing
 * 5. 全局默认值 300ms
 *
 * 优先级规则（easing）：
 * 1. 自定义 easing（CSS 字符串或命名缓动）
 * 2. intent 推导的默认 easing
 * 3. 全局默认值 'ease'
 *
 * Motion Level 规则：
 * - full: 正常播放
 * - reduced: 保留过渡感，duration clamp 到 100ms，delay 置 0
 * - none: duration 和 delay 均为 0
 */
export function resolveConfig(props: FadeProps = {}): ResolvedFadeConfig {
  const { duration, delay, easing, preset, timing, intent } = props;

  // --- resolve intent defaults ---
  const intentDefaults = intent && intent in INTENT_DEFAULTS
    ? INTENT_DEFAULTS[intent]
    : undefined;

  // --- resolve duration ---
  let resolvedDuration: number;

  if (duration !== undefined) {
    resolvedDuration = duration >= 0 ? duration : DEFAULTS.duration;
  } else if (timing !== undefined) {
    if (isTimingScale(timing)) {
      resolvedDuration = TIMING_SCALES[timing];
    } else if (isTimingAlias(timing)) {
      resolvedDuration = TIMING_SCALES[TIMING_ALIASES[timing]];
    } else {
      resolvedDuration = DEFAULTS.duration;
    }
  } else if (preset !== undefined) {
    const validPresets: PresetSpeed[] = ['fast', 'normal', 'slow'];
    if (validPresets.includes(preset as PresetSpeed)) {
      resolvedDuration = PRESET_SPEEDS[preset as PresetSpeed];
    } else {
      resolvedDuration = PRESET_SPEEDS.normal;
    }
  } else if (intentDefaults) {
    resolvedDuration = TIMING_SCALES[intentDefaults.timing];
  } else {
    resolvedDuration = DEFAULTS.duration;
  }

  // --- resolve delay ---
  let resolvedDelay: number;
  if (delay !== undefined) {
    resolvedDelay = delay >= 0 ? delay : DEFAULTS.delay;
  } else {
    resolvedDelay = DEFAULTS.delay;
  }

  // --- resolve easing ---
  let resolvedEasing: string;
  if (easing && easing.length > 0) {
    resolvedEasing = isEasingName(easing) ? EASING_CURVES[easing] : easing;
  } else if (intentDefaults) {
    resolvedEasing = EASING_CURVES[intentDefaults.easing];
  } else {
    resolvedEasing = DEFAULTS.easing;
  }

  // --- apply motion level ---
  const motionLevel = resolveMotionLevel();
  let reducedMotion = false;

  if (motionLevel === 'none') {
    resolvedDuration = 0;
    resolvedDelay = 0;
    reducedMotion = true;
  } else if (motionLevel === 'reduced') {
    resolvedDuration = Math.min(resolvedDuration, REDUCED_MAX_DURATION);
    resolvedDelay = 0;
    reducedMotion = true;
  }

  return {
    duration: resolvedDuration,
    delay: resolvedDelay,
    easing: resolvedEasing,
    reducedMotion,
  };
}
