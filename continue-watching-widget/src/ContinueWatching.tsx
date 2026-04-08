import {
  useRef,
  useState,
  useEffect,
  useCallback,
  useImperativeHandle,
  forwardRef,
  type CSSProperties,
} from 'react';

// ─── Types ───────────────────────────────────────────────────────────
export interface ContinueWatchingProps {
  /** Cover image URL */
  cover: string;
  /** Title text */
  title: string;
  /** Subtitle / episode info, e.g. "EP.1 / EP.100" */
  subtitle?: string;
  /** Auto-show on mount (default: false) */
  autoShow?: boolean;
  /** Delay before auto-show in ms (default: 500) */
  autoShowDelay?: number;
  /** Delay before auto-collapse in ms (default: 3000) */
  collapseDelay?: number;
  /** Duration of content fade-out in ms (default: 300) */
  fadeOutDuration?: number;
  /** Duration of banner shrink in ms (default: 400) */
  shrinkDuration?: number;
  /** Duration of morph-to-widget in ms (default: 550) */
  morphDuration?: number;
  /** Duration of slide-up in ms (default: 450) */
  slideUpDuration?: number;
  /** Duration of dismiss animation in ms (default: 300) */
  dismissDuration?: number;
  /** Widget size in px (default: { width: 90, height: 120 }) */
  widgetSize?: { width: number; height: number };
  /** Widget position relative to container bottom-left (default: { left: 0, bottom: 91 }) */
  widgetPosition?: { left: number; bottom: number };
  /** Banner cover size in px (default: { width: 44.35, height: 60 }) */
  coverSize?: { width: number; height: number };
  /** Called when play is clicked (banner or widget) */
  onPlay?: () => void;
  /** Called when dismissed */
  onDismiss?: () => void;
  /** Called when banner finishes collapsing into widget */
  onCollapsed?: () => void;
  /** Called when banner is fully visible */
  onShow?: () => void;
  /** Custom class on the root container */
  className?: string;
  /** Custom style on the root container */
  style?: CSSProperties;
}

export interface ContinueWatchingRef {
  /** Show the banner with slide-up animation */
  show: () => void;
  /** Dismiss the widget with scale-down animation */
  dismiss: () => void;
  /** Manually trigger collapse (skip the wait) */
  collapse: () => void;
  /** Current animation phase */
  getPhase: () => Phase;
}

export type Phase =
  | 'hidden'
  | 'sliding-up'
  | 'banner'
  | 'fading-content'
  | 'shrinking'
  | 'morphing'
  | 'widget'
  | 'dismissing';

// ─── Easing Functions ────────────────────────────────────────────────
function lerp(a: number, b: number, t: number) { return a + (b - a) * t; }
function easeOutCubic(t: number) { return 1 - Math.pow(1 - t, 3); }
function easeInOutCubic(t: number) { return t < 0.5 ? 4*t*t*t : 1 - Math.pow(-2*t+2, 3)/2; }
function easeOutBack(t: number) {
  const c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

// ─── Component ───────────────────────────────────────────────────────
export const ContinueWatching = forwardRef<ContinueWatchingRef, ContinueWatchingProps>(
  (
    {
      cover,
      title,
      subtitle,
      autoShow = false,
      autoShowDelay = 500,
      collapseDelay = 3000,
      fadeOutDuration = 300,
      shrinkDuration = 400,
      morphDuration = 550,
      slideUpDuration = 450,
      dismissDuration = 300,
      widgetSize = { width: 90, height: 120 },
      widgetPosition = { left: 0, bottom: 91 },
      coverSize = { width: 44.35, height: 60 },
      onPlay,
      onDismiss,
      onCollapsed,
      onShow,
      className,
      style,
    },
    ref,
  ) => {
    const [phase, setPhase] = useState<Phase>('hidden');
    const phaseRef = useRef<Phase>('hidden');
    const rafRef = useRef<number>(0);
    const timerRef = useRef<ReturnType<typeof setTimeout>>();
    const elRef = useRef<HTMLDivElement>(null);
    const infoRef = useRef<HTMLDivElement>(null);
    const playBtnRef = useRef<HTMLButtonElement>(null);
    const closeBtnRef = useRef<HTMLButtonElement>(null);
    const widgetPlayRef = useRef<HTMLButtonElement>(null);
    const widgetCloseRef = useRef<HTMLButtonElement>(null);

    const setP = useCallback((p: Phase) => {
      phaseRef.current = p;
      setPhase(p);
    }, []);

    // Banner dimensions (derived from cover + padding)
    const BANNER_H = coverSize.height + 8; // 4px top + 4px bottom padding
    const COLLAPSED_W = coverSize.width + 8;
    const COLLAPSED_H = coverSize.height + 8;

    // ── Core animation runner ──
    const runAnimation = useCallback((startPhase: 'slide-up' | 'fade-content') => {
      const el = elRef.current;
      if (!el) return;

      let animPhase: string = startPhase;
      let phaseStart = 0;

      function tick(now: number) {
        if (phaseRef.current === 'hidden' || !el) return;
        if (!phaseStart) phaseStart = now;
        const elapsed = now - phaseStart;

        if (animPhase === 'slide-up') {
          const t = Math.min(elapsed / slideUpDuration, 1);
          const e = easeOutCubic(t);
          el.style.transform = `translateY(${(1 - e) * 100}%)`;
          el.style.opacity = String(Math.min(t * 3, 1));

          if (t >= 1) {
            el.style.transform = 'none';
            el.style.opacity = '1';
            setP('banner');
            onShow?.();
            // Auto-collapse after delay
            timerRef.current = setTimeout(() => {
              if (phaseRef.current === 'banner') {
                setP('fading-content');
                animPhase = 'fade-content';
                phaseStart = 0;
                rafRef.current = requestAnimationFrame(tick);
              }
            }, collapseDelay);
            return;
          }
        }
        else if (animPhase === 'fade-content') {
          const t = Math.min(elapsed / fadeOutDuration, 1);
          const e = easeOutCubic(t);
          // Fade out info, play button, close button
          if (infoRef.current) infoRef.current.style.opacity = String(1 - e);
          if (playBtnRef.current) playBtnRef.current.style.opacity = String(1 - e);
          if (closeBtnRef.current) closeBtnRef.current.style.opacity = String(1 - e);

          if (t >= 1) {
            animPhase = 'shrink';
            phaseStart = now;
            setP('shrinking');
          }
        }
        else if (animPhase === 'shrink') {
          const t = Math.min(elapsed / shrinkDuration, 1);
          const e = easeInOutCubic(t);
          const parentW = el.parentElement?.clientWidth || 375;

          el.style.width = lerp(parentW, COLLAPSED_W, e) + 'px';
          el.style.height = lerp(BANNER_H, COLLAPSED_H, e) + 'px';
          el.style.borderRadius = t < 0.5 ? '8px 8px 0 0' : `${lerp(8, 4, (t - 0.5) * 2)}px`;
          el.style.padding = `${lerp(4, 0, e)}px ${lerp(16, 0, e)}px ${lerp(4, 0, e)}px ${lerp(4, 0, e)}px`;

          // Fade out background in second half
          const bgOpacity = lerp(1, 0, Math.max(0, (t - 0.5) * 2));
          el.style.background = `rgba(38, 40, 46, ${bgOpacity})`;

          if (t >= 1) {
            animPhase = 'morph';
            phaseStart = now;
            setP('morphing');
            // Reset for morph phase
            el.style.padding = '0';
            el.style.overflow = 'visible';
            el.style.background = 'none';
          }
        }
        else if (animPhase === 'morph') {
          const t = Math.min(elapsed / morphDuration, 1);
          const e = easeOutBack(t);
          const eSmooth = easeOutCubic(t);

          el.style.left = lerp(0, widgetPosition.left, e) + 'px';
          el.style.bottom = lerp(0, widgetPosition.bottom, e) + 'px';
          el.style.width = lerp(COLLAPSED_W, widgetSize.width, e) + 'px';
          el.style.height = lerp(COLLAPSED_H, widgetSize.height, e) + 'px';
          el.style.borderRadius = lerp(4, 8, eSmooth) + 'px';
          el.style.boxShadow = `4px 4px 16px rgba(0,0,0,${eSmooth * 0.4})`;
          el.style.border = `1px solid rgba(255,255,255,${eSmooth * 0.15})`;

          if (t >= 1) {
            setP('widget');
            el.style.pointerEvents = 'auto';
            onCollapsed?.();
            // Fade in widget buttons
            if (widgetPlayRef.current) widgetPlayRef.current.style.opacity = '1';
            if (widgetCloseRef.current) widgetCloseRef.current.style.opacity = '1';
            return;
          }
        }

        rafRef.current = requestAnimationFrame(tick);
      }

      rafRef.current = requestAnimationFrame(tick);
    }, [
      slideUpDuration, collapseDelay, fadeOutDuration, shrinkDuration,
      morphDuration, widgetSize, widgetPosition, coverSize,
      BANNER_H, COLLAPSED_W, COLLAPSED_H, onShow, onCollapsed, setP,
    ]);

    // ── Show ──
    const show = useCallback(() => {
      if (phaseRef.current !== 'hidden') return;
      setP('sliding-up');
      runAnimation('slide-up');
    }, [runAnimation, setP]);

    // ── Collapse (skip wait) ──
    const collapse = useCallback(() => {
      if (phaseRef.current !== 'banner') return;
      clearTimeout(timerRef.current);
      cancelAnimationFrame(rafRef.current);
      setP('fading-content');
      runAnimation('fade-content');
    }, [runAnimation, setP]);

    // ── Dismiss ──
    const dismiss = useCallback(() => {
      if (phaseRef.current !== 'widget') return;
      setP('dismissing');
      const el = elRef.current;
      if (!el) return;
      el.style.pointerEvents = 'none';

      let start = 0;
      function tick(now: number) {
        if (!el) return;
        if (!start) start = now;
        const t = Math.min((now - start) / dismissDuration, 1);
        const e = easeOutCubic(t);
        el.style.opacity = String(1 - e);
        el.style.transform = `scale(${lerp(1, 0.7, e)}) translateY(${lerp(0, 30, e)}px)`;

        if (t >= 1) {
          setP('hidden');
          onDismiss?.();
          return;
        }
        rafRef.current = requestAnimationFrame(tick);
      }
      rafRef.current = requestAnimationFrame(tick);
    }, [dismissDuration, onDismiss, setP]);

    // ── Imperative API ──
    useImperativeHandle(ref, () => ({
      show,
      dismiss,
      collapse,
      getPhase: () => phaseRef.current,
    }), [show, dismiss, collapse]);

    // ── Auto-show ──
    useEffect(() => {
      if (autoShow) {
        const t = setTimeout(show, autoShowDelay);
        return () => clearTimeout(t);
      }
    }, [autoShow, autoShowDelay, show]);

    // ── Cleanup ──
    useEffect(() => () => {
      clearTimeout(timerRef.current);
      cancelAnimationFrame(rafRef.current);
    }, []);

    if (phase === 'hidden') return null;

    const isBannerPhase = phase === 'sliding-up' || phase === 'banner' || phase === 'fading-content' || phase === 'shrinking';
    const isMorphOrWidget = phase === 'morphing' || phase === 'widget' || phase === 'dismissing';

    return (
      <div
        className={`rcw-root${className ? ` ${className}` : ''}`}
        style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 20, ...style }}
      >
        <div
          ref={elRef}
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            ...(isBannerPhase ? {
              right: 0,
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '4px 16px 4px 4px',
              background: '#26282E',
              borderRadius: '8px 8px 0 0',
              overflow: 'hidden',
              transform: 'translateY(100%)',
              opacity: 0,
              pointerEvents: 'auto' as const,
            } : {}),
            ...(isMorphOrWidget ? {
              overflow: 'visible',
              pointerEvents: phase === 'widget' ? 'auto' as const : 'none' as const,
            } : {}),
          }}
        >
          {/* Cover image — always visible */}
          <img
            src={cover}
            alt=""
            style={{
              ...(isBannerPhase ? {
                width: coverSize.width,
                height: coverSize.height,
                borderRadius: 4,
                objectFit: 'cover' as const,
                display: 'block',
                flexShrink: 0,
              } : {
                width: '100%',
                height: '100%',
                objectFit: 'cover' as const,
                display: 'block',
                borderRadius: 'inherit',
              }),
            }}
          />

          {/* Banner info — only during banner phases */}
          {isBannerPhase && (
            <>
              <div
                ref={infoRef}
                style={{
                  display: 'flex', flexDirection: 'column', gap: 2,
                  flex: 1, minWidth: 0, overflow: 'hidden',
                }}
              >
                <div style={{
                  fontSize: 12, fontWeight: 600, color: '#fff', lineHeight: 1.33,
                  whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                }}>{title}</div>
                {subtitle && (
                  <div style={{ fontSize: 10, fontWeight: 500, color: '#9F9FA2', lineHeight: 1.6 }}>
                    {subtitle}
                  </div>
                )}
              </div>
              <button
                ref={playBtnRef}
                onClick={onPlay}
                aria-label="Play"
                style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', lineHeight: 0, flexShrink: 0 }}
              >
                <svg width="32" height="32" viewBox="0 0 32 32">
                  <circle cx="16" cy="16" r="16" fill="#F6610F" />
                  <path d="M13 9.5V22.5L24 16L13 9.5Z" fill="#fff" />
                </svg>
              </button>
              <button
                ref={closeBtnRef}
                onClick={() => { clearTimeout(timerRef.current); collapse(); }}
                aria-label="Close"
                style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', lineHeight: 0, flexShrink: 0 }}
              >
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                  <line x1="4" y1="4" x2="16" y2="16" stroke="#9F9FA2" strokeWidth="1.5" strokeLinecap="round" />
                  <line x1="16" y1="4" x2="4" y2="16" stroke="#9F9FA2" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
              </button>
            </>
          )}

          {/* Widget overlay buttons — only during widget phase */}
          {isMorphOrWidget && (
            <>
              <button
                ref={widgetPlayRef}
                onClick={onPlay}
                aria-label="Play"
                style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  background: 'none', border: 'none', padding: 0,
                  cursor: 'pointer', lineHeight: 0, opacity: 0,
                  transition: 'opacity 0.35s ease',
                }}
              >
                <svg width="38" height="38" viewBox="0 0 38 38">
                  <circle cx="19" cy="19" r="19" fill="rgba(0,0,0,0.45)" />
                  <path d="M15.5 11V27L28 19L15.5 11Z" fill="#fff" />
                </svg>
              </button>
              <button
                ref={widgetCloseRef}
                onClick={dismiss}
                aria-label="Dismiss"
                style={{
                  position: 'absolute', right: -7, top: -7,
                  background: 'none', border: 'none', padding: 0,
                  cursor: 'pointer', lineHeight: 0, opacity: 0,
                  transition: 'opacity 0.35s ease',
                }}
              >
                <svg width="18" height="18" viewBox="0 0 18 18">
                  <circle cx="9" cy="9" r="9" fill="rgba(0,0,0,0.55)" />
                  <line x1="5.5" y1="5.5" x2="12.5" y2="12.5" stroke="#fff" strokeWidth="1.2" strokeLinecap="round" />
                  <line x1="12.5" y1="5.5" x2="5.5" y2="12.5" stroke="#fff" strokeWidth="1.2" strokeLinecap="round" />
                </svg>
              </button>
            </>
          )}
        </div>
      </div>
    );
  },
);

ContinueWatching.displayName = 'ContinueWatching';
