import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import ContinueWatching from './ContinueWatching.vue';
import { setMotionLevel } from '@fade-animation/core';

describe('ContinueWatching (Vue)', () => {
  beforeEach(() => setMotionLevel('none'));
  afterEach(() => {
    setMotionLevel(undefined);
    vi.restoreAllMocks();
  });

  it('renders title and subtitle', () => {
    const wrapper = mount(ContinueWatching, {
      props: { title: 'Genius Baby', subtitle: 'EP.1 / EP.100', autoShow: false },
    });
    expect(wrapper.text()).toContain('Genius Baby');
    expect(wrapper.text()).toContain('EP.1 / EP.100');
  });

  it('starts hidden (opacity 0) before show', () => {
    const wrapper = mount(ContinueWatching, { props: { title: 'T', autoShow: false } });
    const style = wrapper.find('[role="dialog"]').attributes('style') || '';
    expect(style).toContain('opacity: 0');
  });

  it('show() reveals banner under reduced motion (opacity 1)', async () => {
    const wrapper = mount(ContinueWatching, { props: { title: 'T', autoShow: false } });
    (wrapper.vm as unknown as { show: () => void }).show();
    await wrapper.vm.$nextTick();
    const root = wrapper.find('[role="dialog"]').element as HTMLElement;
    expect(root.style.opacity).toBe('1');
  });

  it('emits play when play button clicked', async () => {
    const wrapper = mount(ContinueWatching, { props: { title: 'T', autoShow: false } });
    await wrapper.find('button[aria-label="播放"]').trigger('click');
    expect(wrapper.emitted('play')).toBeTruthy();
  });

  it('emits dismiss after close button + fade duration', async () => {
    vi.useFakeTimers();
    const wrapper = mount(ContinueWatching, {
      props: { title: 'T', autoShow: false, fadeOutDuration: 300 },
    });
    await wrapper.find('button[aria-label="关闭"]').trigger('click');
    vi.advanceTimersByTime(350);
    expect(wrapper.emitted('dismiss')).toBeTruthy();
    vi.useRealTimers();
  });
});
