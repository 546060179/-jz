import { TIMING_SCALES, DISTANCE_SCALES, EASING_CURVES } from './tokens';
import type { TimingScale, DistanceScale, EasingName } from './tokens';

/**
 * 生成 CSS Custom Properties 字符串。
 *
 * 输出所有 Motion Design Tokens 为 CSS 变量，
 * 让不使用 React/Vue 的页面也能消费这些值。
 *
 * @param prefix CSS 变量前缀，默认 'motion'
 * @returns CSS 字符串，可直接注入 <style> 或写入 .css 文件
 *
 * @example
 * generateCSSTokens()
 * // 输出:
 * // :root {
 * //   --motion-t1: 100ms;
 * //   --motion-t2: 150ms;
 * //   ...
 * //   --motion-easing-productive: cubic-bezier(0.2, 0, 0.38, 0.9);
 * //   ...
 * // }
 */
export function generateCSSTokens(prefix = 'motion'): string {
  const lines: string[] = [':root {'];

  // Timing scales
  for (const [key, value] of Object.entries(TIMING_SCALES) as [TimingScale, number][]) {
    lines.push(`  --${prefix}-${key}: ${value}ms;`);
  }

  lines.push('');

  // Distance scales
  for (const [key, value] of Object.entries(DISTANCE_SCALES) as [DistanceScale, number][]) {
    lines.push(`  --${prefix}-${key}: ${value}px;`);
  }

  lines.push('');

  // Easing curves
  for (const [key, value] of Object.entries(EASING_CURVES) as [EasingName, string][]) {
    lines.push(`  --${prefix}-easing-${key}: ${value};`);
  }

  lines.push('}');
  return lines.join('\n');
}

/**
 * 将 CSS tokens 注入到当前文档的 <head> 中。
 * 仅在浏览器环境下生效，SSR 环境下静默跳过。
 *
 * @param prefix CSS 变量前缀
 */
export function injectCSSTokens(prefix = 'motion'): void {
  if (typeof document === 'undefined') return;

  const id = `${prefix}-design-tokens`;
  if (document.getElementById(id)) return;

  const style = document.createElement('style');
  style.id = id;
  style.textContent = generateCSSTokens(prefix);
  document.head.appendChild(style);
}
