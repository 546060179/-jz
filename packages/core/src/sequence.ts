import type { SequenceStep } from './effects';
import { TIMING_SCALES } from './tokens';

/**
 * 序列动画控制器。
 *
 * 按顺序执行多个动画步骤，每步完成后触发下一步。
 * 支持步骤间延迟和独立时长。
 *
 * @param steps 动画步骤数组
 * @param defaultDuration 默认每步时长（ms），步骤未指定时使用
 * @returns 包含 totalDuration 和 stepDelays 的计划
 *
 * @example
 * const plan = planSequence([
 *   { effects: [{ type: 'fade', from: 0, to: 1 }], duration: 200 },
 *   { effects: [{ type: 'scale', from: 0.9, to: 1 }], delay: 50 },
 *   { effects: [{ type: 'slide', direction: 'up' }] },
 * ]);
 * // plan.stepDelays = [0, 250, 550]  (cumulative)
 * // plan.totalDuration = 850
 */
export interface SequencePlan {
  /** 每步的累计延迟（ms），用于设置每步的 delay */
  stepDelays: number[];
  /** 每步的实际时长（ms） */
  stepDurations: number[];
  /** 整个序列的总时长（ms） */
  totalDuration: number;
}

export function planSequence(
  steps: SequenceStep[],
  defaultDuration: number = TIMING_SCALES.t3
): SequencePlan {
  const stepDelays: number[] = [];
  const stepDurations: number[] = [];
  let cumulative = 0;

  for (const step of steps) {
    const stepDelay = step.delay ?? 0;
    cumulative += stepDelay;
    stepDelays.push(cumulative);

    const dur = step.duration ?? defaultDuration;
    stepDurations.push(dur);
    cumulative += dur;
  }

  return {
    stepDelays,
    stepDurations,
    totalDuration: cumulative,
  };
}
