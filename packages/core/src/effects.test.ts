import { describe, it, expect } from 'vitest';
import { resolveEffectStyles } from './resolveEffectStyles';
import { EFFECT_PRESETS } from './effects';
import type { MotionEffect } from './effects';
import { EASING_CURVES } from './tokens';

describe('resolveEffectStyles', () => {
  it('resolves fade effect for entering', () => {
    const effects: MotionEffect[] = [{ type: 'fade' }];
    const result = resolveEffectStyles(effects, true);
    expect(result.from.opacity).toBe('0');
    expect(result.to.opacity).toBe('1');
    expect(result.transitionProperties).toEqual(['opacity']);
  });

  it('resolves fade effect for exiting', () => {
    const effects: MotionEffect[] = [{ type: 'fade' }];
    const result = resolveEffectStyles(effects, false);
    expect(result.from.opacity).toBe('1');
    expect(result.to.opacity).toBe('0');
  });

  it('resolves scale effect', () => {
    const effects: MotionEffect[] = [{ type: 'scale' }];
    const result = resolveEffectStyles(effects, true);
    expect(result.from.transform).toContain('scale(0.95)');
    expect(result.to.transform).toContain('scale(1)');
    expect(result.transitionProperties).toContain('transform');
  });

  it('resolves slide-up effect', () => {
    const effects: MotionEffect[] = [{ type: 'slide', direction: 'up', distance: 20 }];
    const result = resolveEffectStyles(effects, true);
    expect(result.from.transform).toContain('translateY(20px)');
    expect(result.transitionProperties).toContain('transform');
  });

  it('resolves combined fade + scale', () => {
    const effects: MotionEffect[] = [
      { type: 'fade', from: 0, to: 1 },
      { type: 'scale', from: 0.9, to: 1 },
    ];
    const result = resolveEffectStyles(effects, true);
    expect(result.from.opacity).toBe('0');
    expect(result.from.transform).toContain('scale(0.9)');
    expect(result.to.opacity).toBe('1');
    expect(result.to.transform).toContain('scale(1)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform']);
  });

  it('resolves scale-fade-in preset', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['scale-fade-in']], true);
    expect(result.from.opacity).toBe('0');
    expect(result.from.transform).toContain('scale(0.95)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform']);
  });
});

describe('resolveEffectStyles - rotate', () => {
  it('resolves rotate effect for entering', () => {
    const result = resolveEffectStyles([{ type: 'rotate' }], true);
    expect(result.from.transform).toContain('rotate(-10deg)');
    expect(result.to.transform).toContain('rotate(0deg)');
    expect(result.transitionProperties).toContain('transform');
  });

  it('resolves custom rotate values', () => {
    const result = resolveEffectStyles([{ type: 'rotate', from: -45, to: 0 }], true);
    expect(result.from.transform).toContain('rotate(-45deg)');
    expect(result.to.transform).toContain('rotate(0deg)');
  });

  it('resolves rotate-fade-in preset', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['rotate-fade-in']], true);
    expect(result.from.opacity).toBe('0');
    expect(result.from.transform).toContain('rotate(-10deg)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform']);
  });
});

describe('resolveEffectStyles - blur', () => {
  it('resolves blur effect for entering', () => {
    const result = resolveEffectStyles([{ type: 'blur' }], true);
    expect(result.from.filter).toBe('blur(8px)');
    expect(result.to.filter).toBe('blur(0px)');
    expect(result.transitionProperties).toContain('filter');
  });

  it('resolves custom blur values', () => {
    const result = resolveEffectStyles([{ type: 'blur', from: 20, to: 0 }], true);
    expect(result.from.filter).toBe('blur(20px)');
    expect(result.to.filter).toBe('blur(0px)');
  });

  it('resolves blur-fade-in preset', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['blur-fade-in']], true);
    // 刻意从 0.6 透明度起步(而非 0)，让"由糊变清"区别于纯淡入；初始模糊加大到 14px
    expect(result.from.opacity).toBe('0.6');
    expect(result.to.opacity).toBe('1');
    expect(result.from.filter).toBe('blur(14px)');
    expect(result.to.filter).toBe('blur(0px)');
    expect(result.transitionProperties).toEqual(['opacity', 'filter']);
  });
});

describe('resolveEffectStyles - combined rotate + blur + fade', () => {
  it('resolves all three effects together', () => {
    const result = resolveEffectStyles([
      { type: 'fade', from: 0, to: 1 },
      { type: 'rotate', from: -15, to: 0 },
      { type: 'blur', from: 10, to: 0 },
    ], true);
    expect(result.from.opacity).toBe('0');
    expect(result.from.transform).toContain('rotate(-15deg)');
    expect(result.from.filter).toBe('blur(10px)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform', 'filter']);
  });
});

describe('EFFECT_PRESETS - 新增预设', () => {
  it('bounce-in: fade 0→1 + scale 0.3→1', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['bounce-in']], true);
    expect(result.from.opacity).toBe('0');
    expect(result.to.opacity).toBe('1');
    expect(result.from.transform).toContain('scale(0.3)');
    expect(result.to.transform).toContain('scale(1)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform']);
  });

  it('zoom-in: fade 0→1 + scale 0.5→1', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['zoom-in']], true);
    expect(result.from.transform).toContain('scale(0.5)');
    expect(result.to.transform).toContain('scale(1)');
  });

  it('zoom-slide-in: fade + scale 0.9→1 + slide up 32', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['zoom-slide-in']], true);
    expect(result.from.transform).toContain('scale(0.9)');
    expect(result.from.transform).toContain('translateY(32px)');
    expect(result.to.transform).toContain('scale(1)');
    expect(result.transitionProperties).toEqual(['opacity', 'transform']);
  });

  it('spin-in: fade + rotate -180→0', () => {
    const result = resolveEffectStyles([...EFFECT_PRESETS['spin-in']], true);
    expect(result.from.transform).toContain('rotate(-180deg)');
    expect(result.to.transform).toContain('rotate(0deg)');
  });
});

describe('EASING_CURVES - bounce', () => {
  it('bounce 缓动为过冲回落曲线（y1 > 1）', () => {
    expect(EASING_CURVES.bounce).toBe('cubic-bezier(0.34, 1.56, 0.64, 1)');
  });
});
