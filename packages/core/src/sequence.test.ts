import { describe, it, expect } from 'vitest';
import { planSequence } from './sequence';

describe('planSequence', () => {
  it('plans a single step', () => {
    const plan = planSequence([
      { effects: [{ type: 'fade', from: 0, to: 1 }] },
    ]);
    expect(plan.stepDelays).toEqual([0]);
    expect(plan.stepDurations).toEqual([300]);
    expect(plan.totalDuration).toBe(300);
  });

  it('plans sequential steps with default duration', () => {
    const plan = planSequence([
      { effects: [{ type: 'fade' }] },
      { effects: [{ type: 'scale' }] },
      { effects: [{ type: 'slide', direction: 'up' }] },
    ]);
    // step 0: delay=0, dur=300 → cumulative=300
    // step 1: delay=300, dur=300 → cumulative=600
    // step 2: delay=600, dur=300 → cumulative=900
    expect(plan.stepDelays).toEqual([0, 300, 600]);
    expect(plan.totalDuration).toBe(900);
  });

  it('respects custom step durations', () => {
    const plan = planSequence([
      { effects: [{ type: 'fade' }], duration: 200 },
      { effects: [{ type: 'scale' }], duration: 100 },
    ]);
    expect(plan.stepDelays).toEqual([0, 200]);
    expect(plan.stepDurations).toEqual([200, 100]);
    expect(plan.totalDuration).toBe(300);
  });

  it('respects step delays (gap between steps)', () => {
    const plan = planSequence([
      { effects: [{ type: 'fade' }], duration: 200 },
      { effects: [{ type: 'scale' }], delay: 50, duration: 100 },
    ]);
    // step 0: cumDelay=0, dur=200 → cumulative=200
    // step 1: cumDelay=200+50=250, dur=100 → cumulative=350
    expect(plan.stepDelays).toEqual([0, 250]);
    expect(plan.totalDuration).toBe(350);
  });

  it('uses custom default duration', () => {
    const plan = planSequence(
      [{ effects: [{ type: 'fade' }] }],
      500
    );
    expect(plan.stepDurations).toEqual([500]);
    expect(plan.totalDuration).toBe(500);
  });

  it('handles empty steps', () => {
    const plan = planSequence([]);
    expect(plan.stepDelays).toEqual([]);
    expect(plan.totalDuration).toBe(0);
  });
});
