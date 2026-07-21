import { describe, it, expect } from 'vitest';
import contract from '../../../contract/motion-contract.json';
import { TIMING_SCALES, DISTANCE_SCALES, EASING_CURVES, INTENT_DEFAULTS } from './tokens';
import { SPRING_PRESETS } from './spring';
import { EFFECT_PRESETS } from './effects';
import { resolveEffectStyles } from './resolveEffectStyles';
import { BUBBLE_EXPAND_DEFAULTS, CONTINUE_WATCHING_TIMING } from './componentDefaults';

/**
 * 跨端一致性契约测试（core 侧）。
 *
 * 断言 core 的设计令牌与 contract/motion-contract.json 黄金值一致。
 * iOS(ContractTests.swift) 与 Android(ContractTest.kt) 断言各自实现与同一份 JSON 一致，
 * 从而保证三端令牌数值不漂移（例如新增 easing 时必须四端同步）。
 */

/** 把 'cubic-bezier(a, b, c, d)' 解析为 [a,b,c,d] */
function parseCubic(css: string): number[] {
  const m = css.match(/cubic-bezier\(([^)]+)\)/);
  if (!m) throw new Error(`不是 cubic-bezier: ${css}`);
  return m[1].split(',').map((s) => parseFloat(s.trim()));
}

describe('跨端契约 - Timing Scales', () => {
  for (const [key, value] of Object.entries(contract.timings)) {
    it(`${key} = ${value}ms`, () => {
      expect(TIMING_SCALES[key as keyof typeof TIMING_SCALES]).toBe(value);
    });
  }
});

describe('跨端契约 - Distance Scales（core 令牌）', () => {
  for (const [key, value] of Object.entries(contract.distances)) {
    it(`${key} = ${value}px`, () => {
      expect(DISTANCE_SCALES[key as keyof typeof DISTANCE_SCALES]).toBe(value);
    });
  }
});

describe('跨端契约 - Easing Curves 控制点', () => {
  for (const [name, points] of Object.entries(contract.easings)) {
    it(`${name} = cubic-bezier(${(points as number[]).join(', ')})`, () => {
      const actual = parseCubic(EASING_CURVES[name as keyof typeof EASING_CURVES]);
      expect(actual).toEqual(points);
    });
  }
});

describe('跨端契约 - Intent 默认（timing + easing）', () => {
  for (const [intent, def] of Object.entries(contract.intentDefaults)) {
    it(`${intent} → timing=${(def as any).timing}, easing=${(def as any).easing}`, () => {
      const actual = INTENT_DEFAULTS[intent as keyof typeof INTENT_DEFAULTS];
      expect(actual.timing).toBe((def as any).timing);
      expect(actual.easing).toBe((def as any).easing);
    });
  }
});

describe('跨端契约 - Spring Presets', () => {
  for (const [name, cfg] of Object.entries(contract.springs)) {
    it(`${name} = ${JSON.stringify(cfg)}`, () => {
      const actual = SPRING_PRESETS[name as keyof typeof SPRING_PRESETS] as Record<string, number>;
      expect(actual.stiffness).toBe((cfg as any).stiffness);
      expect(actual.damping).toBe((cfg as any).damping);
      expect(actual.mass).toBe((cfg as any).mass);
    });
  }
});

describe('跨端契约 - Effect Presets（blur-fade-in 参数五端一致）', () => {
  it('blur-fade-in: opacity 0.6→1, blur 14→0', () => {
    const bp = (contract as any).effectPresets.blurFadeIn;
    const styles = resolveEffectStyles([...EFFECT_PRESETS['blur-fade-in']], true);
    expect(styles.from.opacity).toBe(String(bp.opacityFrom));
    expect(styles.to.opacity).toBe(String(bp.opacityTo));
    expect(styles.from.filter).toBe(`blur(${bp.blurFrom}px)`);
    expect(styles.to.filter).toBe(`blur(${bp.blurTo}px)`);
  });
});

describe('跨端契约 - 业务组件默认参数', () => {
  it('BubbleExpand: zeta/omega/expandDuration/textFadeDuration', () => {
    const c = (contract as any).components.bubbleExpand;
    expect(BUBBLE_EXPAND_DEFAULTS.zeta).toBe(c.zeta);
    expect(BUBBLE_EXPAND_DEFAULTS.omega).toBe(c.omega);
    expect(BUBBLE_EXPAND_DEFAULTS.expandDuration).toBe(c.expandDuration);
    expect(BUBBLE_EXPAND_DEFAULTS.textFadeDuration).toBe(c.textFadeDuration);
  });

  it('ContinueWatching: 5 阶段时长', () => {
    const c = (contract as any).components.continueWatching;
    expect(CONTINUE_WATCHING_TIMING.slideUpDuration).toBe(c.slideUpDuration);
    expect(CONTINUE_WATCHING_TIMING.collapseDelay).toBe(c.collapseDelay);
    expect(CONTINUE_WATCHING_TIMING.fadeOutDuration).toBe(c.fadeOutDuration);
    expect(CONTINUE_WATCHING_TIMING.shrinkDuration).toBe(c.shrinkDuration);
    expect(CONTINUE_WATCHING_TIMING.morphDuration).toBe(c.morphDuration);
  });
});
