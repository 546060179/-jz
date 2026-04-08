import type { MotionEffect, SlideEffect } from './effects';
import { DISTANCE_SCALES } from './tokens';

/**
 * 效果的 CSS 起始/目标状态
 */
export interface EffectStyles {
  /** 起始状态的 CSS 属性 */
  from: Record<string, string>;
  /** 目标状态的 CSS 属性 */
  to: Record<string, string>;
  /** 需要过渡的 CSS 属性列表 */
  transitionProperties: string[];
}

/** 获取 slide 效果的 translate 值 */
function getSlideTranslate(effect: SlideEffect, isFrom: boolean): string {
  const dist = effect.distance ?? DISTANCE_SCALES.d3;
  const sign = isFrom ? 1 : 0;

  switch (effect.direction ?? 'up') {
    case 'up':    return `translateY(${sign * dist}px)`;
    case 'down':  return `translateY(${sign * -dist}px)`;
    case 'left':  return `translateX(${sign * dist}px)`;
    case 'right': return `translateX(${sign * -dist}px)`;
  }
}

/**
 * 将 MotionEffect 数组解析为 CSS 起始/目标样式。
 *
 * @param effects 效果数组
 * @param entering true 表示进入动画，false 表示退出动画
 * @returns CSS 样式对象
 */
export function resolveEffectStyles(effects: MotionEffect[], entering: boolean, contentHeight?: number): EffectStyles {
  const from: Record<string, string> = {};
  const to: Record<string, string> = {};
  const transitionProperties: string[] = [];

  const transforms: { from: string[]; to: string[] } = { from: [], to: [] };

  // Flip + Rotate conflict detection (Requirements 12.1, 12.2, 12.4, 12.5)
  const hasFlip = effects.some(e => e.type === 'flip');
  const hasRotate = effects.some(e => e.type === 'rotate');
  if (hasFlip && hasRotate) {
    console.warn('[Animation_Library] FlipEffect and RotateEffect cannot be used together. RotateEffect will be ignored.');
    effects = effects.filter(e => e.type !== 'rotate');
  }

  for (const effect of effects) {
    switch (effect.type) {
      case 'fade': {
        const fadeFrom = effect.from ?? (entering ? 0 : 1);
        const fadeTo = effect.to ?? (entering ? 1 : 0);
        from['opacity'] = String(fadeFrom);
        to['opacity'] = String(fadeTo);
        transitionProperties.push('opacity');
        break;
      }
      case 'scale': {
        const scaleFrom = effect.from ?? (entering ? 0.95 : 1);
        const scaleTo = effect.to ?? (entering ? 1 : 0.95);
        transforms.from.push(`scale(${scaleFrom})`);
        transforms.to.push(`scale(${scaleTo})`);
        if (!transitionProperties.includes('transform')) {
          transitionProperties.push('transform');
        }
        break;
      }
      case 'slide': {
        transforms.from.push(getSlideTranslate(effect, true));
        transforms.to.push('translateX(0) translateY(0)');
        if (!transitionProperties.includes('transform')) {
          transitionProperties.push('transform');
        }
        break;
      }
      case 'rotate': {
        const rotFrom = effect.from ?? (entering ? -10 : 0);
        const rotTo = effect.to ?? (entering ? 0 : 10);
        transforms.from.push(`rotate(${rotFrom}deg)`);
        transforms.to.push(`rotate(${rotTo}deg)`);
        if (!transitionProperties.includes('transform')) {
          transitionProperties.push('transform');
        }
        break;
      }
      case 'flip': {
        // Resolve from/to angles: explicit from/to take priority over flipped boolean
        let flipFrom: number;
        let flipTo: number;
        if (effect.from !== undefined || effect.to !== undefined) {
          flipFrom = effect.from ?? 0;
          flipTo = effect.to ?? 180;
        } else if (effect.flipped !== undefined) {
          flipFrom = effect.flipped ? 0 : 180;
          flipTo = effect.flipped ? 180 : 0;
        } else {
          flipFrom = 0;
          flipTo = 180;
        }

        // entering=true: from→to; entering=false: to→from
        const startAngle = entering ? flipFrom : flipTo;
        const endAngle = entering ? flipTo : flipFrom;

        const perspective = effect.perspective ?? 800;
        const axis = effect.axis ?? 'y';
        const rotateFn = axis === 'x' ? 'rotateX' : 'rotateY';

        transforms.from.push(`perspective(${perspective}px) ${rotateFn}(${startAngle}deg)`);
        transforms.to.push(`perspective(${perspective}px) ${rotateFn}(${endAngle}deg)`);

        // Set backface-visibility
        const bfv = effect.backfaceVisibility ?? 'hidden';
        from['backface-visibility'] = bfv;
        to['backface-visibility'] = bfv;

        if (!transitionProperties.includes('transform')) {
          transitionProperties.push('transform');
        }
        break;
      }
      case 'collapse': {
        const collapsedHeight = effect.collapsedHeight ?? 0;
        const height = contentHeight ?? 0;
        if (entering) {
          from['max-height'] = collapsedHeight + 'px';
          to['max-height'] = height + 'px';
        } else {
          from['max-height'] = height + 'px';
          to['max-height'] = collapsedHeight + 'px';
        }
        from['overflow'] = 'hidden';
        to['overflow'] = 'hidden';
        transitionProperties.push('max-height');
        break;
      }
      case 'blur': {
        const blurFrom = effect.from ?? (entering ? 8 : 0);
        const blurTo = effect.to ?? (entering ? 0 : 8);
        from['filter'] = `blur(${blurFrom}px)`;
        to['filter'] = `blur(${blurTo}px)`;
        transitionProperties.push('filter');
        break;
      }
    }
  }

  if (transforms.from.length > 0) {
    from['transform'] = transforms.from.join(' ');
    to['transform'] = transforms.to.join(' ');
  }

  return { from, to, transitionProperties };
}
