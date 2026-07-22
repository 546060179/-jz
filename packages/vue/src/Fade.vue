<script setup lang="ts">
import { ref, computed, watch, onUnmounted, nextTick } from 'vue';
import { resolveConfig, type FadeProps, type MotionIntent, type TimingScale, type TimingAlias } from '@kinetic-motion/core';

const props = withDefaults(
  defineProps<{
    in?: boolean;
    duration?: number;
    delay?: number;
    easing?: string;
    preset?: FadeProps['preset'];
    timing?: TimingScale | TimingAlias;
    intent?: MotionIntent;
    onAnimationEnd?: () => void;
    className?: string;
  }>(),
  {
    in: true,
  }
);

const opacity = ref(props.in ? 0 : 1);
// 动画进行中标记，用于开启/复位 will-change GPU 提示
const isAnimating = ref(false);
const rootRef = ref<HTMLDivElement | null>(null);

let callbackFired = false;
let safetyTimer: ReturnType<typeof setTimeout> | null = null;
let transitionEndHandler: ((e: TransitionEvent) => void) | null = null;

function cleanup() {
  if (safetyTimer !== null) {
    clearTimeout(safetyTimer);
    safetyTimer = null;
  }
  const el = rootRef.value;
  if (el && transitionEndHandler) {
    el.removeEventListener('transitionend', transitionEndHandler);
    transitionEndHandler = null;
  }
}

function getResolvedConfig() {
  return resolveConfig({
    duration: props.duration,
    delay: props.delay,
    easing: props.easing,
    preset: props.preset,
    timing: props.timing,
    intent: props.intent,
  });
}

watch(
  () => props.in,
  (fadeIn) => {
    cleanup();
    callbackFired = false;

    const resolved = getResolvedConfig();
    const targetOpacity = fadeIn ? 1 : 0;

    if (resolved.reducedMotion || resolved.duration === 0) {
      opacity.value = targetOpacity;
      isAnimating.value = false;
      if (props.onAnimationEnd && !callbackFired) {
        callbackFired = true;
        props.onAnimationEnd();
      }
      return;
    }

    opacity.value = fadeIn ? 0 : 1;
    // 动画开始：开启 will-change
    isAnimating.value = true;

    const fireCallback = () => {
      // 动画结束：复位 will-change
      isAnimating.value = false;
      if (props.onAnimationEnd && !callbackFired) {
        callbackFired = true;
        props.onAnimationEnd();
      }
    };

    nextTick(() => {
      requestAnimationFrame(() => {
        opacity.value = targetOpacity;
      });
    });

    const el = rootRef.value;
    transitionEndHandler = (e: TransitionEvent) => {
      if (e.propertyName === 'opacity') {
        fireCallback();
      }
    };
    if (el) {
      el.addEventListener('transitionend', transitionEndHandler);
    }

    safetyTimer = setTimeout(() => {
      fireCallback();
    }, resolved.duration + resolved.delay + 50);
  },
  { immediate: true }
);

onUnmounted(() => {
  cleanup();
});

const inlineStyle = computed(() => {
  const config = getResolvedConfig();
  return {
    opacity: opacity.value,
    transition:
      config.reducedMotion || config.duration === 0
        ? 'none'
        : `opacity ${config.duration}ms ${config.easing} ${config.delay}ms`,
    willChange: isAnimating.value ? 'opacity' : 'auto',
  };
});
</script>

<template>
  <div ref="rootRef" :class="props.className" :style="inlineStyle">
    <slot />
  </div>
</template>
