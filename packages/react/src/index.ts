// @fade-animation/react entry point

// Generic Motion component
export { Motion } from './Motion';
export type { MotionProps } from './Motion';

// Presence — manages enter/exit lifecycle
export { Presence } from './Presence';
export type { PresenceProps } from './Presence';

// Fade components (specialized)
export { Fade } from './Fade';
export type { FadeComponentProps } from './Fade';
export { FadeIn } from './FadeIn';
export type { FadeInProps } from './FadeIn';
export { FadeOut } from './FadeOut';
export type { FadeOutProps } from './FadeOut';

// Choreography
export { FadeGroup } from './FadeGroup';
export type { FadeGroupProps } from './FadeGroup';

// Typing Dots (marquee pulse)
export { TypingDots } from './TypingDots';
export type { TypingDotsProps } from './TypingDots';

// Business components (对齐 iOS/Android 预置组件)
export { BubbleExpand } from './BubbleExpand';
export type { BubbleExpandProps, BubbleExpandHandle, BubbleArrowDirection } from './BubbleExpand';
export { ContinueWatching } from './ContinueWatching';
export type { ContinueWatchingProps, ContinueWatchingHandle, CWPhase } from './ContinueWatching';

// Spring hook
export { useSpring } from './useSpring';
export type { UseSpringOptions } from './useSpring';
