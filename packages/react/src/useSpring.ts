import { useEffect, useRef, useState, useCallback } from 'react';
import {
  createSpring,
  SPRING_PRESETS,
  type SpringConfig,
  type SpringPresetName,
} from '@fade-animation/core';

export interface UseSpringOptions {
  /** Spring 配置或预设名称 */
  config?: SpringConfig | SpringPresetName;
  /** 动画结束回调 */
  onRest?: () => void;
}

/**
 * React Hook：弹簧动画驱动器。
 *
 * 返回 0→1 的弹簧进度值，可用于插值任意 CSS 属性。
 *
 * @param active true 时启动弹簧动画（0→1），false 时重置到 0
 * @param options 配置选项
 * @returns 当前弹簧进度（0 到 ~1，可能超过 1 表示弹跳）
 *
 * @example
 * const progress = useSpring(show, { config: 'bouncy' });
 * <div style={{
 *   opacity: progress,
 *   transform: `scale(${0.9 + 0.1 * progress})`,
 * }}>Hello</div>
 */
export function useSpring(active: boolean, options: UseSpringOptions = {}): number {
  const { config = 'gentle', onRest } = options;
  const springConfig = typeof config === 'string' ? SPRING_PRESETS[config] : config;

  const [progress, setProgress] = useState(active ? 0 : 0);
  const springRef = useRef(createSpring(springConfig));
  const rafRef = useRef<number | null>(null);
  const onRestRef = useRef(onRest);

  useEffect(() => { onRestRef.current = onRest; });

  useEffect(() => {
    if (!active) {
      setProgress(0);
      springRef.current.reset();
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }
      return;
    }

    springRef.current = createSpring(springConfig);
    const dt = 1 / 60;

    const animate = () => {
      const state = springRef.current.step(dt);
      setProgress(state.position);

      if (state.atRest) {
        rafRef.current = null;
        onRestRef.current?.();
      } else {
        rafRef.current = requestAnimationFrame(animate);
      }
    };

    rafRef.current = requestAnimationFrame(animate);

    return () => {
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }
    };
  }, [active, springConfig.stiffness, springConfig.damping, springConfig.mass]);

  return progress;
}
