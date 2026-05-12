/**
 * Shared types for component documentation pages.
 * Mirrors the shape used in Desktop/index-2-1-1.html (CASES) so we can
 * migrate data 1:1 during the VitePress migration.
 */

/** A single platform implementation for a component case */
export type Platform = 'react' | 'vue' | 'swift' | 'kotlin';

/** One animation case (what we used to call a "CASE" entry) */
export interface ComponentCase {
  /** URL-safe id (lowercase, hyphen-separated) */
  id: string;
  /** Chinese display name */
  name: string;
  /** Optional emoji icon */
  icon?: string;
  /** Short one-line description shown on the card */
  desc: string;
  /** Free-form tags (for filter / search) */
  tags?: string[];

  /** Effect string (preset name or combined description) */
  effect: string;
  /** Default duration in ms */
  duration: number;
  /** Default easing — one of "enter" | "exit" | "productive" | "expressive" | "linear" or a custom label */
  easing: string;

  /** Long-form "when to use" scenario */
  scenario?: string;

  /** Per-platform code snippets (real library APIs). Keys match `Platform`. */
  react?: string;
  vue?: string;
  swift?: string;
  kotlin?: string;

  /** Known-bad patterns to avoid, shown as warnings */
  cautions?: string[];
  /** Good-to-know tips, shown as hints */
  tips?: string[];
}

/** Top-level category shown in the sidebar */
export interface Category {
  id: string;
  label: string;
  count?: number;
  /** Cases belonging to this category */
  cases: ComponentCase[];
}

/**
 * Identifies which kind of editor controls each animation supports:
 * - 'motion': standard Motion component, duration/easing/intent are tunable
 * - 'loop':   CSS / platform-native infinite loops, params are hard-coded in platform code
 * - 'native': uses platform-native primitives directly (UIProgressView etc.)
 * - 'gesture': timing is driven by user gesture velocity, not props
 * - 'custom': project-level composite component with bespoke params
 */
export type EditableKind = 'motion' | 'loop' | 'native' | 'gesture' | 'custom';

export const EDITABLE_KIND: Record<string, EditableKind> = {
  // motion — tunable
  modal: 'motion', toast: 'motion', drawer: 'motion', actionsheet: 'motion', notification: 'motion',
  'fade-in': 'motion', 'blur-in': 'motion', 'flip-in': 'motion', collapse: 'motion', 'slide-in': 'motion',
  press: 'motion', success: 'motion', insert: 'motion', 'zoom-in': 'motion',

  // loop — CSS / platform-native loops
  spinner: 'loop', pulse: 'loop', typing: 'loop', wave: 'loop', float: 'loop',
  marquee: 'loop', 'vip-shimmer': 'loop', spotlight: 'loop',

  // native — platform primitives
  shake: 'native', ripple: 'native', progress: 'native', 'count-up': 'native',

  // gesture — velocity-driven
  'drag-spring': 'gesture', 'swipe-card': 'gesture', 'pinch-zoom': 'gesture',
  'long-press': 'gesture', 'swipe-delete': 'gesture', reorder: 'gesture',

  // custom — project-level composites
  'continue-watching': 'custom', 'bubble-expand': 'custom', 'vip-flip': 'custom',
  sequence: 'custom', stagger: 'custom',
};
