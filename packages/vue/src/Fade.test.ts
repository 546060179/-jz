import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import Fade from './Fade.vue';
import FadeIn from './FadeIn.vue';
import FadeOut from './FadeOut.vue';
import { setMotionLevel } from '@kinetic-motion/core';

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
}

describe('Fade (Vue)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    setMotionLevel(undefined);
  });

  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders slot content', () => {
    const wrapper = mount(Fade, {
      slots: { default: 'Hello Vue' },
    });
    expect(wrapper.text()).toBe('Hello Vue');
  });

  it('applies className prop', () => {
    const wrapper = mount(Fade, {
      props: { className: 'my-class' },
      slots: { default: 'Test' },
    });
    expect(wrapper.find('.my-class').exists()).toBe(true);
  });

  it('starts with opacity 0 for fadeIn (default)', () => {
    const wrapper = mount(Fade, {
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 0');
  });

  it('starts with opacity 1 for fadeOut (in=false)', () => {
    const wrapper = mount(Fade, {
      props: { in: false },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 1');
  });

  it('sets transition style with correct duration and easing', () => {
    const wrapper = mount(Fade, {
      props: { duration: 500, delay: 100, easing: 'linear' },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('opacity 500ms linear 100ms');
  });

  it('uses preset speed', () => {
    const wrapper = mount(Fade, {
      props: { preset: 'slow' },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('500ms');
  });

  it('sets transition to none when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const wrapper = mount(Fade, {
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('transition: none');
  });

  it('fires onAnimationEnd immediately when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const callback = vi.fn();
    mount(Fade, {
      props: { onAnimationEnd: callback },
      slots: { default: 'Content' },
    });
    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('sets duration=0 and delay=0 when reduced-motion is on', () => {
    mockMatchMedia(true);
    const wrapper = mount(Fade, {
      props: { duration: 500, delay: 200 },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('transition: none');
  });
});

describe('FadeIn (Vue)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders as fade-in (opacity starts at 0)', () => {
    const wrapper = mount(FadeIn, {
      slots: { default: 'Hello' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 0');
  });

  it('passes through props', () => {
    const wrapper = mount(FadeIn, {
      props: { duration: 400, className: 'fi-cls' },
      slots: { default: 'Hello' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('400ms');
    expect(wrapper.find('.fi-cls').exists()).toBe(true);
  });
});

describe('FadeOut (Vue)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders as fade-out (opacity starts at 1)', () => {
    const wrapper = mount(FadeOut, {
      slots: { default: 'Hello' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('opacity: 1');
  });

  it('passes through props', () => {
    const wrapper = mount(FadeOut, {
      props: { preset: 'fast', className: 'fo-cls' },
      slots: { default: 'Hello' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('150ms');
    expect(wrapper.find('.fo-cls').exists()).toBe(true);
  });

  it('supports intent prop for automatic timing and easing', () => {
    const wrapper = mount(Fade, {
      props: { intent: 'enter' as any },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('300ms');
    expect(style).toContain('cubic-bezier(0, 0, 0.3, 1)');
  });

  it('supports timing prop', () => {
    const wrapper = mount(Fade, {
      props: { timing: 't1' as any },
      slots: { default: 'Content' },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('100ms');
  });
});
