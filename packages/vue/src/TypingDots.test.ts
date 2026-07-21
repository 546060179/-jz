import { describe, it, expect, afterEach, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import TypingDots from './TypingDots.vue';

describe('TypingDots (Vue)', () => {
  afterEach(() => vi.restoreAllMocks());

  it('renders 3 dots by default', () => {
    const wrapper = mount(TypingDots);
    // container + 3 dot children
    const container = wrapper.find('[role="status"]');
    expect(container.exists()).toBe(true);
    expect(container.element.children.length).toBe(3);
  });

  it('renders custom dot count', () => {
    const wrapper = mount(TypingDots, { props: { count: 5 } });
    expect(wrapper.find('[role="status"]').element.children.length).toBe(5);
  });

  it('applies background color and gap', () => {
    const wrapper = mount(TypingDots, {
      props: { backgroundColor: '#101010', gap: 10 },
    });
    const style = wrapper.find('[role="status"]').attributes('style') || '';
    expect(style).toContain('rgb(16, 16, 16)');
    expect(style).toContain('gap: 10px');
  });

  it('applies dot size and infinite pulse animation', () => {
    const wrapper = mount(TypingDots, { props: { dotSize: 6 } });
    const dot = wrapper.find('[role="status"]').element.children[0] as HTMLElement;
    expect(dot.style.width).toBe('6px');
    expect(dot.style.animation).toContain('typing-dots-pulse');
    expect(dot.style.animation).toContain('infinite');
  });

  it('has aria-label for accessibility', () => {
    const wrapper = mount(TypingDots);
    expect(wrapper.find('[role="status"]').attributes('aria-label')).toBe('Loading');
  });
});
