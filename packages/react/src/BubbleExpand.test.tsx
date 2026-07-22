import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, act } from '@testing-library/react';
import React, { createRef } from 'react';
import { BubbleExpand, type BubbleExpandHandle } from './BubbleExpand';
import { setMotionLevel } from '@kinetic-motion/core';

describe('BubbleExpand (React)', () => {
  beforeEach(() => {
    setMotionLevel('none'); // 确定性：跳过 rAF 动画，直接最终态
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders the text', () => {
    const { getByText } = render(<BubbleExpand text="限时免费" autoPlay={false} />);
    expect(getByText('限时免费')).toBeTruthy();
  });

  it('applies background and textColor', () => {
    const { getByText } = render(
      <BubbleExpand text="A" background="#FF9500" textColor="#62241B" autoPlay={false} />,
    );
    const span = getByText('A') as HTMLElement;
    expect(span.style.color).toBe('rgb(98, 36, 27)');
    const body = span.parentElement as HTMLElement;
    expect(body.style.background).toContain('rgb(255, 149, 0)');
  });

  it('right-anchored container aligns to flex-end', () => {
    const { container } = render(<BubbleExpand text="A" arrowDirection="right" autoPlay={false} />);
    const wrap = container.firstElementChild as HTMLElement;
    expect(wrap.style.justifyContent).toBe('flex-end');
  });

  it('left-anchored container aligns to flex-start', () => {
    const { container } = render(<BubbleExpand text="A" arrowDirection="left" autoPlay={false} />);
    const wrap = container.firstElementChild as HTMLElement;
    expect(wrap.style.justifyContent).toBe('flex-start');
  });

  it('shows expanded state (scaleX 1, text visible) when autoPlay=false', () => {
    const { getByText } = render(<BubbleExpand text="A" autoPlay={false} />);
    const span = getByText('A') as HTMLElement;
    const body = span.parentElement as HTMLElement;
    expect(body.style.transform).toBe('scaleX(1)');
    expect(span.style.opacity).toBe('1');
  });

  it('starts collapsed when autoPlay=true, then resolves to final under reduced motion', () => {
    const { getByText } = render(<BubbleExpand text="A" autoPlay autoPlayDelay={100} />);
    const span = getByText('A') as HTMLElement;
    const body = span.parentElement as HTMLElement;
    // 初始收起
    expect(body.style.transform).toBe('scaleX(0)');
    // 到达自动播放延迟后，reduced motion 直接跳到最终态
    act(() => { vi.advanceTimersByTime(150); });
    expect(body.style.transform).toBe('scaleX(1)');
    expect(span.style.opacity).toBe('1');
  });

  it('exposes imperative play() via ref', () => {
    const ref = createRef<BubbleExpandHandle>();
    const { getByText } = render(<BubbleExpand ref={ref} text="A" autoPlay={false} />);
    const span = getByText('A') as HTMLElement;
    const body = span.parentElement as HTMLElement;
    act(() => { ref.current?.play(); });
    // reduced motion 下 play() 直接置最终态
    expect(body.style.transform).toBe('scaleX(1)');
    expect(span.style.opacity).toBe('1');
  });
});
