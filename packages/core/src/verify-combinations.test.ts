import { describe, it, expect } from 'vitest';
import { resolveEffectStyles } from './resolveEffectStyles';
import type { MotionEffect } from './effects';

describe('Task 12.2 - Flip/Collapse + Fade combination verification', () => {
  it('Flip+Fade produces both transform (with perspective and rotateY) and opacity in transitionProperties', () => {
    const effects: MotionEffect[] = [
      { type: 'fade', from: 0, to: 1 },
      { type: 'flip', axis: 'y', from: 90, to: 0 },
    ];
    const result = resolveEffectStyles(effects, true);

    // transitionProperties must include both transform and opacity
    expect(result.transitionProperties).toContain('transform');
    expect(result.transitionProperties).toContain('opacity');

    // from.transform must include perspective() and rotateY()
    expect(result.from.transform).toContain('perspective(');
    expect(result.from.transform).toContain('rotateY(');

    // opacity values
    expect(result.from.opacity).toBe('0');
    expect(result.to.opacity).toBe('1');

    // Flip angles: entering=true, from=90, to=0
    expect(result.from.transform).toContain('rotateY(90deg)');
    expect(result.to.transform).toContain('rotateY(0deg)');
  });

  it('Collapse+Fade produces both max-height and opacity in transitionProperties', () => {
    const effects: MotionEffect[] = [
      { type: 'fade', from: 0, to: 1 },
      { type: 'collapse', collapsedHeight: 0 },
    ];
    const result = resolveEffectStyles(effects, true, 200);

    // transitionProperties must include both max-height and opacity
    expect(result.transitionProperties).toContain('max-height');
    expect(result.transitionProperties).toContain('opacity');

    // opacity values
    expect(result.from.opacity).toBe('0');
    expect(result.to.opacity).toBe('1');

    // max-height values: entering=true, collapsedHeight=0, contentHeight=200
    expect(result.from['max-height']).toBe('0px');
    expect(result.to['max-height']).toBe('200px');

    // overflow must be hidden
    expect(result.from.overflow).toBe('hidden');
    expect(result.to.overflow).toBe('hidden');
  });
});
