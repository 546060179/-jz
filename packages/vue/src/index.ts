// @kinetic-motion/vue entry point

// Generic Motion component
export { default as Motion } from './Motion.vue';

// Presence — manages enter/exit lifecycle
export { default as Presence } from './Presence.vue';

// Fade components (specialized)
export { default as Fade } from './Fade.vue';
export { default as FadeIn } from './FadeIn.vue';
export { default as FadeOut } from './FadeOut.vue';

// Choreography
export { default as FadeGroup } from './FadeGroup.vue';

// Typing Dots (marquee pulse) — 与 React 端 TypingDots 对齐
export { default as TypingDots } from './TypingDots.vue';

// Business components (对齐 iOS/Android 预置组件)
export { default as BubbleExpand } from './BubbleExpand.vue';
export { default as ContinueWatching } from './ContinueWatching.vue';

// Spring composable
export { useSpring } from './useSpring';
export type { UseSpringOptions } from './useSpring';

// Re-export types from core
export type {
  FadeProps, PresetSpeed, ResolvedFadeConfig, StaggerOptions,
  TimingScale, TimingAlias, EasingName, MotionIntent, MotionLevel,
  MotionEffect, EffectPresetName, EffectType,
} from '@kinetic-motion/core';
