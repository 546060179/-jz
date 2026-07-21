<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, type CSSProperties } from 'vue';
import { resolveMotionLevel, BUBBLE_EXPAND_DEFAULTS } from '@fade-animation/core';

type BubbleArrowDirection = 'left' | 'right';

const props = withDefaults(
  defineProps<{
    /** 气泡文字 */
    text: string;
    /** 气泡背景（任意 CSS background 值） */
    background?: string;
    /** 文字颜色 */
    textColor?: string;
    /** 展开时长（ms） */
    expandDuration?: number;
    /** 文字淡入时长（ms） */
    textFadeDuration?: number;
    /** 是否显示箭头（预留） */
    showArrow?: boolean;
    /** 展开锚点方向 */
    arrowDirection?: BubbleArrowDirection;
    /** 气泡高度（px） */
    height?: number;
    /** 文字字号（px） */
    fontSize?: number;
    /** 挂载后自动播放 */
    autoPlay?: boolean;
    /** 自动播放延迟（ms） */
    autoPlayDelay?: number;
    /** 阻尼比 zeta */
    zeta?: number;
    /** 角频率 omega */
    omega?: number;
    className?: string;
  }>(),
  {
    background: '#186CE5',
    textColor: '#ffffff',
    expandDuration: BUBBLE_EXPAND_DEFAULTS.expandDuration,
    textFadeDuration: BUBBLE_EXPAND_DEFAULTS.textFadeDuration,
    showArrow: false,
    arrowDirection: 'right',
    height: 22,
    fontSize: 12,
    autoPlay: true,
    autoPlayDelay: 300,
    zeta: BUBBLE_EXPAND_DEFAULTS.zeta,
    omega: BUBBLE_EXPAND_DEFAULTS.omega,
  },
);

/** 阻尼谐振子步响应（与 iOS/Android/React 同款公式） */
function springBounce(t: number, zeta: number, omega: number): number {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  const wd = omega * Math.sqrt(1 - zeta * zeta);
  const env = Math.exp(-zeta * omega * t);
  return 1 - env * (Math.cos(wd * t) + (zeta / Math.sqrt(1 - zeta * zeta)) * Math.sin(wd * t));
}

const bodyRef = ref<HTMLDivElement | null>(null);
const textRef = ref<HTMLSpanElement | null>(null);
let rafId: number | null = null;
let autoTimer: ReturnType<typeof setTimeout> | null = null;

const origin = computed(() => (props.arrowDirection === 'right' ? 'right center' : 'left center'));
const collapsed = props.autoPlay;

function play() {
  const body = bodyRef.value;
  const txt = textRef.value;
  if (!body) return;
  if (rafId !== null) cancelAnimationFrame(rafId);

  if (resolveMotionLevel() !== 'full') {
    body.style.transform = 'scaleX(1)';
    if (txt) txt.style.opacity = '1';
    return;
  }

  body.style.transformOrigin = origin.value;
  body.style.transform = 'scaleX(0)';
  if (txt) txt.style.opacity = '0';

  const fadeStart = 1 - props.textFadeDuration / props.expandDuration;
  let t0 = 0;
  const tick = (now: number) => {
    if (!t0) t0 = now;
    const p = Math.min((now - t0) / props.expandDuration, 1);
    const s = springBounce(p, props.zeta, props.omega);
    body.style.transform = `scaleX(${Math.max(0.001, s)})`;
    if (txt && p > fadeStart) {
      txt.style.opacity = String(Math.min((p - fadeStart) / (1 - fadeStart), 1));
    }
    if (p < 1) {
      rafId = requestAnimationFrame(tick);
    } else {
      body.style.transform = 'scaleX(1)';
      if (txt) txt.style.opacity = '1';
      rafId = null;
    }
  };
  rafId = requestAnimationFrame(tick);
}

defineExpose({ play });

onMounted(() => {
  if (props.autoPlay) {
    autoTimer = setTimeout(play, props.autoPlayDelay);
  }
});

onUnmounted(() => {
  if (autoTimer !== null) clearTimeout(autoTimer);
  if (rafId !== null) cancelAnimationFrame(rafId);
});

const containerStyle = computed<CSSProperties>(() => ({
  display: 'inline-flex',
  alignItems: 'center',
  justifyContent: props.arrowDirection === 'right' ? 'flex-end' : 'flex-start',
}));
const bodyStyle = computed<CSSProperties>(() => ({
  height: props.height + 'px',
  borderRadius: '8px',
  background: props.background,
  display: 'inline-flex',
  alignItems: 'center',
  whiteSpace: 'nowrap',
  overflow: 'hidden',
  transformOrigin: origin.value,
  transform: collapsed ? 'scaleX(0)' : 'scaleX(1)',
  willChange: 'transform',
}));
const textStyle = computed<CSSProperties>(() => ({
  color: props.textColor,
  fontWeight: 700,
  fontSize: props.fontSize + 'px',
  padding: '0 12px',
  opacity: collapsed ? 0 : 1,
}));
</script>

<template>
  <div :class="props.className" :style="containerStyle">
    <div ref="bodyRef" :style="bodyStyle" :data-arrow="showArrow ? arrowDirection : undefined">
      <span ref="textRef" :style="textStyle">{{ text }}</span>
    </div>
  </div>
</template>
