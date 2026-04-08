// @fade-animation/react entry point

// Generic Motion component
export { Motion } from './Motion';
export type { MotionProps } from './Motion';

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

// Spring hook
export { useSpring } from './useSpring';
export type { UseSpringOptions } from './useSpring';
