import { describe, it, expect } from 'vitest';
import { createSpring, estimateSpringDuration, SPRING_PRESETS } from './spring';

describe('createSpring', () => {
  it('starts at position 0', () => {
    const spring = createSpring();
    expect(spring.current().position).toBe(0);
    expect(spring.current().atRest).toBe(false);
  });

  it('converges to position 1', () => {
    const spring = createSpring({ stiffness: 200, damping: 20 });
    let state = spring.current();
    for (let i = 0; i < 300; i++) {
      state = spring.step(1 / 60);
    }
    expect(state.position).toBeCloseTo(1, 2);
    expect(state.atRest).toBe(true);
  });

  it('bouncy config overshoots past 1', () => {
    const spring = createSpring(SPRING_PRESETS.bouncy);
    let maxPos = 0;
    for (let i = 0; i < 300; i++) {
      const state = spring.step(1 / 60);
      if (state.position > maxPos) maxPos = state.position;
    }
    // bouncy should overshoot past 1
    expect(maxPos).toBeGreaterThan(1.01);
  });

  it('noWobble config does not overshoot significantly', () => {
    const spring = createSpring(SPRING_PRESETS.noWobble);
    let maxPos = 0;
    for (let i = 0; i < 300; i++) {
      const state = spring.step(1 / 60);
      if (state.position > maxPos) maxPos = state.position;
    }
    // noWobble should barely overshoot
    expect(maxPos).toBeLessThan(1.05);
  });

  it('reset returns to initial state', () => {
    const spring = createSpring();
    spring.step(1 / 60);
    spring.step(1 / 60);
    spring.reset();
    expect(spring.current().position).toBe(0);
  });
});

describe('estimateSpringDuration', () => {
  it('returns reasonable duration for default config', () => {
    const dur = estimateSpringDuration();
    expect(dur).toBeGreaterThan(200);
    expect(dur).toBeLessThan(5000);
  });

  it('snappy is faster than slow', () => {
    const snappy = estimateSpringDuration(SPRING_PRESETS.snappy);
    const slow = estimateSpringDuration(SPRING_PRESETS.slow);
    expect(snappy).toBeLessThan(slow);
  });

  it('all presets converge within 5 seconds', () => {
    for (const [name, config] of Object.entries(SPRING_PRESETS)) {
      const dur = estimateSpringDuration(config);
      expect(dur, `${name} should converge`).toBeLessThan(5000);
    }
  });
});
