import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { resolveConfig } from './resolveConfig';
import { setMotionLevel } from './reducedMotion';

/**
 * Helper: mock matchMedia to return a specific reduced-motion preference.
 * Returns a cleanup function.
 */
function mockMatchMedia(reducedMotion: boolean) {
  const mql = {
    matches: reducedMotion,
    media: '(prefers-reduced-motion: reduce)',
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    addListener: vi.fn(),
    removeListener: vi.fn(),
    onchange: null,
    dispatchEvent: vi.fn(),
  } as unknown as MediaQueryList;

  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockReturnValue(mql),
  });

  return mql;
}

describe('resolveConfig', () => {
  beforeEach(() => {
    // Default: reduced-motion disabled
    mockMatchMedia(false);
    setMotionLevel(undefined);
  });

  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  // --- 默认值 (Requirements 1.2-1.4, 2.2-2.4) ---
  it('should return defaults when no props provided', () => {
    const config = resolveConfig({});
    expect(config).toEqual({
      duration: 300,
      delay: 0,
      easing: 'ease',
      reducedMotion: false,
    });
  });

  it('should return defaults when called with no arguments', () => {
    const config = resolveConfig();
    expect(config.duration).toBe(300);
    expect(config.delay).toBe(0);
    expect(config.easing).toBe('ease');
  });

  // --- 自定义值覆盖 (Requirements 1.5-1.7, 2.5-2.7) ---
  it('should use custom duration when provided', () => {
    expect(resolveConfig({ duration: 500 }).duration).toBe(500);
  });

  it('should use custom delay when provided', () => {
    expect(resolveConfig({ delay: 100 }).delay).toBe(100);
  });

  it('should use custom easing when provided', () => {
    expect(resolveConfig({ easing: 'linear' }).easing).toBe('linear');
  });

  it('should accept duration of 0', () => {
    expect(resolveConfig({ duration: 0 }).duration).toBe(0);
  });

  it('should accept delay of 0', () => {
    expect(resolveConfig({ delay: 0 }).delay).toBe(0);
  });

  // --- 预设速度 (Requirements 3.1-3.3) ---
  it('should resolve preset "fast" to 150ms', () => {
    expect(resolveConfig({ preset: 'fast' }).duration).toBe(150);
  });

  it('should resolve preset "normal" to 300ms', () => {
    expect(resolveConfig({ preset: 'normal' }).duration).toBe(300);
  });

  it('should resolve preset "slow" to 500ms', () => {
    expect(resolveConfig({ preset: 'slow' }).duration).toBe(500);
  });

  // --- 自定义 duration 优先于 preset (Requirement 3.4) ---
  it('should prioritize custom duration over preset', () => {
    expect(resolveConfig({ duration: 200, preset: 'slow' }).duration).toBe(200);
  });

  it('should prioritize custom duration=0 over preset', () => {
    expect(resolveConfig({ duration: 0, preset: 'slow' }).duration).toBe(0);
  });

  // --- 负数回退 (Requirements 9.1, 9.2) ---
  it('should fallback negative duration to 300ms', () => {
    expect(resolveConfig({ duration: -100 }).duration).toBe(300);
  });

  it('should fallback negative delay to 0ms', () => {
    expect(resolveConfig({ delay: -50 }).delay).toBe(0);
  });

  it('should fallback negative duration even when preset is provided', () => {
    expect(resolveConfig({ duration: -1, preset: 'fast' }).duration).toBe(300);
  });

  // --- 无效 preset 回退 (Requirement 9.3) ---
  it('should fallback invalid preset to normal (300ms)', () => {
    expect(resolveConfig({ preset: 'invalid' as any }).duration).toBe(300);
  });

  it('should fallback empty string preset to normal (300ms)', () => {
    expect(resolveConfig({ preset: '' as any }).duration).toBe(300);
  });

  // --- easing 边界情况 ---
  it('should fallback empty easing to "ease"', () => {
    expect(resolveConfig({ easing: '' }).easing).toBe('ease');
  });

  // --- reduced-motion 集成 (Requirements 7.1, 7.2, 7.4) ---
  it('should set reducedMotion to false when preference is disabled', () => {
    expect(resolveConfig({}).reducedMotion).toBe(false);
  });

  it('should set reducedMotion to true when preference is enabled', () => {
    mockMatchMedia(true);
    expect(resolveConfig({}).reducedMotion).toBe(true);
  });

  it('should set duration and delay to 0 when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const config = resolveConfig({ duration: 500, delay: 200 });
    expect(config.duration).toBe(0);
    expect(config.delay).toBe(0);
    expect(config.reducedMotion).toBe(true);
  });

  it('should preserve easing when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const config = resolveConfig({ easing: 'linear' });
    expect(config.easing).toBe('linear');
  });

  it('should override preset duration to 0 when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const config = resolveConfig({ preset: 'slow' });
    expect(config.duration).toBe(0);
    expect(config.delay).toBe(0);
  });
});

describe('resolveConfig - Timing Scales', () => {
  beforeEach(() => { mockMatchMedia(false); setMotionLevel(undefined); });
  afterEach(() => { setMotionLevel(undefined); vi.restoreAllMocks(); });

  it('should resolve timing "t1" to 100ms', () => {
    expect(resolveConfig({ timing: 't1' }).duration).toBe(100);
  });

  it('should resolve timing "t3" to 300ms', () => {
    expect(resolveConfig({ timing: 't3' }).duration).toBe(300);
  });

  it('should resolve timing "t5" to 700ms', () => {
    expect(resolveConfig({ timing: 't5' }).duration).toBe(700);
  });

  it('should resolve timing alias "extra-fast" to t1 (100ms)', () => {
    expect(resolveConfig({ timing: 'extra-fast' }).duration).toBe(100);
  });

  it('should resolve timing alias "slow" to t4 (500ms)', () => {
    expect(resolveConfig({ timing: 'slow' }).duration).toBe(500);
  });

  it('should prioritize custom duration over timing', () => {
    expect(resolveConfig({ duration: 200, timing: 't5' }).duration).toBe(200);
  });

  it('should prioritize timing over preset', () => {
    expect(resolveConfig({ timing: 't1', preset: 'slow' }).duration).toBe(100);
  });

  it('should fallback invalid timing to default', () => {
    expect(resolveConfig({ timing: 'invalid' as any }).duration).toBe(300);
  });
});

describe('resolveConfig - Named Easing', () => {
  beforeEach(() => { mockMatchMedia(false); setMotionLevel(undefined); });
  afterEach(() => { setMotionLevel(undefined); vi.restoreAllMocks(); });

  it('should resolve named easing "productive"', () => {
    expect(resolveConfig({ easing: 'productive' }).easing).toBe('cubic-bezier(0.2, 0, 0.38, 0.9)');
  });

  it('should resolve named easing "expressive"', () => {
    expect(resolveConfig({ easing: 'expressive' }).easing).toBe('cubic-bezier(0.4, 0.14, 0.3, 1)');
  });

  it('should resolve named easing "enter"', () => {
    expect(resolveConfig({ easing: 'enter' }).easing).toBe('cubic-bezier(0, 0, 0.3, 1)');
  });

  it('should resolve named easing "exit"', () => {
    expect(resolveConfig({ easing: 'exit' }).easing).toBe('cubic-bezier(0.4, 0, 1, 1)');
  });

  it('should pass through custom CSS easing string', () => {
    expect(resolveConfig({ easing: 'cubic-bezier(0.1, 0.2, 0.3, 0.4)' }).easing)
      .toBe('cubic-bezier(0.1, 0.2, 0.3, 0.4)');
  });
});

describe('resolveConfig - Motion Intent', () => {
  beforeEach(() => { mockMatchMedia(false); setMotionLevel(undefined); });
  afterEach(() => { setMotionLevel(undefined); vi.restoreAllMocks(); });

  it('should use intent "enter" defaults (t3=300ms, enter easing)', () => {
    const config = resolveConfig({ intent: 'enter' });
    expect(config.duration).toBe(300);
    expect(config.easing).toBe('cubic-bezier(0, 0, 0.3, 1)');
  });

  it('should use intent "exit" defaults (t2=150ms, exit easing)', () => {
    const config = resolveConfig({ intent: 'exit' });
    expect(config.duration).toBe(150);
    expect(config.easing).toBe('cubic-bezier(0.4, 0, 1, 1)');
  });

  it('should use intent "feedback" defaults (t1=100ms, productive easing)', () => {
    const config = resolveConfig({ intent: 'feedback' });
    expect(config.duration).toBe(100);
    expect(config.easing).toBe('cubic-bezier(0.2, 0, 0.38, 0.9)');
  });

  it('should use intent "delight" defaults (t4=500ms, expressive easing)', () => {
    const config = resolveConfig({ intent: 'delight' });
    expect(config.duration).toBe(500);
    expect(config.easing).toBe('cubic-bezier(0.4, 0.14, 0.3, 1)');
  });

  it('should allow custom duration to override intent timing', () => {
    const config = resolveConfig({ intent: 'enter', duration: 100 });
    expect(config.duration).toBe(100);
    // easing still comes from intent
    expect(config.easing).toBe('cubic-bezier(0, 0, 0.3, 1)');
  });

  it('should allow custom easing to override intent easing', () => {
    const config = resolveConfig({ intent: 'enter', easing: 'linear' });
    expect(config.duration).toBe(300);
    expect(config.easing).toBe('linear');
  });

  it('should allow timing to override intent timing', () => {
    const config = resolveConfig({ intent: 'enter', timing: 't1' });
    expect(config.duration).toBe(100);
  });

  it('should ignore invalid intent', () => {
    const config = resolveConfig({ intent: 'invalid' as any });
    expect(config.duration).toBe(300);
    expect(config.easing).toBe('ease');
  });
});
