import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, act } from '@testing-library/react';
import React, { createRef } from 'react';
import { ContinueWatching, type ContinueWatchingHandle } from './ContinueWatching';
import { setMotionLevel } from '@fade-animation/core';

describe('ContinueWatching (React)', () => {
  beforeEach(() => {
    setMotionLevel('none'); // 确定性：show() 走静态 banner 分支，无 rAF/多阶段计时
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders title and subtitle', () => {
    const { getByText } = render(
      <ContinueWatching title="Genius Baby" subtitle="EP.1 / EP.100" autoShow={false} />,
    );
    expect(getByText('Genius Baby')).toBeTruthy();
    expect(getByText('EP.1 / EP.100')).toBeTruthy();
  });

  it('starts hidden (opacity 0) before show', () => {
    const { container } = render(<ContinueWatching title="T" autoShow={false} />);
    const root = container.querySelector('[role="dialog"]') as HTMLElement;
    expect(root.style.opacity).toBe('0');
  });

  it('auto-shows after delay (reduced motion → static banner, opacity 1)', () => {
    const { container } = render(
      <ContinueWatching title="T" autoShow autoShowDelay={200} />,
    );
    const root = container.querySelector('[role="dialog"]') as HTMLElement;
    act(() => { vi.advanceTimersByTime(250); });
    expect(root.style.opacity).toBe('1');
  });

  it('calls onPlay when play button clicked', () => {
    const onPlay = vi.fn();
    const { getByLabelText } = render(
      <ContinueWatching title="T" autoShow={false} onPlay={onPlay} />,
    );
    act(() => { (getByLabelText('播放') as HTMLButtonElement).click(); });
    expect(onPlay).toHaveBeenCalledTimes(1);
  });

  it('calls onDismiss after close button + fade duration', () => {
    const onDismiss = vi.fn();
    const { getByLabelText } = render(
      <ContinueWatching title="T" autoShow={false} fadeOutDuration={300} onDismiss={onDismiss} />,
    );
    act(() => { (getByLabelText('关闭') as HTMLButtonElement).click(); });
    act(() => { vi.advanceTimersByTime(350); });
    expect(onDismiss).toHaveBeenCalledTimes(1);
  });

  it('exposes imperative show/dismiss via ref', () => {
    const ref = createRef<ContinueWatchingHandle>();
    const { container } = render(<ContinueWatching ref={ref} title="T" autoShow={false} />);
    const root = container.querySelector('[role="dialog"]') as HTMLElement;
    act(() => { ref.current?.show(); });
    expect(root.style.opacity).toBe('1');
  });
});
