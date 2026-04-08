import { describe, it, expect } from 'vitest';
import { stagger } from './stagger';

describe('stagger', () => {
  it('returns empty array for count 0', () => {
    expect(stagger(0, { interval: 50 })).toEqual([]);
  });

  it('returns empty array for negative count', () => {
    expect(stagger(-1, { interval: 50 })).toEqual([]);
  });

  it('returns [0] for single element', () => {
    expect(stagger(1, { interval: 50 })).toEqual([0]);
  });

  // --- forward ---
  it('generates forward stagger delays', () => {
    expect(stagger(5, { interval: 50 })).toEqual([0, 50, 100, 150, 200]);
  });

  it('applies baseDelay to forward stagger', () => {
    expect(stagger(3, { interval: 50, baseDelay: 100 })).toEqual([100, 150, 200]);
  });

  // --- reverse ---
  it('generates reverse stagger delays', () => {
    expect(stagger(5, { interval: 50, direction: 'reverse' })).toEqual([200, 150, 100, 50, 0]);
  });

  it('applies baseDelay to reverse stagger', () => {
    expect(stagger(3, { interval: 50, baseDelay: 100, direction: 'reverse' })).toEqual([200, 150, 100]);
  });

  // --- center ---
  it('generates center stagger delays (odd count)', () => {
    expect(stagger(5, { interval: 50, direction: 'center' })).toEqual([100, 50, 0, 50, 100]);
  });

  it('generates center stagger delays (even count)', () => {
    expect(stagger(4, { interval: 50, direction: 'center' })).toEqual([75, 25, 25, 75]);
  });

  it('applies baseDelay to center stagger', () => {
    expect(stagger(3, { interval: 50, baseDelay: 200, direction: 'center' })).toEqual([250, 200, 250]);
  });

  // --- edge cases ---
  it('treats negative interval as 0', () => {
    expect(stagger(3, { interval: -10 })).toEqual([0, 0, 0]);
  });

  it('treats negative baseDelay as 0', () => {
    expect(stagger(3, { interval: 50, baseDelay: -100 })).toEqual([0, 50, 100]);
  });
});
