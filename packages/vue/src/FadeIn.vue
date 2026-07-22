<script setup lang="ts">
import { type FadeProps, type MotionIntent, type TimingScale, type TimingAlias } from '@kinetic-motion/core';
import Fade from './Fade.vue';

defineProps<{
  duration?: number;
  delay?: number;
  easing?: string;
  preset?: FadeProps['preset'];
  timing?: TimingScale | TimingAlias;
  intent?: MotionIntent;
  onAnimationEnd?: () => void;
  className?: string;
}>();
</script>

<template>
  <Fade
    :in="true"
    :duration="duration"
    :delay="delay"
    :easing="easing"
    :preset="preset"
    :timing="timing"
    :intent="intent"
    :onAnimationEnd="onAnimationEnd"
    :className="className"
  >
    <slot />
  </Fade>
</template>
