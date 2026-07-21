// Types
export type { PresetSpeed, FadeProps, ResolvedFadeConfig, StaggerOptions } from './types';

// Motion Design Tokens
export type { TimingScale, TimingAlias, DistanceScale, DistanceAlias, EasingName, MotionIntent } from './tokens';
export { TIMING_SCALES, TIMING_ALIASES, DISTANCE_SCALES, DISTANCE_ALIASES, EASING_CURVES, INTENT_DEFAULTS } from './tokens';

// Constants (backward compatible)
export { PRESET_SPEEDS, DEFAULTS } from './constants';

// Config resolver
export { resolveConfig } from './resolveConfig';

// Choreography
export { stagger } from './stagger';

// Reduced motion & motion level
export type { MotionLevel } from './reducedMotion';
export { getReducedMotionPreference, resolveMotionLevel, setMotionLevel, getMotionLevel, REDUCED_MAX_DURATION } from './reducedMotion';

// Dynamic duration
export { dynamicDuration } from './dynamicDuration';

// CSS token output
export { generateCSSTokens, injectCSSTokens } from './cssTokens';

// Effects system
export type { EffectType, FadeEffect, ScaleEffect, SlideEffect, RotateEffect, BlurEffect, FlipEffect, CollapseEffect, MotionEffect, EffectPresetName, SequenceStep } from './effects';
export { EFFECT_PRESETS } from './effects';
export type { EffectStyles } from './resolveEffectStyles';
export { resolveEffectStyles } from './resolveEffectStyles';

// Sequence animation
export type { SequencePlan } from './sequence';
export { planSequence } from './sequence';

// Spring physics
export type { SpringConfig, SpringState, SpringPresetName } from './spring';
export { createSpring, estimateSpringDuration, SPRING_PRESETS } from './spring';

// Business component defaults (单一事实源，跨端契约保护)
export { BUBBLE_EXPAND_DEFAULTS, CONTINUE_WATCHING_TIMING } from './componentDefaults';
