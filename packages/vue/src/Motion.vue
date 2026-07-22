<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue';
import {
  resolveConfig,
  resolveEffectStyles,
  EFFECT_PRESETS,
  type FadeProps,
  type MotionEffect,
  type EffectPresetName,
  type MotionIntent,
  type TimingScale,
  type TimingAlias,
} from '@kinetic-motion/core';

const props = withDefaults(
  defineProps<{
    in?: boolean;
    effect?: MotionEffect[] | EffectPresetName;
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
    effect: () => [{ type: 'fade' }] as MotionEffect[],
  }
);

function getEffects(): MotionEffect[] {
  return typeof props.effect === 'string'
    ? [...EFFECT_PRESETS[props.effect as EffectPresetName]]
    : (props.effect as MotionEffect[]);
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

// --- Collapse detection ---
const effects = computed(() => getEffects());
const collapseEffect = computed(() =>
  effects.value.find(e => e.type === 'collapse') as
    | (MotionEffect & { type: 'collapse'; collapsedHeight?: number })
    | undefined
);
const hasCollapse = computed(() => collapseEffect.value !== undefined);
const collapsedHeight = computed(() => collapseEffect.value?.collapsedHeight ?? 0);

// --- First render tracking (Req 20.5) ---
// Before onMounted fires, isFirstRender is true → skip initial animation
let isFirstRender = true;

// Track whether we're in expanded state (max-height is "none")
let isExpanded = props.in && hasCollapse.value;

// Content height measured via scrollHeight (Req 11.1)
const contentHeight = ref(0);

// 动画进行中标记，用于开启/复位 will-change GPU 提示
const isAnimating = ref(false);

// Compute effect styles, passing contentHeight for Collapse
const effectStyles = computed(() =>
  resolveEffectStyles(effects.value, props.in, hasCollapse.value ? contentHeight.value : undefined)
);

// --- Initial styles ---
// For Collapse on first render: set static state without animation (Req 20.1, 20.2)
const currentStyles = ref<Record<string, string>>((() => {
  if (hasCollapse.value && isFirstRender) {
    const baseStyles = props.in ? effectStyles.value.to : effectStyles.value.from;
    if (props.in) {
      return { ...baseStyles, 'max-height': 'none' };
    } else {
      return { ...baseStyles, 'max-height': collapsedHeight.value + 'px' };
    }
  }
  return props.in ? effectStyles.value.from : effectStyles.value.to;
})());

const rootRef = ref<HTMLDivElement | null>(null);
let callbackFired = false;
let safetyTimer: ReturnType<typeof setTimeout> | null = null;
let transitionEndHandler: ((e: TransitionEvent) => void) | null = null;
let resizeObserver: ResizeObserver | null = null;
let rafId: number | null = null;

function cleanup() {
  if (safetyTimer !== null) {
    clearTimeout(safetyTimer);
    safetyTimer = null;
  }
  if (rafId !== null) {
    cancelAnimationFrame(rafId);
    rafId = null;
  }
  const el = rootRef.value;
  if (el && transitionEndHandler) {
    el.removeEventListener('transitionend', transitionEndHandler);
    transitionEndHandler = null;
  }
}

function cleanupResizeObserver() {
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
}

// Handle expand/collapse animation completion for Collapse effect
function handleCollapseTransitionEnd(entering: boolean) {
  if (!hasCollapse.value || !rootRef.value) return;
  if (entering) {
    // Expand animation completed: set max-height to "none" (Req 11.3)
    isExpanded = true;
    currentStyles.value = { ...currentStyles.value, 'max-height': 'none' };
  } else {
    isExpanded = false;
  }
}

// --- onMounted: mark first render done, set up ResizeObserver (Req 11.5, 20.5) ---
onMounted(() => {
  const el = rootRef.value;

  // Measure content height on mount (Req 11.1)
  if (hasCollapse.value && el) {
    contentHeight.value = el.scrollHeight;

    // Set up ResizeObserver to track content size changes (Req 11.5, 11.6)
    resizeObserver = new ResizeObserver(() => {
      if (el) {
        contentHeight.value = el.scrollHeight;
      }
    });
    resizeObserver.observe(el);
  }

  // Mark first render complete (Req 20.5)
  isFirstRender = false;
});

// --- Main animation watcher ---
watch(
  () => props.in,
  (entering) => {
    cleanup();
    callbackFired = false;

    const resolved = getResolvedConfig();
    const effs = getEffects();
    const resolvedHasCollapse = effs.some(e => e.type === 'collapse');
    const resolvedCollapseEffect = effs.find(e => e.type === 'collapse') as
      | (MotionEffect & { type: 'collapse'; collapsedHeight?: number })
      | undefined;
    const resolvedCollapsedHeight = resolvedCollapseEffect?.collapsedHeight ?? 0;

    const styles = resolveEffectStyles(
      effs,
      entering,
      resolvedHasCollapse ? contentHeight.value : undefined,
    );
    const target = entering ? styles.to : styles.from;

    // Skip animation on first render for Collapse (Req 20.5)
    if (isFirstRender) {
      if (resolvedHasCollapse) {
        if (entering) {
          isExpanded = true;
          currentStyles.value = { ...styles.to, 'max-height': 'none' };
        } else {
          isExpanded = false;
          currentStyles.value = { ...styles.from, 'max-height': resolvedCollapsedHeight + 'px' };
        }
        if (props.onAnimationEnd) {
          props.onAnimationEnd();
        }
        return;
      }
    }

    // Reduced motion: skip animation
    if (resolved.reducedMotion && resolved.duration === 0) {
      isAnimating.value = false;
      if (resolvedHasCollapse) {
        if (entering) {
          currentStyles.value = { ...target, 'max-height': 'none' };
          isExpanded = true;
        } else {
          currentStyles.value = { ...target, 'max-height': resolvedCollapsedHeight + 'px' };
          isExpanded = false;
        }
      } else {
        currentStyles.value = target;
      }
      if (props.onAnimationEnd && !callbackFired) {
        callbackFired = true;
        props.onAnimationEnd();
      }
      return;
    }

    // For Collapse: handle the "none" → scrollHeight snap before collapsing (Req 11.4)
    if (resolvedHasCollapse && !entering && isExpanded) {
      const el = rootRef.value;
      const currentScrollHeight = el ? el.scrollHeight : contentHeight.value;
      const snapStyles = { ...styles.to, 'max-height': currentScrollHeight + 'px', overflow: 'hidden' };
      currentStyles.value = snapStyles;
      isExpanded = false;
      isAnimating.value = true;

      // Use rAF to ensure the snap is painted, then transition to collapsedHeight
      rafId = requestAnimationFrame(() => {
        currentStyles.value = { ...target };
      });

      const fireCallback = () => {
        isAnimating.value = false;
        if (props.onAnimationEnd && !callbackFired) {
          callbackFired = true;
          handleCollapseTransitionEnd(entering);
          props.onAnimationEnd();
        }
      };

      const el2 = rootRef.value;
      transitionEndHandler = (e: TransitionEvent) => {
        if (styles.transitionProperties.includes(e.propertyName)) {
          fireCallback();
        }
      };
      if (el2) {
        el2.addEventListener('transitionend', transitionEndHandler);
      }

      safetyTimer = setTimeout(() => {
        fireCallback();
      }, resolved.duration + resolved.delay + 50);

      return;
    }

    // Standard animation path (also handles Collapse expand)
    currentStyles.value = entering ? styles.from : styles.to;
    isAnimating.value = true;

    const fireCallback = () => {
      isAnimating.value = false;
      if (props.onAnimationEnd && !callbackFired) {
        callbackFired = true;
        if (resolvedHasCollapse) {
          handleCollapseTransitionEnd(entering);
        }
        props.onAnimationEnd();
      }
    };

    nextTick(() => {
      rafId = requestAnimationFrame(() => {
        currentStyles.value = target;
      });
    });

    const el = rootRef.value;
    transitionEndHandler = (e: TransitionEvent) => {
      if (styles.transitionProperties.includes(e.propertyName)) {
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

// Re-setup ResizeObserver when hasCollapse changes
watch(hasCollapse, (newVal) => {
  cleanupResizeObserver();
  if (newVal) {
    const el = rootRef.value;
    if (el) {
      contentHeight.value = el.scrollHeight;
      resizeObserver = new ResizeObserver(() => {
        if (el) {
          contentHeight.value = el.scrollHeight;
        }
      });
      resizeObserver.observe(el);
    }
  }
});

onUnmounted(() => {
  cleanup();
  cleanupResizeObserver();
});

const inlineStyle = computed(() => {
  const config = getResolvedConfig();
  const styles = effectStyles.value;

  let transitionValue: string;
  // First render with collapse: no transition
  if (hasCollapse.value && isFirstRender) {
    transitionValue = 'none';
  } else if (config.reducedMotion && config.duration === 0) {
    transitionValue = 'none';
  } else {
    transitionValue = styles.transitionProperties
      .map((prop: string) => `${prop} ${config.duration}ms ${config.easing} ${config.delay}ms`)
      .join(', ');
  }

  const willChangeValue =
    isAnimating.value && !(config.reducedMotion && config.duration === 0)
      ? styles.transitionProperties.join(', ')
      : 'auto';

  return {
    ...currentStyles.value,
    transition: transitionValue,
    willChange: willChangeValue,
  };
});
</script>

<template>
  <div ref="rootRef" :class="props.className" :style="inlineStyle">
    <slot />
  </div>
</template>
