import { describe, it, expect } from 'vitest';
import { dynamicDuration } from './dynamicDuration';

describe('dynamicDuration', () => {
  it('returns t3 (300ms) when no params provided', () => {
    expect(dynamicDuration({})).toBe(300);
  });

  // Distance-based
  it('returns 200ms for 200px distance', () => {
    expect(dynamicDuration({ distance: 200 })).toBe(200);
  });

  it('clamps small distance to t1 (100ms)', () => {
    expect(dynamicDuration({ distance: 30 })).toBe(100);
  });

  it('clamps large distance to t5 (700ms)', () => {
    expect(dynamicDuration({ distance: 1000 })).toBe(700);
  });

  // Size-based
  it('returns t1 for small element (50px)', () => {
    expect(dynamicDuration({ size: 50 })).toBe(100);
  });

  it('returns t2 for 150px element', () => {
    expect(dynamicDuration({ size: 150 })).toBe(150);
  });

  it('returns t3 for 300px element', () => {
    expect(dynamicDuration({ size: 300 })).toBe(300);
  });

  it('returns t4 for 500px element', () => {
    expect(dynamicDuration({ size: 500 })).toBe(500);
  });

  it('returns t5 for 800px element', () => {
    expect(dynamicDuration({ size: 800 })).toBe(700);
  });

  // Combined: takes larger value
  it('takes larger of distance vs size', () => {
    expect(dynamicDuration({ distance: 150, size: 300 })).toBe(300);
  });

  // Edge cases
  it('ignores zero distance', () => {
    expect(dynamicDuration({ distance: 0 })).toBe(300);
  });

  it('ignores negative size', () => {
    expect(dynamicDuration({ size: -10 })).toBe(300);
  });
});
