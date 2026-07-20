import React, { useEffect, useCallback, useMemo, useRef, useState, type ReactNode, type CSSProperties } from 'react';
import {
  resolveConfig,
  resolveEffectStyles,
  type FadeProps,
  type MotionEffect,
  type EffectPresetName,
  EFFECT_PRESETS,
} from '@fade-animation/core';

const DEFAULT_EFFECT: MotionEffect[] = [{ type: 'fade' }];

export interface MotionProps extends Omit<FadeProps, 'in'> {
  /** 控制动画方向：true 为进入，false 为退出 */
  in?: boolean;
  /** 效果数组或预设名称 */
  effect?: MotionEffect[] | EffectPresetName;
  children?: ReactNode;
}

/**
 * 通用 Motion 组件。
 *
 * 支持 fade、scale、slide、flip、collapse 及其组合效果。
 * <Fade> 是它的特化版本（effect 固定为 fade）。
 *
 * @example
 * <Motion in={show} effect="scale-fade-in" intent="enter">
 *   <Card />
 * </Motion>
 *
 * <Motion in={show} effect={[{ type: 'fade' }, { type: 'slide', direction: 'up' }]}>
 *   <Panel />
 * </Motion>
 *
 * <Motion in={expanded} effect={[{ type: 'collapse' }]}>
 *   <CollapsibleContent />
 * </Motion>
 */
export const Motion: React.FC<MotionProps> = ({
  in: entering = true,
  effect = DEFAULT_EFFECT,
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
  const effectKey = typeof effect === 'string' ? effect : JSON.stringify(effect);
  // 缓存 effects 数组：仅当 effectKey 变化时重建，避免每次渲染新建数组
  const effects = useMemo(
    () => (typeof effect === 'string' ? [...EFFECT_PRESETS[effect]] : effect),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [effectKey],
  );
  // 缓存解析后的配置
  const config = useMemo(
    () => resolveConfig({ duration, delay, easing, preset, timing, intent }),
    [duration, delay, easing, preset, timing, intent],
  );

  // Detect if effects contain a CollapseEffect
  const collapseEffect = effects.find(e => e.type === 'collapse') as
    | (MotionEffect & { type: 'collapse'; collapsedHeight?: number })
    | undefined;
  const hasCollapse = collapseEffect !== undefined;
  const collapsedHeight = collapseEffect?.collapsedHeight ?? 0;

  // Track first render to skip initial animation (Requirement 20.4)
  const isFirstRenderRef = useRef(true);

  // Track measured content height for Collapse
  const [contentHeight, setContentHeight] = useState(0);
  // 动画进行中标记，用于开启/复位 will-change GPU 提示
  const [isAnimating, setIsAnimating] = useState(false);

  // 缓存效果样式：依赖 effects / entering / contentHeight
  const effectStyles = useMemo(
    () => resolveEffectStyles(effects, entering, hasCollapse ? contentHeight : undefined),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [effectKey, entering, contentHeight, hasCollapse],
  );

  const [currentStyles, setCurrentStyles] = useState<Record<string, string>>(() => {
    if (hasCollapse && isFirstRenderRef.current) {
      // First render: set initial state without animation (Req 20.1, 20.2)
      const baseStyles = entering ? effectStyles.to : effectStyles.from;
      if (entering) {
        // expanded=true: max-height=none to allow free content growth
        return { ...baseStyles, 'max-height': 'none' };
      } else {
        // expanded=false: max-height=collapsedHeight directly
        return { ...baseStyles, 'max-height': collapsedHeight + 'px' };
      }
    }
    return entering ? effectStyles.from : effectStyles.to;
  });

  const divRef = useRef<HTMLDivElement>(null);
  const callbackFiredRef = useRef(false);
  const safetyTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const onAnimationEndRef = useRef(onAnimationEnd);

  // Track whether we're in expanded state (max-height is "none")
  const isExpandedRef = useRef(entering && hasCollapse);

  useEffect(() => {
    onAnimationEndRef.current = onAnimationEnd;
  });

  // Measure content height via scrollHeight and observe changes with ResizeObserver (Req 11.1, 11.5, 11.6)
  useEffect(() => {
    if (!hasCollapse) return;

    const el = divRef.current;
    if (!el) return;

    // Initial measurement
    setContentHeight(el.scrollHeight);

    // Observe content size changes
    const observer = new ResizeObserver(() => {
      setContentHeight(el.scrollHeight);
    });
    observer.observe(el);

    return () => {
      observer.disconnect();
    };
  }, [hasCollapse]);

  // Handle expand/collapse animation completion for Collapse effect
  const handleCollapseTransitionEnd = useCallback(() => {
    if (!hasCollapse || !divRef.current) return;

    if (entering) {
      // Expand animation completed: set max-height to "none" (Req 11.3)
      isExpandedRef.current = true;
      setCurrentStyles(prev => ({ ...prev, 'max-height': 'none' }));
    } else {
      isExpandedRef.current = false;
    }
  }, [hasCollapse, entering]);

  // Main animation effect
  useEffect(() => {
    callbackFiredRef.current = false;

    const resolved = resolveConfig({ duration, delay, easing, preset, timing, intent });
    const resolvedEffects = typeof effect === 'string' ? [...EFFECT_PRESETS[effect]] : effect;
    const resolvedHasCollapse = resolvedEffects.some(e => e.type === 'collapse');
    const resolvedCollapseEffect = resolvedEffects.find(e => e.type === 'collapse') as
      | (MotionEffect & { type: 'collapse'; collapsedHeight?: number })
      | undefined;
    const resolvedCollapsedHeight = resolvedCollapseEffect?.collapsedHeight ?? 0;

    const styles = resolveEffectStyles(
      resolvedEffects,
      entering,
      resolvedHasCollapse ? contentHeight : undefined,
    );
    const target = entering ? styles.to : styles.from;

    // Skip animation on first render for Collapse (Req 20.4)
    if (isFirstRenderRef.current) {
      isFirstRenderRef.current = false;

      if (resolvedHasCollapse) {
        if (entering) {
          // expanded=true on mount: show fully expanded, no animation
          isExpandedRef.current = true;
          setCurrentStyles({ ...styles.to, 'max-height': 'none' });
        } else {
          // expanded=false on mount: show collapsed, no animation
          isExpandedRef.current = false;
          setCurrentStyles({ ...styles.from, 'max-height': resolvedCollapsedHeight + 'px' });
        }
        // Still fire callback for first render
        if (onAnimationEndRef.current) {
          onAnimationEndRef.current();
        }
        return;
      }
    }

    if (resolved.reducedMotion && resolved.duration === 0) {
      setIsAnimating(false);
      if (resolvedHasCollapse) {
        if (entering) {
          setCurrentStyles({ ...target, 'max-height': 'none' });
          isExpandedRef.current = true;
        } else {
          setCurrentStyles({ ...target, 'max-height': resolvedCollapsedHeight + 'px' });
          isExpandedRef.current = false;
        }
      } else {
        setCurrentStyles(target);
      }
      if (onAnimationEndRef.current && !callbackFiredRef.current) {
        callbackFiredRef.current = true;
        onAnimationEndRef.current();
      }
      return;
    }

    // For Collapse: handle the "none" → scrollHeight snap before collapsing (Req 11.4)
    if (resolvedHasCollapse && !entering && isExpandedRef.current) {
      // Snap max-height from "none" to current scrollHeight before transitioning
      const el = divRef.current;
      const currentScrollHeight = el ? el.scrollHeight : contentHeight;
      const snapStyles = { ...styles.to, 'max-height': currentScrollHeight + 'px', overflow: 'hidden' };
      setCurrentStyles(snapStyles);
      isExpandedRef.current = false;
      setIsAnimating(true);

      // Use rAF to ensure the snap is painted, then transition to collapsedHeight
      const rafId = requestAnimationFrame(() => {
        setCurrentStyles({ ...target });
      });

      const fireCallback = () => {
        setIsAnimating(false);
        if (onAnimationEndRef.current && !callbackFiredRef.current) {
          callbackFiredRef.current = true;
          handleCollapseTransitionEnd();
          onAnimationEndRef.current();
        }
      };

      const handleTransitionEnd = (e: TransitionEvent) => {
        if (styles.transitionProperties.includes(e.propertyName)) {
          fireCallback();
        }
      };

      if (el) {
        el.addEventListener('transitionend', handleTransitionEnd);
      }

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
    }

    // Standard animation path (also handles Collapse expand)
    setCurrentStyles(entering ? styles.from : styles.to);
    setIsAnimating(true);

    const rafId = requestAnimationFrame(() => {
      setCurrentStyles(target);
    });

    const fireCallback = () => {
      setIsAnimating(false);
      if (onAnimationEndRef.current && !callbackFiredRef.current) {
        callbackFiredRef.current = true;
        if (resolvedHasCollapse) {
          handleCollapseTransitionEnd();
        }
        onAnimationEndRef.current();
      }
    };

    const el = divRef.current;
    const handleTransitionEnd = (e: TransitionEvent) => {
      if (styles.transitionProperties.includes(e.propertyName)) {
        fireCallback();
      }
    };

    if (el) {
      el.addEventListener('transitionend', handleTransitionEnd);
    }

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
  }, [entering, effectKey, duration, delay, easing, preset, timing, intent, contentHeight, handleCollapseTransitionEnd]);

  const transitionValue = (() => {
    // First render with collapse: no transition
    if (hasCollapse && isFirstRenderRef.current) {
      return 'none';
    }
    if (config.reducedMotion && config.duration === 0) {
      return 'none';
    }
    return effectStyles.transitionProperties
      .map((prop) => `${prop} ${config.duration}ms ${config.easing} ${config.delay}ms`)
      .join(', ');
  })();

  // 动画进行中开启 will-change（列出正在过渡的属性），空闲时复位为 auto
  const willChangeValue =
    isAnimating && !(config.reducedMotion && config.duration === 0)
      ? effectStyles.transitionProperties.join(', ')
      : 'auto';

  const style: CSSProperties = {
    ...currentStyles,
    transition: transitionValue,
    willChange: willChangeValue,
  } as CSSProperties;

  return (
    <div ref={divRef} className={className} style={style}>
      {children}
    </div>
  );
};
