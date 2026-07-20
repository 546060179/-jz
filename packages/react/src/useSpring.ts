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

    // 固定步长累加器：物理步长恒定 1/60s（保证数值稳定与确定性），
    // 每帧执行的步数按真实经过时间自适应，从而与屏幕刷新率无关
    // （120Hz ProMotion / 60Hz / 低刷设备表现一致，也对齐原生按时间积分的弹簧）。
    const FIXED_STEP = 1 / 60;
    let lastTime: number | null = null;
    let accumulator = 0;

    const animate = (now: number) => {
      if (lastTime === null) lastTime = now;
      let frameTime = (now - lastTime) / 1000;
      lastTime = now;
      // 防止后台标签页恢复时的巨大时间跳变导致积分器发散
      if (frameTime > 0.25) frameTime = 0.25;
      accumulator += frameTime;

      let state = springRef.current.current();
      while (accumulator >= FIXED_STEP) {
        state = springRef.current.step(FIXED_STEP);
        accumulator -= FIXED_STEP;
        if (state.atRest) break;
      }

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
