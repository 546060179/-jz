import type { StaggerOptions } from './types';

/**
 * 编排工具：计算每个子元素的延迟时间。
 *
 * 参考文章中 Choreography 概念：多元素协同动画时，
 * 通过交错延迟创造有节奏的视觉流。
 *
 * @param count 子元素总数
 * @param options 编排配置
 * @returns 每个子元素的延迟时间数组（ms）
 *
 * @example
 * // 5 个卡片依次淡入，间隔 50ms
 * stagger(5, { interval: 50 })
 * // → [0, 50, 100, 150, 200]
 *
 * // 从中间向两侧展开
 * stagger(5, { interval: 50, direction: 'center' })
 * // → [100, 50, 0, 50, 100]
 *
 * // 反向，从最后一个开始
 * stagger(5, { interval: 50, direction: 'reverse' })
 * // → [200, 150, 100, 50, 0]
 */
export function stagger(count: number, options: StaggerOptions): number[] {
  if (count <= 0) return [];

  const { interval, baseDelay = 0, direction = 'forward' } = options;
  const safeInterval = Math.max(0, interval);
  const safeBase = Math.max(0, baseDelay);

  const delays: number[] = [];

  switch (direction) {
    case 'reverse':
      for (let i = 0; i < count; i++) {
        delays.push(safeBase + (count - 1 - i) * safeInterval);
      }
      break;

    case 'center': {
      const center = (count - 1) / 2;
      for (let i = 0; i < count; i++) {
        delays.push(safeBase + Math.round(Math.abs(i - center) * safeInterval));
      }
      break;
    }

    case 'forward':
    default:
      for (let i = 0; i < count; i++) {
        delays.push(safeBase + i * safeInterval);
      }
      break;
  }

  return delays;
}
