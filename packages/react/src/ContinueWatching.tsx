import React, {
  useRef,
  useEffect,
  useState,
  useCallback,
  useImperativeHandle,
  forwardRef,
  type CSSProperties,
} from 'react';
import { resolveMotionLevel, CONTINUE_WATCHING_TIMING } from '@fade-animation/core';

export type CWPhase =
  | 'hidden'
  | 'sliding-up'
  | 'banner'
  | 'fading-content'
  | 'shrinking'
  | 'morphing'
  | 'widget';

export interface ContinueWatchingProps {
  /** 封面图 URL */
  cover?: string;
  /** 标题 */
  title: string;
  /** 副标题（如 EP.1 / EP.100） */
  subtitle?: string;
  /** 挂载后自动滑入，默认 true */
  autoShow?: boolean;
  /** 自动滑入延迟（ms），默认 500 */
  autoShowDelay?: number;
  /** 展示多久后自动收缩（ms），默认 3000 */
  collapseDelay?: number;
  /** 滑入时长（ms），默认 450 */
  slideUpDuration?: number;
  /** 详情淡出时长（ms），默认 300 */
  fadeOutDuration?: number;
  /** 横条收缩时长（ms），默认 400 */
  shrinkDuration?: number;
  /** 变形为小浮窗时长（ms），默认 550 */
  morphDuration?: number;
  /** 高度（px），默认 68 */
  height?: number;
  /** 点击播放回调 */
  onPlay?: () => void;
  /** 关闭回调 */
  onDismiss?: () => void;
  /** 收缩为小浮窗完成回调 */
  onCollapsed?: () => void;
  className?: string;
}

export interface ContinueWatchingHandle {
  show: () => void;
  dismiss: () => void;
  phase: CWPhase;
}

/**
 * ContinueWatching — "最近播放"浮层组件
 *
 * 底部滑入的继续播放提示条，展示封面 + 标题 + 集数，停留数秒后自动收缩为只剩封面的
 * 小浮窗。5 阶段序列与 iOS/Android `ContinueWatchingView` 对齐：
 * sliding-up → banner（停留）→ fading-content → shrinking → morphing → widget。
 *
 * @example
 * <ContinueWatching
 *   cover="cover.jpg" title="剧名" subtitle="EP.1 / EP.100"
 *   autoShow collapseDelay={3000}
 *   onPlay={() => navigate('/player')}
 * />
 */
export const ContinueWatching = forwardRef<ContinueWatchingHandle, ContinueWatchingProps>(
  function ContinueWatching(
    {
      cover,
      title,
      subtitle,
      autoShow = true,
      autoShowDelay = 500,
      collapseDelay = CONTINUE_WATCHING_TIMING.collapseDelay,
      slideUpDuration = CONTINUE_WATCHING_TIMING.slideUpDuration,
      fadeOutDuration = CONTINUE_WATCHING_TIMING.fadeOutDuration,
      shrinkDuration = CONTINUE_WATCHING_TIMING.shrinkDuration,
      morphDuration = CONTINUE_WATCHING_TIMING.morphDuration,
      height = 68,
      onPlay,
      onDismiss,
      onCollapsed,
      className,
    },
    ref,
  ) {
    const rootRef = useRef<HTMLDivElement>(null);
    const fadeRef = useRef<HTMLDivElement>(null);
    const timers = useRef<ReturnType<typeof setTimeout>[]>([]);
    const rafRef = useRef<number | null>(null);
    const [phase, setPhase] = useState<CWPhase>('hidden');
    const phaseRef = useRef<CWPhase>('hidden');

    const setPh = (p: CWPhase) => {
      phaseRef.current = p;
      setPhase(p);
    };

    const pad = 8;
    const coverSize = height - pad * 2;
    const collapsedWidth = coverSize + pad * 2;

    const clearTimers = useCallback(() => {
      timers.current.forEach(clearTimeout);
      timers.current = [];
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }
    }, []);

    const dismiss = useCallback(() => {
      const root = rootRef.current;
      clearTimers();
      if (!root) return;
      root.style.transition = `transform ${fadeOutDuration}ms ease, opacity ${fadeOutDuration}ms ease`;
      root.style.transform = 'translateY(30px)';
      root.style.opacity = '0';
      timers.current.push(
        setTimeout(() => {
          setPh('hidden');
          onDismiss?.();
        }, fadeOutDuration),
      );
    }, [clearTimers, fadeOutDuration, onDismiss]);

    const show = useCallback(() => {
      const root = rootRef.current;
      const fadeEl = fadeRef.current;
      if (!root) return;
      clearTimers();

      const fullWidth = root.offsetWidth || 300;

      // reduced/none：静态展示 banner，不做定时收缩
      if (resolveMotionLevel() !== 'full') {
        root.style.transition = 'none';
        root.style.transform = 'none';
        root.style.opacity = '1';
        if (fadeEl) fadeEl.style.opacity = '1';
        setPh('banner');
        return;
      }

      // 阶段1: 滑入
      setPh('sliding-up');
      root.style.transition = 'none';
      root.style.transform = 'translateY(30px)';
      root.style.opacity = '0';
      root.style.width = '';
      root.style.boxShadow = 'none';
      if (fadeEl) fadeEl.style.opacity = '1';

      rafRef.current = requestAnimationFrame(() => {
        root.style.transition = `transform ${slideUpDuration}ms cubic-bezier(0,0,.3,1), opacity ${slideUpDuration}ms ease`;
        root.style.transform = 'none';
        root.style.opacity = '1';
      });

      timers.current.push(
        setTimeout(() => {
          setPh('banner');
          // 阶段2→3: 停留后详情淡出
          timers.current.push(
            setTimeout(() => {
              setPh('fading-content');
              if (fadeEl) {
                fadeEl.style.transition = `opacity ${fadeOutDuration}ms ease`;
                fadeEl.style.opacity = '0';
              }
              // 阶段4: 横条收缩
              timers.current.push(
                setTimeout(() => {
                  setPh('shrinking');
                  root.style.width = fullWidth + 'px';
                  root.style.transition = `width ${shrinkDuration}ms cubic-bezier(.42,0,.58,1)`;
                  rafRef.current = requestAnimationFrame(() => {
                    root.style.width = collapsedWidth + 'px';
                  });
                  // 阶段5: 变形为小浮窗
                  timers.current.push(
                    setTimeout(() => {
                      setPh('morphing');
                      root.style.transition = `border-radius ${morphDuration}ms ease, box-shadow ${morphDuration}ms ease`;
                      root.style.borderRadius = '10px';
                      root.style.boxShadow = '2px 3px 16px rgba(0,0,0,.4)';
                      timers.current.push(
                        setTimeout(() => {
                          setPh('widget');
                          onCollapsed?.();
                        }, morphDuration),
                      );
                    }, shrinkDuration),
                  );
                }, fadeOutDuration),
              );
            }, collapseDelay),
          );
        }, slideUpDuration),
      );
    }, [
      clearTimers,
      slideUpDuration,
      collapseDelay,
      fadeOutDuration,
      shrinkDuration,
      morphDuration,
      collapsedWidth,
      onCollapsed,
    ]);

    useImperativeHandle(ref, () => ({ show, dismiss, phase: phaseRef.current }), [show, dismiss]);

    useEffect(() => {
      if (!autoShow) return;
      const id = setTimeout(show, autoShowDelay);
      timers.current.push(id);
      return () => {
        clearTimeout(id);
        clearTimers();
      };
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const rootStyle: CSSProperties = {
      position: 'relative',
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      height,
      padding: pad,
      boxSizing: 'border-box',
      borderRadius: 12,
      background: 'rgba(20,22,33,0.92)',
      overflow: 'hidden',
      transform: 'translateY(30px)',
      opacity: 0,
      willChange: 'transform, opacity, width',
    };
    const coverStyle: CSSProperties = {
      width: coverSize,
      height: coverSize,
      flexShrink: 0,
      borderRadius: 6,
      background: cover ? `center/cover no-repeat url(${cover})` : '#186CE5',
    };
    const fadeStyle: CSSProperties = {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      flex: 1,
      minWidth: 0,
    };

    return (
      <div ref={rootRef} className={className} style={rootStyle} role="dialog" aria-label={title}>
        <div style={coverStyle} aria-hidden="true" />
        <div ref={fadeRef} style={fadeStyle}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div
              style={{
                color: '#fff',
                fontSize: 14,
                fontWeight: 600,
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {title}
            </div>
            {subtitle && (
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 12, marginTop: 2 }}>
                {subtitle}
              </div>
            )}
          </div>
          <button
            type="button"
            onClick={onPlay}
            aria-label="播放"
            style={{
              width: 40,
              height: 40,
              flexShrink: 0,
              borderRadius: '50%',
              border: 'none',
              background: '#186CE5',
              color: '#fff',
              cursor: 'pointer',
              fontSize: 14,
            }}
          >
            ▶
          </button>
          <button
            type="button"
            onClick={dismiss}
            aria-label="关闭"
            style={{
              width: 24,
              height: 24,
              flexShrink: 0,
              borderRadius: '50%',
              border: 'none',
              background: 'transparent',
              color: 'rgba(255,255,255,0.5)',
              cursor: 'pointer',
              fontSize: 12,
            }}
          >
            ✕
          </button>
        </div>
      </div>
    );
  },
);
