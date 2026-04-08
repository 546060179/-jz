import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { resolveConfig } from './resolveConfig';
import { setMotionLevel } from './reducedMotion';

function mockMatchMedia(reducedMotion: boolean) {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockReturnValue({
      matches: reducedMotion,
      media: '(prefers-reduced-motion: reduce)',
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      onchange: null,
      dispatchEvent: vi.fn(),
    }),
  });
}

describe('Motion Level', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    setMotionLevel(undefined); // reset
  });
  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('full: normal animation', () => {
    setMotionLevel('full');
    const config = resolveConfig({ duration: 500, delay: 100 });
    expect(config.duration).toBe(500);
    expect(config.delay).toBe(100);
    expect(config.reducedMotion).toBe(false);
  });

  it('reduced: clamps duration to 100ms, delay to 0', () => {
    setMotionLevel('reduced');
    const config = resolveConfig({ duration: 500, delay: 100 });
    expect(config.duration).toBe(100);
    expect(config.delay).toBe(0);
    expect(config.reducedMotion).toBe(true);
  });

  it('reduced: keeps short duration as-is', () => {
    setMotionLevel('reduced');
    const config = resolveConfig({ duration: 50 });
    expect(config.duration).toBe(50);
  });

  it('none: sets duration and delay to 0', () => {
    setMotionLevel('none');
    const config = resolveConfig({ duration: 500, delay: 100 });
    expect(config.duration).toBe(0);
    expect(config.delay).toBe(0);
    expect(config.reducedMotion).toBe(true);
  });

  it('undefined: follows system preference (no reduced motion)', () => {
    setMotionLevel(undefined);
    mockMatchMedia(false);
    const config = resolveConfig({ duration: 500 });
    expect(config.duration).toBe(500);
    expect(config.reducedMotion).toBe(false);
  });

  it('undefined: follows system preference (reduced motion)', () => {
    setMotionLevel(undefined);
    mockMatchMedia(true);
    const config = resolveConfig({ duration: 500 });
    expect(config.duration).toBe(0);
    expect(config.reducedMotion).toBe(true);
  });

  it('global override takes precedence over system preference', () => {
    mockMatchMedia(true); // system says reduce
    setMotionLevel('full'); // but we override to full
    const config = resolveConfig({ duration: 500 });
    expect(config.duration).toBe(500);
    expect(config.reducedMotion).toBe(false);
  });
});
