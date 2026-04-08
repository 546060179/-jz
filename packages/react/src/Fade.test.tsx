import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, act } from '@testing-library/react';
import React from 'react';
import { Fade } from './Fade';
import { FadeIn } from './FadeIn';
import { FadeOut } from './FadeOut';
import { setMotionLevel } from '@fade-animation/core';

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

describe('Fade (React)', () => {
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
    const { getByText } = render(<Fade>Hello</Fade>);
    expect(getByText('Hello')).toBeTruthy();
  });

  it('applies className prop', () => {
    const { container } = render(<Fade className="custom">Test</Fade>);
    expect(container.firstElementChild!.classList.contains('custom')).toBe(true);
  });

  it('starts with opacity 0 for fadeIn (default)', () => {
    const { container } = render(<Fade>Content</Fade>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0');
  });

  it('starts with opacity 1 for fadeOut (in=false)', () => {
    const { container } = render(<Fade in={false}>Content</Fade>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('1');
  });

  it('sets transition style with correct duration and easing', () => {
    const { container } = render(
      <Fade duration={500} delay={100} easing="linear">Content</Fade>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toBe('opacity 500ms linear 100ms');
  });

  it('uses preset speed for transition', () => {
    const { container } = render(<Fade preset="fast">Content</Fade>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('150ms');
  });

  it('sets transition to none when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const { container } = render(<Fade>Content</Fade>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toBe('none');
  });

  it('fires onAnimationEnd immediately when reduced-motion is enabled', () => {
    mockMatchMedia(true);
    const callback = vi.fn();
    render(<Fade onAnimationEnd={callback}>Content</Fade>);
    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('fires onAnimationEnd via safety timer when transitionend does not fire', async () => {
    const callback = vi.fn();
    render(<Fade duration={300} onAnimationEnd={callback}>Content</Fade>);

    // Advance past rAF + duration + delay + safety margin
    await act(async () => {
      vi.advanceTimersByTime(400);
    });

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('fires onAnimationEnd only once (no double-fire)', async () => {
    const callback = vi.fn();
    const { container } = render(
      <Fade duration={200} onAnimationEnd={callback}>Content</Fade>
    );
    const el = container.firstElementChild as HTMLElement;

    // Simulate transitionend
    await act(async () => {
      el.dispatchEvent(new TransitionEvent('transitionend', { propertyName: 'opacity' }));
    });

    // Also let safety timer fire
    await act(async () => {
      vi.advanceTimersByTime(300);
    });

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('ignores transitionend for non-opacity properties', async () => {
    const callback = vi.fn();
    const { container } = render(
      <Fade duration={200} onAnimationEnd={callback}>Content</Fade>
    );
    const el = container.firstElementChild as HTMLElement;

    await act(async () => {
      el.dispatchEvent(new TransitionEvent('transitionend', { propertyName: 'transform' }));
    });

    // Should not have fired yet (only safety timer would fire it)
    expect(callback).not.toHaveBeenCalled();
  });

  it('sets duration=0 and delay=0 when reduced-motion is on, even with custom values', () => {
    mockMatchMedia(true);
    const { container } = render(
      <Fade duration={500} delay={200}>Content</Fade>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toBe('none');
  });
});

describe('FadeIn (React)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders as a fade-in (opacity starts at 0)', () => {
    const { container } = render(<FadeIn>Hello</FadeIn>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('0');
  });

  it('passes through props', () => {
    const { container } = render(
      <FadeIn duration={400} className="fade-in-cls">Hello</FadeIn>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('400ms');
    expect(el.classList.contains('fade-in-cls')).toBe(true);
  });
});

describe('FadeOut (React)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders as a fade-out (opacity starts at 1)', () => {
    const { container } = render(<FadeOut>Hello</FadeOut>);
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.opacity).toBe('1');
  });

  it('passes through props', () => {
    const { container } = render(
      <FadeOut preset="slow" className="fade-out-cls">Hello</FadeOut>
    );
    const el = container.firstElementChild as HTMLElement;
    expect(el.style.transition).toContain('500ms');
    expect(el.classList.contains('fade-out-cls')).toBe(true);
  });
});


describe('Fade regression: onAnimationEnd stability', () => {
  beforeEach(() => {
    mockMatchMedia(true); // reduced motion: callback fires immediately
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it('inline onAnimationEnd with setState should not cause infinite re-renders', () => {
    let renderCount = 0;

    const Wrapper = () => {
      renderCount++;
      const [count, setCount] = React.useState(0);
      return (
        <Fade in={true} onAnimationEnd={() => setCount((c) => c + 1)}>
          Count: {count}
        </Fade>
      );
    };

    render(<Wrapper />);
    act(() => { vi.advanceTimersByTime(500); });
    expect(renderCount).toBeLessThan(5);
  });
});

describe('Fade: in prop toggle', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it('transitions correctly when toggling in from true to false', async () => {
    const Wrapper = () => {
      const [show, setShow] = React.useState(true);
      return (
        <>
          <button onClick={() => setShow(false)}>Hide</button>
          <Fade in={show} duration={300}>Content</Fade>
        </>
      );
    };

    const { container, getByText } = render(<Wrapper />);
    const fadeEl = container.querySelector('div[style]') as HTMLElement;

    expect(fadeEl.style.opacity).toBe('0');

    await act(async () => { vi.advanceTimersByTime(16); });
    expect(fadeEl.style.opacity).toBe('1');

    await act(async () => { getByText('Hide').click(); });
    expect(fadeEl.style.opacity).toBe('1');

    await act(async () => { vi.advanceTimersByTime(16); });
    expect(fadeEl.style.opacity).toBe('0');
  });
});
