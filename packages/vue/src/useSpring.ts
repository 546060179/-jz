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
    const dt = 1 / 60;

    const animate = () => {
      const state = spring.step(dt);
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
