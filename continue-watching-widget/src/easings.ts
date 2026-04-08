/**
 * Animation easing functions used by ContinueWatching.
 * Exported for reuse in custom animations.
 */

/** Linear interpolation between two values */
export function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

/** Cubic ease-out — fast start, slow end */
export function easeOutCubic(t: number): number {
  return 1 - Math.pow(1 - t, 3);
}

/** Cubic ease-in-out — slow start and end */
export function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
}

/** Back ease-out — overshoots then settles (spring-like) */
export function easeOutBack(t: number): number {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

/** Default animation timing config */
export const DEFAULT_TIMING = {
  slideUpDuration: 450,
  collapseDelay: 3000,
  fadeOutDuration: 300,
  shrinkDuration: 400,
  morphDuration: 550,
  dismissDuration: 300,
} as const;
