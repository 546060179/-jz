import { describe, it, expect } from 'vitest';
import { generateCSSTokens } from './cssTokens';

describe('generateCSSTokens', () => {
  it('generates valid CSS with default prefix', () => {
    const css = generateCSSTokens();
    expect(css).toContain(':root {');
    expect(css).toContain('--motion-t1: 100ms;');
    expect(css).toContain('--motion-t3: 300ms;');
    expect(css).toContain('--motion-d1: 4px;');
    expect(css).toContain('--motion-d3: 16px;');
    expect(css).toContain('--motion-easing-productive: cubic-bezier(0.2, 0, 0.38, 0.9);');
    expect(css).toContain('--motion-easing-enter: cubic-bezier(0, 0, 0.3, 1);');
    expect(css).toContain('}');
  });

  it('supports custom prefix', () => {
    const css = generateCSSTokens('my-app');
    expect(css).toContain('--my-app-t1: 100ms;');
    expect(css).toContain('--my-app-easing-linear: linear;');
  });
});
