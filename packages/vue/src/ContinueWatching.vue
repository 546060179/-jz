<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, type CSSProperties } from 'vue';
import { resolveMotionLevel } from '@fade-animation/core';

type CWPhase =
  | 'hidden'
  | 'sliding-up'
  | 'banner'
  | 'fading-content'
  | 'shrinking'
  | 'morphing'
  | 'widget';

const props = withDefaults(
  defineProps<{
    cover?: string;
    title: string;
    subtitle?: string;
    autoShow?: boolean;
    autoShowDelay?: number;
    collapseDelay?: number;
    slideUpDuration?: number;
    fadeOutDuration?: number;
    shrinkDuration?: number;
    morphDuration?: number;
    height?: number;
    className?: string;
  }>(),
  {
    autoShow: true,
    autoShowDelay: 500,
    collapseDelay: 3000,
    slideUpDuration: 450,
    fadeOutDuration: 300,
    shrinkDuration: 400,
    morphDuration: 550,
    height: 68,
  },
);

const emit = defineEmits<{
  (e: 'play'): void;
  (e: 'dismiss'): void;
  (e: 'collapsed'): void;
}>();

const rootRef = ref<HTMLDivElement | null>(null);
const fadeRef = ref<HTMLDivElement | null>(null);
const phase = ref<CWPhase>('hidden');

let timers: ReturnType<typeof setTimeout>[] = [];
let rafId: number | null = null;

const pad = 8;
const coverSize = computed(() => props.height - pad * 2);
const collapsedWidth = computed(() => coverSize.value + pad * 2);

function clearTimers() {
  timers.forEach(clearTimeout);
  timers = [];
  if (rafId !== null) {
    cancelAnimationFrame(rafId);
    rafId = null;
  }
}

function dismiss() {
  const root = rootRef.value;
  clearTimers();
  if (!root) return;
  root.style.transition = `transform ${props.fadeOutDuration}ms ease, opacity ${props.fadeOutDuration}ms ease`;
  root.style.transform = 'translateY(30px)';
  root.style.opacity = '0';
  timers.push(
    setTimeout(() => {
      phase.value = 'hidden';
      emit('dismiss');
    }, props.fadeOutDuration),
  );
}

function show() {
  const root = rootRef.value;
  const fadeEl = fadeRef.value;
  if (!root) return;
  clearTimers();

  const fullWidth = root.offsetWidth || 300;

  if (resolveMotionLevel() !== 'full') {
    root.style.transition = 'none';
    root.style.transform = 'none';
    root.style.opacity = '1';
    if (fadeEl) fadeEl.style.opacity = '1';
    phase.value = 'banner';
    return;
  }

  phase.value = 'sliding-up';
  root.style.transition = 'none';
  root.style.transform = 'translateY(30px)';
  root.style.opacity = '0';
  root.style.width = '';
  root.style.boxShadow = 'none';
  if (fadeEl) fadeEl.style.opacity = '1';

  rafId = requestAnimationFrame(() => {
    root.style.transition = `transform ${props.slideUpDuration}ms cubic-bezier(0,0,.3,1), opacity ${props.slideUpDuration}ms ease`;
    root.style.transform = 'none';
    root.style.opacity = '1';
  });

  timers.push(
    setTimeout(() => {
      phase.value = 'banner';
      timers.push(
        setTimeout(() => {
          phase.value = 'fading-content';
          if (fadeEl) {
            fadeEl.style.transition = `opacity ${props.fadeOutDuration}ms ease`;
            fadeEl.style.opacity = '0';
          }
          timers.push(
            setTimeout(() => {
              phase.value = 'shrinking';
              root.style.width = fullWidth + 'px';
              root.style.transition = `width ${props.shrinkDuration}ms cubic-bezier(.42,0,.58,1)`;
              rafId = requestAnimationFrame(() => {
                root.style.width = collapsedWidth.value + 'px';
              });
              timers.push(
                setTimeout(() => {
                  phase.value = 'morphing';
                  root.style.transition = `border-radius ${props.morphDuration}ms ease, box-shadow ${props.morphDuration}ms ease`;
                  root.style.borderRadius = '10px';
                  root.style.boxShadow = '2px 3px 16px rgba(0,0,0,.4)';
                  timers.push(
                    setTimeout(() => {
                      phase.value = 'widget';
                      emit('collapsed');
                    }, props.morphDuration),
                  );
                }, props.shrinkDuration),
              );
            }, props.fadeOutDuration),
          );
        }, props.collapseDelay),
      );
    }, props.slideUpDuration),
  );
}

defineExpose({ show, dismiss, phase });

onMounted(() => {
  if (props.autoShow) {
    timers.push(setTimeout(show, props.autoShowDelay));
  }
});

onUnmounted(clearTimers);

const rootStyle = computed<CSSProperties>(() => ({
  position: 'relative',
  display: 'flex',
  alignItems: 'center',
  gap: '10px',
  height: props.height + 'px',
  padding: pad + 'px',
  boxSizing: 'border-box',
  borderRadius: '12px',
  background: 'rgba(20,22,33,0.92)',
  overflow: 'hidden',
  transform: 'translateY(30px)',
  opacity: 0,
  willChange: 'transform, opacity, width',
}));
const coverStyle = computed<CSSProperties>(() => ({
  width: coverSize.value + 'px',
  height: coverSize.value + 'px',
  flexShrink: 0,
  borderRadius: '6px',
  background: props.cover ? `center/cover no-repeat url(${props.cover})` : '#186CE5',
}));
</script>

<template>
  <div ref="rootRef" :class="props.className" :style="rootStyle" role="dialog" :aria-label="title">
    <div :style="coverStyle" aria-hidden="true" />
    <div ref="fadeRef" style="display:flex;align-items:center;gap:8px;flex:1;min-width:0">
      <div style="flex:1;min-width:0">
        <div style="color:#fff;font-size:14px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">
          {{ title }}
        </div>
        <div v-if="subtitle" style="color:rgba(255,255,255,0.6);font-size:12px;margin-top:2px">
          {{ subtitle }}
        </div>
      </div>
      <button
        type="button"
        aria-label="播放"
        style="width:40px;height:40px;flex-shrink:0;border-radius:50%;border:none;background:#186CE5;color:#fff;cursor:pointer;font-size:14px"
        @click="emit('play')"
      >
        ▶
      </button>
      <button
        type="button"
        aria-label="关闭"
        style="width:24px;height:24px;flex-shrink:0;border-radius:50%;border:none;background:transparent;color:rgba(255,255,255,0.5);cursor:pointer;font-size:12px"
        @click="dismiss"
      >
        ✕
      </button>
    </div>
  </div>
</template>
