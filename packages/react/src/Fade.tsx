import React, { useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { resolveConfig, type FadeProps } from '@kinetic-motion/core';

export interface FadeComponentProps extends FadeProps {
  children?: ReactNode;
}

/**
 * 统一 Fade 组件。
 * 通过 `in` 属性控制淡入/淡出方向：
 * - in=true（默认）：opacity 0 → 1（淡入）
 * - in=false：opacity 1 → 0（淡出）
 */
export const Fade: React.FC<FadeComponentProps> = ({
  in: fadeIn = true,
  duration,
  delay,
  easing,
  preset,
  timing,
  intent,
  onAnimationEnd,
  className,
  children,
}) => {
  const config = useMemo(
    () => resolveConfig({ duration, delay, easing, preset, timing, intent }),
    [duration, delay, easing, preset, timing, intent],
  );

  // Current opacity state drives the inline style
  const [opacity, setOpacity] = useState(fadeIn ? 0 : 1);
  // 动画进行中标记，用于开启/复位 will-change GPU 提示
  const [isAnimating, setIsAnimating] = useState(false);

  const divRef = useRef<HTMLDivElement>(null);
  const callbackFiredRef = useRef(false);
  const safetyTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const onAnimationEndRef = useRef(onAnimationEnd);

  // Keep the ref in sync without triggering effect re-runs
  useEffect(() => {
    onAnimationEndRef.current = onAnimationEnd;
  });

  useEffect(() => {
    // Reset the callback-fired flag for each new transition
    callbackFiredRef.current = false;

    const resolved = resolveConfig({ duration, delay, easing, preset, timing, intent });
    const targetOpacity = fadeIn ? 1 : 0;

    // If reducedMotion (duration=0), set opacity immediately and fire callback
    if (resolved.reducedMotion || resolved.duration === 0) {
      setOpacity(targetOpacity);
      setIsAnimating(false);
      if (onAnimationEndRef.current && !callbackFiredRef.current) {
        callbackFiredRef.current = true;
        onAnimationEndRef.current();
      }
      return;
    }

    // Set initial opacity (opposite of target) then transition to target
    const initialOpacity = fadeIn ? 0 : 1;
    setOpacity(initialOpacity);
    // 动画开始：开启 will-change 提示浏览器提升合成层
    setIsAnimating(true);

    // Use requestAnimationFrame to ensure the initial opacity is painted
    // before transitioning to the target
    const rafId = requestAnimationFrame(() => {
      setOpacity(targetOpacity);
    });

    const fireCallback = () => {
      // 动画结束：复位 will-change，避免常驻合成层浪费显存
      setIsAnimating(false);
      if (onAnimationEndRef.current && !callbackFiredRef.current) {
        callbackFiredRef.current = true;
        onAnimationEndRef.current();
      }
    };

    // Listen for transitionend on the div element
    const el = divRef.current;
    const handleTransitionEnd = (e: TransitionEvent) => {
      if (e.propertyName === 'opacity') {
        fireCallback();
      }
    };

    if (el) {
      el.addEventListener('transitionend', handleTransitionEnd);
    }

    // Safety net timeout: duration + delay + 50ms
    safetyTimerRef.current = setTimeout(() => {
      fireCallback();
    }, resolved.duration + resolved.delay + 50);

    return () => {
      cancelAnimationFrame(rafId);
      if (el) {
        el.removeEventListener('transitionend', handleTransitionEnd);
      }
      if (safetyTimerRef.current !== null) {
        clearTimeout(safetyTimerRef.current);
        safetyTimerRef.current = null;
      }
    };
  }, [fadeIn, duration, delay, easing, preset, timing, intent]);

  const style: React.CSSProperties = {
    opacity,
    transition:
      config.reducedMotion || config.duration === 0
        ? 'none'
        : `opacity ${config.duration}ms ${config.easing} ${config.delay}ms`,
    willChange: isAnimating ? 'opacity' : 'auto',
  };

  return (
    <div ref={divRef} className={className} style={style}>
      {children}
    </div>
  );
};
