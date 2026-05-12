import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { mount, flushPromises } from '@vue/test-utils';
import { defineComponent, h, ref, nextTick } from 'vue';
import Presence from './Presence.vue';
import Motion from './Motion.vue';
import { setMotionLevel } from '@fade-animation/core';

function mockMatchMedia(reducedMotion: boolean) {
  const mql = {
    matches: reducedMotion,
    media: '(prefers-reduced-motion: reduce)',
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    addListener: vi.fn(),
    removeListener: vi.fn(),
    onchange: null,
    dispatchEvent: vi.fn(),
  } as unknown as MediaQueryList;

  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockReturnValue(mql),
  });
}

describe('Presence (Vue)', () => {
  beforeEach(() => {
    mockMatchMedia(false);
    setMotionLevel(undefined);
    vi.useFakeTimers();
  });

  afterEach(() => {
    setMotionLevel(undefined);
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it('renders children when present', () => {
    const wrapper = mount(Presence, {
      slots: {
        default: () =>
          h(
            Motion,
            { key: 'a', in: true, effect: 'fade-in', duration: 100 },
            { default: () => h('div', { 'data-testid': 'a' }, 'A') },
          ),
      },
    });

    expect(wrapper.find('[data-testid="a"]').exists()).toBe(true);
  });

  it('keeps exiting child mounted until animation ends, then unmounts', async () => {
    const Harness = defineComponent({
      setup() {
        const show = ref(true);
        return { show };
      },
      render() {
        return h('div', [
          h('button', { onClick: () => (this.show = false) }, 'hide'),
          h(
            Presence,
            {},
            {
              default: () =>
                this.show
                  ? [
                      h(
                        Motion,
                        { key: 'modal', in: true, effect: 'fade-in', duration: 100 },
                        { default: () => h('div', { 'data-testid': 'modal' }, 'Modal') },
                      ),
                    ]
                  : [],
            },
          ),
        ]);
      },
    });

    const wrapper = mount(Harness);
    expect(wrapper.find('[data-testid="modal"]').exists()).toBe(true);

    await wrapper.find('button').trigger('click');
    await nextTick();

    // During exit animation, element still in DOM
    expect(wrapper.find('[data-testid="modal"]').exists()).toBe(true);

    // Wait for animation to finish
    await vi.advanceTimersByTimeAsync(200);
    await flushPromises();
    await nextTick();

    expect(wrapper.find('[data-testid="modal"]').exists()).toBe(false);
  });

  it('emits exit-complete after all children exit', async () => {
    const Harness = defineComponent({
      props: {
        onExitComplete: Function,
      },
      setup() {
        const show = ref(true);
        return { show };
      },
      render() {
        return h('div', [
          h('button', { onClick: () => (this.show = false) }, 'hide'),
          h(
            Presence,
            { onExitComplete: this.onExitComplete },
            {
              default: () =>
                this.show
                  ? [
                      h(
                        Motion,
                        { key: 'm', in: true, effect: 'fade-in', duration: 100 },
                        { default: () => h('div', 'M') },
                      ),
                    ]
                  : [],
            },
          ),
        ]);
      },
    });

    const onExitComplete = vi.fn();
    const wrapper = mount(Harness, { props: { onExitComplete } });

    await wrapper.find('button').trigger('click');
    await nextTick();
    await vi.advanceTimersByTimeAsync(200);
    await flushPromises();

    expect(onExitComplete).toHaveBeenCalledTimes(1);
  });

  it('warns when a native DOM child is passed directly', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});

    mount(Presence, {
      slots: {
        default: () => h('div', { key: 'raw', 'data-testid': 'raw' }, 'bad'),
      },
    });

    expect(warn).toHaveBeenCalled();
    const msg = warn.mock.calls[0]?.[0] as string;
    expect(msg).toContain('native DOM element');

    warn.mockRestore();
  });
});
