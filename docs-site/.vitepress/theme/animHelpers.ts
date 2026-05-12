/**
 * Shared animation helpers used by the Visual Editor and live previews.
 * These mirror `packages/core/src/tokens.ts` so the demo stays in sync
 * with the real library behavior.
 */

export const EASING_CURVES: Record<string, string> = {
  productive: 'cubic-bezier(0.2, 0, 0.38, 0.9)',
  expressive: 'cubic-bezier(0.4, 0.14, 0.3, 1)',
  enter:      'cubic-bezier(0, 0, 0.3, 1)',
  exit:       'cubic-bezier(0.4, 0, 1, 1)',
  linear:     'linear',
};

export const INTENT_DEFAULTS: Record<string, { duration: number; easing: string }> = {
  enter:    { duration: 300, easing: 'enter' },
  exit:     { duration: 150, easing: 'exit' },
  focus:    { duration: 150, easing: 'expressive' },
  feedback: { duration: 100, easing: 'productive' },
  delight:  { duration: 500, easing: 'expressive' },
};

export const EASING_OPTIONS = ['enter', 'exit', 'productive', 'expressive', 'linear'] as const;
export const INTENT_OPTIONS = ['enter', 'exit', 'focus', 'feedback', 'delight'] as const;

/** A single transition template — knows how to tween one element for a given effect */
export type PreviewTemplate = (el: HTMLElement, duration: number, easing: string) => void;

function tween(
  el: HTMLElement,
  duration: number,
  easing: string,
  props: Record<string, [string | number, string | number]>,
) {
  el.style.transition = 'none';
  Object.keys(props).forEach((k) => {
    el.style.setProperty(k === 'transform' ? 'transform' : k, String(props[k][0]));
  });
  // force reflow
  void el.offsetWidth;
  const trans = Object.keys(props)
    .map((k) => `${k} ${duration}ms ${easing}`)
    .join(', ');
  el.style.transition = trans;
  Object.keys(props).forEach((k) => {
    el.style.setProperty(k === 'transform' ? 'transform' : k, String(props[k][1]));
  });
}

export const PREVIEW_TEMPLATE: Record<string, PreviewTemplate> = {
  'fade-in':       (el, d, e) => tween(el, d, e, { opacity: [0, 1] }),
  'scale-fade-in': (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['scale(0.85)', 'scale(1)'] }),
  'slide-up-in':   (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['translateY(16px)', 'translateY(0)'] }),
  'slide-down':    (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['translateY(-16px)', 'translateY(0)'] }),
  'slide-right':   (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['translateX(-24px)', 'translateX(0)'] }),
  'slide-fade-in': (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['translateX(30px)', 'translateX(0)'] }),
  'blur-fade-in':  (el, d, e) => tween(el, d, e, { opacity: [0, 1], filter: ['blur(8px)', 'blur(0)'] }),
  'flip-y-in':     (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['perspective(200px) rotateY(90deg)', 'perspective(200px) rotateY(0)'] }),
  'collapse-in':   (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['scaleY(0)', 'scaleY(1)'] }),
  press:           (el, d, e) => {
    tween(el, d, e, { transform: ['scale(1)', 'scale(0.85)'] });
    setTimeout(() => tween(el, d * 1.5, e, { transform: ['scale(0.85)', 'scale(1)'] }), d + 50);
  },
  'zoom-in':       (el, d, e) => tween(el, d, e, { opacity: [0, 1], transform: ['scale(0.5)', 'scale(1)'] }),
};
