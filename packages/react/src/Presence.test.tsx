import React, { useState } from 'react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, act } from '@testing-library/react';
import { Presence } from './Presence';
import { Motion } from './Motion';

describe('Presence', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('renders children when present', () => {
    render(
      <Presence>
        <Motion key="a" in effect="fade-in" duration={100}>
          <div data-testid="a">A</div>
        </Motion>
      </Presence>,
    );
    expect(screen.getByTestId('a')).toBeDefined();
  });

  it('keeps exiting child mounted until animation ends, then unmounts', async () => {
    function Harness() {
      const [show, setShow] = useState(true);
      return (
        <>
          <button onClick={() => setShow(false)}>hide</button>
          <Presence>
            {show && (
              <Motion key="modal" in effect="fade-in" duration={100}>
                <div data-testid="modal">Modal</div>
              </Motion>
            )}
          </Presence>
        </>
      );
    }

    render(<Harness />);
    expect(screen.getByTestId('modal')).toBeDefined();

    act(() => {
      screen.getByText('hide').click();
    });

    // During exit animation, element still in DOM
    expect(screen.queryByTestId('modal')).not.toBeNull();

    await act(async () => {
      await vi.advanceTimersByTimeAsync(200);
    });

    expect(screen.queryByTestId('modal')).toBeNull();
  });

  it('fires onExitComplete after all children exit', async () => {
    const onExitComplete = vi.fn();

    function Harness() {
      const [show, setShow] = useState(true);
      return (
        <>
          <button onClick={() => setShow(false)}>hide</button>
          <Presence onExitComplete={onExitComplete}>
            {show && (
              <Motion key="m" in effect="fade-in" duration={100}>
                <div>M</div>
              </Motion>
            )}
          </Presence>
        </>
      );
    }

    render(<Harness />);
    act(() => {
      screen.getByText('hide').click();
    });
    await act(async () => {
      await vi.advanceTimersByTimeAsync(200);
    });

    expect(onExitComplete).toHaveBeenCalledTimes(1);
  });

  // --- mode="wait" ---
  it('mode="wait": next child waits for previous to finish exiting', async () => {
    function Harness() {
      const [tab, setTab] = useState<'a' | 'b'>('a');
      return (
        <>
          <button onClick={() => setTab('b')}>switch</button>
          <Presence mode="wait">
            {tab === 'a' && (
              <Motion key="a" in effect="fade-in" duration={100}>
                <div data-testid="a">A</div>
              </Motion>
            )}
            {tab === 'b' && (
              <Motion key="b" in effect="fade-in" duration={100}>
                <div data-testid="b">B</div>
              </Motion>
            )}
          </Presence>
        </>
      );
    }

    render(<Harness />);
    expect(screen.getByTestId('a')).toBeDefined();
    expect(screen.queryByTestId('b')).toBeNull();

    act(() => {
      screen.getByText('switch').click();
    });

    // Immediately after switching: A still exiting, B not yet mounted (wait mode queues it)
    expect(screen.queryByTestId('a')).not.toBeNull();
    expect(screen.queryByTestId('b')).toBeNull();

    // After A's exit finishes, B should mount
    await act(async () => {
      await vi.advanceTimersByTimeAsync(200);
    });

    expect(screen.queryByTestId('a')).toBeNull();
    expect(screen.queryByTestId('b')).not.toBeNull();
  });

  it('mode="sync" (default): A and B coexist during A\'s exit', async () => {
    function Harness() {
      const [tab, setTab] = useState<'a' | 'b'>('a');
      return (
        <>
          <button onClick={() => setTab('b')}>switch</button>
          <Presence>
            {tab === 'a' && (
              <Motion key="a" in effect="fade-in" duration={100}>
                <div data-testid="a">A</div>
              </Motion>
            )}
            {tab === 'b' && (
              <Motion key="b" in effect="fade-in" duration={100}>
                <div data-testid="b">B</div>
              </Motion>
            )}
          </Presence>
        </>
      );
    }

    render(<Harness />);
    act(() => {
      screen.getByText('switch').click();
    });

    // In sync mode both are on-screen while A exits + B enters
    expect(screen.queryByTestId('a')).not.toBeNull();
    expect(screen.queryByTestId('b')).not.toBeNull();

    await act(async () => {
      await vi.advanceTimersByTimeAsync(200);
    });

    expect(screen.queryByTestId('a')).toBeNull();
    expect(screen.queryByTestId('b')).not.toBeNull();
  });

  // --- re-entry ---
  it('re-entering during exit cancels the exit and replays enter', async () => {
    function Harness() {
      const [show, setShow] = useState(true);
      return (
        <>
          <button onClick={() => setShow((s) => !s)}>toggle</button>
          <Presence>
            {show && (
              <Motion key="m" in effect="fade-in" duration={100}>
                <div data-testid="m">M</div>
              </Motion>
            )}
          </Presence>
        </>
      );
    }

    render(<Harness />);
    expect(screen.getByTestId('m')).toBeDefined();

    // Hide it
    act(() => {
      screen.getByText('toggle').click();
    });

    // Show it again before exit finishes
    await act(async () => {
      await vi.advanceTimersByTimeAsync(30);
    });
    act(() => {
      screen.getByText('toggle').click();
    });

    // After full animation window, m should still be present (exit was cancelled)
    await act(async () => {
      await vi.advanceTimersByTimeAsync(300);
    });

    expect(screen.queryByTestId('m')).not.toBeNull();
  });

  it('warns in development when a native DOM child is passed directly', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});

    render(
      <Presence>
        <div key="raw" data-testid="raw">
          bad
        </div>
      </Presence>,
    );

    expect(warn).toHaveBeenCalled();
    const msg = warn.mock.calls[0]?.[0] as string;
    expect(msg).toContain('native DOM element');

    warn.mockRestore();
  });
});
