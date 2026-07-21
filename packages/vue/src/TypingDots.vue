<script setup lang="ts">
import { computed, type CSSProperties } from 'vue';
import { TIMING_SCALES, EASING_CURVES, stagger } from '@fade-animation/core';

const props = withDefaults(
  defineProps<{
    /** 圆点数量 */
    count?: number;
    /** 圆点直径（px） */
    dotSize?: number;
    /** 圆点间距（px） */
    gap?: number;
    /** 暗态颜色 */
    dimColor?: string;
    /** 亮态颜色（保留以对齐 React API） */
    brightColor?: string;
    /** 容器背景色 */
    backgroundColor?: string;
    /** 单个圆点动画周期（ms） */
    cycleDuration?: number;
    /** 圆点间交错延迟（ms） */
    staggerInterval?: number;
    /** 容器圆角 */
    borderRadius?: string;
    /** 容器内边距 */
    padding?: string;
    className?: string;
  }>(),
  {
    count: 3,
    dotSize: 8,
    gap: 6,
    dimColor: '#4C4B50',
    brightColor: '#828386',
    backgroundColor: '#23252A',
    cycleDuration: TIMING_SCALES.t4,
    staggerInterval: 150,
    borderRadius: '0px 12px 12px 12px',
    padding: '12px',
  },
);

// 生成唯一 keyframes 名称避免冲突
const KEYFRAMES_NAME = 'typing-dots-pulse';

// 注入全局 keyframes（仅一次，SSR 环境下跳过）
let injected = false;
function injectKeyframes() {
  if (injected || typeof document === 'undefined') return;
  const style = document.createElement('style');
  style.textContent = `
@keyframes ${KEYFRAMES_NAME} {
  0%, 100% { opacity: 0.4; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.15); }
}`;
  document.head.appendChild(style);
  injected = true;
}
injectKeyframes();

const delays = computed(() => stagger(props.count, { interval: props.staggerInterval }));
// 总动画周期 = 单点周期 + 所有交错延迟
const totalDuration = computed(() => props.cycleDuration + (props.count - 1) * props.staggerInterval);

const containerStyle = computed<CSSProperties>(() => ({
  display: 'inline-flex',
  alignItems: 'center',
  gap: `${props.gap}px`,
  padding: props.padding,
  backgroundColor: props.backgroundColor,
  borderRadius: props.borderRadius,
  height: '44px',
  boxSizing: 'border-box',
}));

function dotStyle(delayMs: number): CSSProperties {
  return {
    width: `${props.dotSize}px`,
    height: `${props.dotSize}px`,
    borderRadius: '50%',
    backgroundColor: props.dimColor,
    animation: `${KEYFRAMES_NAME} ${totalDuration.value}ms ${EASING_CURVES.expressive} ${delayMs}ms infinite`,
    willChange: 'opacity, transform',
  };
}
</script>

<template>
  <div :class="props.className" :style="containerStyle" role="status" aria-label="Loading">
    <div v-for="(d, i) in delays" :key="i" :style="dotStyle(d)" aria-hidden="true" />
  </div>
</template>
