import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { mount } from '@vue/test-utils';
import Motion from './Motion.vue';
import { setMotionLevel } from '@kinetic-motion/core';

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

describe('Motion (Vue)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    setMotionLevel(undefined);
  });
  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders slot content', () => {
    const w = mount(Motion, { slots: { default: 'Hello' } });
    expect(w.text()).toBe('Hello');
  });

  it('applies className', () => {
    const w = mount(Motion, {
      props: { className: 'mc' },
      slots: { default: 'T' },
    });
    expect(w.find('.mc').exists()).toBe(true);
  });

  it('starts with opacity 0 for entering (default)', () => {
    const w = mount(Motion, { slots: { default: 'C' } });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 0');
  });

  it('sets opacity transition for default fade', () => {
    const w = mount(Motion, {
      props: { duration: 300 },
      slots: { default: 'C' },
    });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('opacity');
    expect(style).toContain('300ms');
  });

  it('applies scale-fade-in preset', () => {
    const w = mount(Motion, {
      props: { effect: 'scale-fade-in' as any },
      slots: { default: 'C' },
    });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 0');
    expect(style).toContain('scale(0.95)');
  });

  it('applies slide-up-in preset', () => {
    const w = mount(Motion, {
      props: { effect: 'slide-up-in' as any },
      slots: { default: 'C' },
    });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('translateY(16px)');
  });

  it('uses intent for timing and easing', () => {
    const w = mount(Motion, {
      props: { intent: 'enter' as any },
      slots: { default: 'C' },
    });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('300ms');
    expect(style).toContain('cubic-bezier(0, 0, 0.3, 1)');
  });

  it('sets transition to none when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const w = mount(Motion, { slots: { default: 'C' } });
    const style = w.find('div').attributes('style') || '';
    expect(style).toContain('transition: none');
  });

  it('fires onAnimationEnd immediately when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const cb = vi.fn();
    mount(Motion, {
      props: { onAnimationEnd: cb },
      slots: { default: 'C' },
    });
    expect(cb).toHaveBeenCalledTimes(1);
  });
});
