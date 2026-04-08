import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, act } from '@testing-library/react';
import React from 'react';
import { Motion } from './Motion';
import { setMotionLevel } from '@fade-animation/core';

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

describe('Motion (React)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    setMotionLevel(undefined);
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders children', () => {
    const { getByText } = render(<Motion>Hello</Motion>);
    expect(getByText('Hello')).toBeTruthy();
  });

  it('applies className', () => {
    const { container } = render(<Motion className="m">Test</Motion>);
    expect(container.firstElementChild!.classList.contains('m')).toBe(true);
  });

  // --- fade (default effect) ---
  it('starts with opacity 0 for entering (default)', () => {
    const { container } = render(<Motion>Content</Motion>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0');
  });

  it('sets opacity transition for default fade effect', () => {
    const { container } = render(<Motion duration={300}>Content</Motion>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('opacity');
    expect(el.style.transition).toContain('300ms');
  });

  // --- scale-fade-in preset ---
  it('applies scale-fade-in preset with opacity and transform', () => {
    const { container } = render(
      <Motion effect="scale-fade-in">Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0');
    expect(el.style.transform).toContain('scale(0.95)');
  });

  it('sets both opacity and transform transitions for scale-fade-in', () => {
    const { container } = render(
      <Motion effect="scale-fade-in" duration={400}>Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('opacity');
    expect(el.style.transition).toContain('transform');
  });

  // --- slide-up-in preset ---
  it('applies slide-up-in preset with translateY', () => {
    const { container } = render(
      <Motion effect="slide-up-in">Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0');
    expect(el.style.transform).toContain('translateY(16px)');
  });

  // --- custom effects array ---
  it('supports custom effects array', () => {
    const { container } = render(
      <Motion effect={[
        { type: 'fade', from: 0.2, to: 0.8 },
        { type: 'scale', from: 0.5, to: 1 },
      ]}>Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0.2');
    expect(el.style.transform).toContain('scale(0.5)');
  });

  // --- intent integration ---
  it('uses intent for timing and easing', () => {
    const { container } = render(
      <Motion intent="enter">Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('300ms');
    expect(el.style.transition).toContain('cubic-bezier(0, 0, 0.3, 1)');
  });

  // --- reduced motion ---
  it('sets transition to none when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const { container } = render(<Motion>Content</Motion>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toBe('none');
  });

  it('fires onAnimationEnd immediately when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const cb = vi.fn();
    render(<Motion onAnimationEnd={cb}>Content</Motion>);
    expect(cb).toHaveBeenCalledTimes(1);
  });

  // --- callback safety ---
  it('fires onAnimationEnd via safety timer', async () => {
    const cb = vi.fn();
    render(<Motion duration={200} onAnimationEnd={cb}>Content</Motion>);
    await act(async () => { vi.advanceTimersByTime(300); });
    expect(cb).toHaveBeenCalledTimes(1);
  });

  it('does not double-fire onAnimationEnd', async () => {
    const cb = vi.fn();
    const { container } = render(
      <Motion duration={200} onAnimationEnd={cb}>Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    await act(async () => {
      el.dispatchEvent(new TransitionEvent('transitionend', { propertyName: 'opacity' }));
    });
    await act(async () => { vi.advanceTimersByTime(300); });
    expect(cb).toHaveBeenCalledTimes(1);
  });

  // --- exiting ---
  it('starts with target styles when exiting', () => {
    const { container } = render(
      <Motion in={false} effect="scale-fade-out">Content</Motion>
    );
    const el = container.firstElementChild as HTMLElement;
    // scale-fade-out: from=1, to=0 for fade; from=1, to=0.95 for scale
    // exiting=false means we show "to" state initially
    expect(el.style.opacity).toBe('0');
  });
});
