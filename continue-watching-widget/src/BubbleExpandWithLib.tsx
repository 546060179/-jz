/**
 * BubbleExpand — 使用 @fade-animation/core 动效库重构版本
 *
 * 对比原版 BubbleExpand.tsx：
 * - 原版：手写 cubic-bezier 求解器 (cubicBezierAt, makeEasing) + rAF 循环 + 手写 spring bounce
 * - 库版：使用 createSpring + useSpring + Motion 组件
 *
 * 代码量对比：
 * - 原版 easing 相关代码：~40 行（cubicBezierAt + makeEasing + easeOutBounceBack）
 * - 库版：0 行（直接用 SPRING_PRESETS.bouncy + EASING_CURVES.enter）
 */

import React, {
  useRef,
  useState,
  useEffect,
  useCallback,
  useImperativeHandle,
  forwardRef,
  type CSSProperties,
} from 'react';
import {
  createSpring,
  SPRING_PRESETS,
  EASING_CURVES,
  TIMING_SCALES,
} from '@fade-animation/core';

export interface BubbleExpandProps {
  text: string;
  background?: string;
  textColor?: string;
  fontSize?: number;
  width?: number;
  height?: number;
  borderRadius?: number;
  showArrow?: boolean;
  arrowDirection?: 'left' | 'right';
  arrowColor?: string;
  autoPlay?: boolean;
  autoPlayDelay?: number;
  onAnimationEnd?: () => void;
  onExpandEnd?: () => void;
  className?: string;
  style?: CSSProperties;
}

export interface BubbleExpandRef {
  play: () => void;
  reset: () => void;
}

export const BubbleExpandWithLib = forwardRef<BubbleExpandRef, BubbleExpandProps>(
  (
    {
      text,
      background = 'linear-gradient(90deg, #FFD1C4, #FFD75F)',
      textColor = '#62241B',
      fontSize = 10,
      width,
      height = 28,
      borderRadius = 8,
      showArrow = true,
      arrowDirection = 'right',
      arrowColor = '#FFD65A',
      autoPlay = false,
      autoPlayDelay = 300,
      onAnimationEnd,
      onExpandEnd,
      className,
      style,
    },
    ref
  ) => {
    const [phase, setPhase] = useState<'idle' | 'expanding' | 'text-fading' | 'done'>('idle');
    const containerRef = useRef<HTMLDivElement>(null);
    const textRef = useRef<HTMLSpanElement>(null);
    const arrowRef = useRef<HTMLDivElement>(null);
    const measureRef = useRef<HTMLSpanElement>(null);
    const rafRef = useRef<number>(0);
    const finalWidthRef = useRef<number>(0);
    const collapsedWidth = height;

    useEffect(() => {
      if (measureRef.current) {
        finalWidthRef.current = width ?? measureRef.current.offsetWidth + 20;
      }
    }, [text, width]);

    const play = useCallback(() => {
      if (phase !== 'idle') return;
      const el = containerRef.current;
      if (!el) return;

      setPhase('expanding');
      el.style.width = collapsedWidth + 'px';
      el.style.opacity = '1';
      if (textRef.current) { textRef.current.style.opacity = '0'; textRef.current.style.transform = 'translateX(8px)'; }
      if (arrowRef.current) arrowRef.current.style.opacity = '0';

      // ✅ 使用库的 spring 求解器替代手写 easeOutBounceBack
      const spring = createSpring(SPRING_PRESETS.bouncy);
      const targetW = finalWidthRef.current || 145;
      const dt = 1 / 60;

      function expandTick() {
        const state = spring.step(dt);
        const w = Math.max(collapsedWidth, collapsedWidth + (targetW - collapsedWidth) * state.position);
        el!.style.width = w + 'px';

        if (state.atRest) {
          el!.style.width = targetW + 'px';
          onExpandEnd?.();
          setPhase('text-fading');
          startTextFade();
          return;
        }
        rafRef.current = requestAnimationFrame(expandTick);
      }
      rafRef.current = requestAnimationFrame(expandTick);
    }, [phase, collapsedWidth, width, onExpandEnd]);

    // ✅ 文字淡入：使用库的 enter easing token，不再手写 cubic-bezier 求解器
    const startTextFade = useCallback(() => {
      const textEl = textRef.current;
      const arrowEl = arrowRef.current;
      if (!textEl) return;

      // 使用 CSS transition + 库的 easing token
      const duration = TIMING_SCALES.t3; // 300ms
      const easing = EASING_CURVES.enter; // cubic-bezier(0, 0, 0.3, 1)

      textEl.style.transition = `opacity ${duration}ms ${easing}, transform ${duration}ms ${easing}`;
      if (arrowEl) arrowEl.style.transition = `opacity ${duration}ms ${easing}`;

      requestAnimationFrame(() => {
        textEl.style.opacity = '1';
        textEl.style.transform = 'translateX(0)';
        if (arrowEl) arrowEl.style.opacity = '1';
      });

      setTimeout(() => {
        setPhase('done');
        onAnimationEnd?.();
      }, duration);
    }, [onAnimationEnd]);

    const reset = useCallback(() => {
      cancelAnimationFrame(rafRef.current);
      setPhase('idle');
      const el = containerRef.current;
      if (el) { el.style.width = collapsedWidth + 'px'; el.style.opacity = '0'; }
      if (textRef.current) { textRef.current.style.opacity = '0'; textRef.current.style.transform = 'translateX(8px)'; textRef.current.style.transition = 'none'; }
      if (arrowRef.current) { arrowRef.current.style.opacity = '0'; arrowRef.current.style.transition = 'none'; }
    }, [collapsedWidth]);

    useImperativeHandle(ref, () => ({ play, reset }), [play, reset]);

    useEffect(() => {
      if (autoPlay) {
        const t = setTimeout(play, autoPlayDelay);
        return () => clearTimeout(t);
      }
    }, [autoPlay, autoPlayDelay, play]);

    useEffect(() => () => cancelAnimationFrame(rafRef.current), []);

    const arrowBorder = arrowDirection === 'right'
      ? { borderTop: '8px solid transparent', borderBottom: '8px solid transparent', borderLeft: `9px solid ${arrowColor}`, right: '-8px' }
      : { borderTop: '8px solid transparent', borderBottom: '8px solid transparent', borderRight: `9px solid ${arrowColor}`, left: '-8px' };

    return (
      <>
        <span ref={measureRef} aria-hidden="true" style={{
          position: 'absolute', visibility: 'hidden', whiteSpace: 'nowrap',
          fontSize, fontWeight: 500, padding: '6px 8px',
        }}>{text}</span>

        <div ref={containerRef} className={className} style={{
          display: 'inline-flex', alignItems: 'center',
          height, width: collapsedWidth, borderRadius,
          background, overflow: 'hidden',
          opacity: phase === 'idle' ? 0 : 1,
          whiteSpace: 'nowrap', position: 'relative',
          ...style,
        }}>
          <span ref={textRef} style={{
            color: textColor, fontSize, fontWeight: 500,
            lineHeight: 1.4, opacity: 0, transform: 'translateX(8px)',
            padding: '6px 8px', willChange: 'opacity, transform',
          }}>{text}</span>

          {showArrow && (
            <div ref={arrowRef} style={{
              position: 'absolute', top: '50%', transform: 'translateY(-50%)',
              width: 0, height: 0, opacity: 0, ...arrowBorder,
            }} />
          )}
        </div>
      </>
    );
  }
);

BubbleExpandWithLib.displayName = 'BubbleExpandWithLib';
