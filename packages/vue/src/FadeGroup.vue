<script setup lang="ts">
import { computed, type VNode } from 'vue';
import { stagger, type FadeProps, type MotionIntent, type TimingScale, type TimingAlias } from '@kinetic-motion/core';
import Fade from './Fade.vue';

const props = withDefaults(
  defineProps<{
    in?: boolean;
    duration?: number;
    easing?: string;
    preset?: FadeProps['preset'];
    timing?: TimingScale | TimingAlias;
    intent?: MotionIntent;
    staggerInterval: number;
    staggerBaseDelay?: number;
    staggerDirection?: 'forward' | 'reverse' | 'center';
    onAnimationEnd?: () => void;
    className?: string;
  }>(),
  { in: true, staggerBaseDelay: 0, staggerDirection: 'forward' }
);

const slots = defineSlots<{ default(): VNode[] }>();

const childCount = computed(() => {
  const children = slots.default?.();
  return children ? children.length : 0;
});

const delays = computed(() => {
  return stagger(childCount.value, {
    interval: props.staggerInterval,
    baseDelay: props.staggerBaseDelay,
    direction: props.staggerDirection,
  });
});
</script>

<template>
  <template v-for="(child, index) in slots.default?.()" :key="index">
    <Fade
      :in="props.in" :duration="props.duration" :easing="props.easing"
      :preset="props.preset" :timing="props.timing" :intent="props.intent"
      :delay="delays[index]"
      :onAnimationEnd="index === (childCount - 1) ? props.onAnimationEnd : undefined"
      :className="props.className"
    >
      <component :is="child" />
    </Fade>
  </template>
</template>
