import { ref, watch, onUnmounted, type Ref } from 'vue';
import {
  createSpring,
  SPRING_PRESETS,
  type SpringConfig,
  type SpringPresetName,
} from '@fade-animation/core';

export interface UseSpringOptions {
  config?: SpringConfig | SpringPresetName;
  onRest?: () => void;
}

/**
 * Vue Composable：弹簧动画驱动器。
 *
 * @param active 响应式布尔值，true 时启动弹簧
 * @param options 配置选项
 * @returns 响应式弹簧进度 ref（0 到 ~1）
 *
 * @example
 * const show = ref(false);
 * const progress = useSpring(show, { config: 'bouncy' });
 * // 在 template 中: :style="{ opacity: progress, transform: `scale(${0.9 + 0.1 * progress})` }"
 */
export function useSpring(active: Ref<boolean>, options: UseSpringOptions = {}): Ref<number> {
  const { config = 'gentle', onRest } = options;
  const springConfig = typeof config === 'string' ? SPRING_PRESETS[config] : config;

  const progress = ref(0);
  let rafId: number | null = null;
  let spring = createSpring(springConfig);

  function stop() {
    if (rafId !== null) {
      cancelAnimationFrame(rafId);
      rafId = null;
    }
  }

  watch(active, (val) => {
    stop();
    if (!val) {
      progress.value = 0;
      spring.reset();
      return;
    }

    spring = createSpring(springConfig);

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

      let state = spring.current();
      while (accumulator >= FIXED_STEP) {
        state = spring.step(FIXED_STEP);
        accumulator -= FIXED_STEP;
        if (state.atRest) break;
      }

      progress.value = state.position;
      if (state.atRest) {
        rafId = null;
        onRest?.();
      } else {
        rafId = requestAnimationFrame(animate);
      }
    };
    rafId = requestAnimationFrame(animate);
  }, { immediate: true });

  onUnmounted(stop);

  return progress;
}
