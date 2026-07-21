import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import BubbleExpand from './BubbleExpand.vue';
import { setMotionLevel } from '@fade-animation/core';

describe('BubbleExpand (Vue)', () => {
  beforeEach(() => setMotionLevel('none'));
  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders the text', () => {
    const wrapper = mount(BubbleExpand, { props: { text: '限时免费', autoPlay: false } });
    expect(wrapper.text()).toContain('限时免费');
  });

  it('applies background and textColor', () => {
    const wrapper = mount(BubbleExpand, {
      props: { text: 'A', background: '#FF9500', textColor: '#62241B', autoPlay: false },
    });
    const span = wrapper.find('span').element as HTMLElement;
    expect(span.style.color).toBe('rgb(98, 36, 27)');
    const body = span.parentElement as HTMLElement;
    expect(body.style.background).toContain('rgb(255, 149, 0)');
  });

  it('right-anchored container aligns to flex-end', () => {
    const wrapper = mount(BubbleExpand, {
      props: { text: 'A', arrowDirection: 'right', autoPlay: false },
    });
    const style = wrapper.find('div').attributes('style') || '';
    expect(style).toContain('justify-content: flex-end');
  });

  it('shows expanded state when autoPlay=false', () => {
    const wrapper = mount(BubbleExpand, { props: { text: 'A', autoPlay: false } });
    const body = (wrapper.find('span').element as HTMLElement).parentElement as HTMLElement;
    expect(body.style.transform).toBe('scaleX(1)');
  });

  it('exposes play() which resolves to final state under reduced motion', async () => {
    const wrapper = mount(BubbleExpand, { props: { text: 'A', autoPlay: false } });
    (wrapper.vm as unknown as { play: () => void }).play();
    await wrapper.vm.$nextTick();
    const span = wrapper.find('span').element as HTMLElement;
    const body = span.parentElement as HTMLElement;
    expect(body.style.transform).toBe('scaleX(1)');
    expect(span.style.opacity).toBe('1');
  });
});
