import React, {
  useRef,
  useState,
  useEffect,
  useCallback,
  useImperativeHandle,
  forwardRef,
  type CSSProperties,
} from 'react';

// ─── Types ───────────────────────────────────────────────────────────

export interface BubbleExpandProps {
  /** 气泡内文字 */
  text: string;
  /** 气泡背景（支持 CSS gradient），默认 Figma 金色渐变 */
  background?: string;
  /** 文字颜色，默认 #62241B（Figma 深棕色） */
  textColor?: string;
  /** 文字大小 (px)，默认 10 */
  fontSize?: number;
  /** 气泡最终宽度 (px)，不设则自适应文字 */
  width?: number;
  /** 气泡高度 (px)，默认 28 */
  height?: number;
  /** 气泡圆角 (px)，默认 8 */
  borderRadius?: number;
  /** 是否显示三角箭头，默认 true */
  showArrow?: boolean;
  /** 箭头方向，默认 'right' */
  arrowDirection?: 'left' | 'right';
  /** 箭头颜色，默认 #FFD65A */
  arrowColor?: string;
  /** 气泡展开动画时长 (ms)，默认 650（含弹跳） */
  expandDuration?: number;
  /** 文字淡入动画时长 (ms)，默认 300（t3 token） */
  textFadeDuration?: number;
  /** 文字淡入延迟（相对于展开结束），默认 0ms */
  textFadeDelay?: number;
  /** 自动播放，默认 false */
  autoPlay?: boolean;
  /** 自动播放延迟 (ms)，默认 300 */
  autoPlayDelay?: number;
  /** 展开缓动函数，默认 expressive: cubic-bezier(0.4, 0.14, 0.3, 1) */
  expandEasing?: string;
  /** 文字淡入缓动，默认 enter: cubic-bezier(0, 0, 0.3, 1) */
  textEasing?: string;
  /** 动画完成回调 */
  onAnimationEnd?: () => void;
  /** 展开完成回调（文字开始淡入前） */
  onExpandEnd?: () => void;
  /** 额外 className */
  className?: string;
  /** 额外 style */
  style?: CSSProperties;
}

export interface BubbleExpandRef {
  play: () => void;
  reset: () => void;
  getPhase: () => BubblePhase;
}

export type BubblePhase = 'idle' | 'expanding' | 'text-fading' | 'done';

// ─── Easing helpers (same as ContinueWatching.tsx pattern) ───────────

function lerp(a: number, b: number, t: number) {
  return a + (b - a) * t;
}

function cubicBezierAt(
  t: number, p1x: number, p1y: number, p2x: number, p2y: number
): number {
  const cx = 3 * p1x, bx = 3 * (p2x - p1x) - cx, ax = 1 - cx - bx;
  const cy = 3 * p1y, by = 3 * (p2y - p1y) - cy, ay = 1 - cy - by;
  const sX = (tt: number) => ((ax * tt + bx) * tt + cx) * tt;
  const sY = (tt: number) => ((ay * tt + by) * tt + cy) * tt;
  const dX = (tt: number) => (3 * ax * tt + 2 * bx) * tt + cx;
  let x = t;
  for (let i = 0; i < 8; i++) {
    const err = sX(x) - t;
    if (Math.abs(err) < 1e-6) break;
    const d = dX(x);
    if (Math.abs(d) < 1e-6) break;
    x -= err / d;
  }
  return sY(x);
}

function makeEasing(css: string): (t: number) => number {
  const m = css.match(
    /cubic-bezier\(\s*([\d.]+)\s*,\s*([-\d.]+)\s*,\s*([\d.]+)\s*,\s*([-\d.]+)\s*\)/
  );
  if (m) {
    const [, a, b, c, d] = m.map(Number);
    return (t) => cubicBezierAt(t, a, b, c, d);
  }
  return (t) => cubicBezierAt(t, 0.25, 0.1, 0.25, 1);
}

// Motion tokens from @fade-animation/core
const EASING_EXPRESSIVE = 'cubic-bezier(0.4, 0.14, 0.3, 1)';
const EASING_ENTER = 'cubic-bezier(0, 0, 0.3, 1)';

// Bounce-back easing: overshoot → bounce back → settle (参照花呗弹动效果)
function easeOutBounceBack(t: number): number {
  if (t < 0.65) {
    const p = t / 0.65;
    const e = 1 - Math.pow(1 - p, 3);
    return e * 1.12;
  } else if (t < 0.85) {
    const p = (t - 0.65) / 0.2;
    const e = 1 - Math.pow(1 - p, 2);
    return lerp(1.12, 0.97, e);
  } else {
    const p = (t - 0.85) / 0.15;
    const e = 1 - Math.pow(1 - p, 2);
    return lerp(0.97, 1.0, e);
  }
}

// ─── Component ───────────────────────────────────────────────────────

export const BubbleExpand = forwardRef<BubbleExpandRef, BubbleExpandProps>(
  (
    {
      text,
      background = 'linear-gradient(90deg, #FFD1C4, #FFD75F)',
      textColor = '#62241B',
      fontSize = 10,
      width,
      height = 28,
      borderRadius = 8,
      showArrow = true,
      arrowDirection = 'right',
      arrowColor = '#FFD65A',
      expandDuration = 650,
      textFadeDuration = 300,
      textFadeDelay = 0,
      autoPlay = false,
      autoPlayDelay = 300,
      expandEasing = EASING_EXPRESSIVE,
      textEasing = EASING_ENTER,
      onAnimationEnd,
      onExpandEnd,
      className,
      style,
    },
    ref
  ) => {
    const [phase, setPhase] = useState<BubblePhase>('idle');
    const phaseRef = useRef<BubblePhase>('idle');
    const rafRef = useRef<number>(0);
    const timerRef = useRef<ReturnType<typeof setTimeout>>();
    const containerRef = useRef<HTMLDivElement>(null);
    const textRef = useRef<HTMLSpanElement>(null);
    const measureRef = useRef<HTMLSpanElement>(null);
    const arrowRef = useRef<HTMLDivElement>(null);
    const finalWidthRef = useRef<number>(0);

    const setP = useCallback((p: BubblePhase) => {
      phaseRef.current = p;
      setPhase(p);
    }, []);

    const collapsedWidth = height;

    useEffect(() => {
      if (measureRef.current) {
        finalWidthRef.current = width ?? measureRef.current.offsetWidth + 16 + 4;
      }
    }, [text, width]);

    const play = useCallback(() => {
      if (phaseRef.current !== 'idle') return;
      const el = containerRef.current;
      if (!el) return;

      setP('expanding');
      const targetW = finalWidthRef.current || (width ?? 145);
      const expandEase = makeEasing(expandEasing);
      const textEase = makeEasing(textEasing);

      let animPhase: 'expand' | 'text-fade' = 'expand';
      let phaseStart = 0;

      function tick(now: number) {
        if (phaseRef.current === 'idle' || !el) return;
        if (!phaseStart) phaseStart = now;
        const elapsed = now - phaseStart;

        if (animPhase === 'expand') {
          const t = Math.min(elapsed / expandDuration, 1);
          const e = easeOutBounceBack(t);
          el.style.width = Math.max(collapsedWidth, lerp(collapsedWidth, targetW, e)) + 'px';

          if (t >= 1) {
            el.style.width = targetW + 'px';
            onExpandEnd?.();
            setP('text-fading');
            timerRef.current = setTimeout(() => {
              animPhase = 'text-fade';
              phaseStart = 0;
              rafRef.current = requestAnimationFrame(tick);
            }, textFadeDelay);
            return;
          }
        } else if (animPhase === 'text-fade') {
          const t = Math.min(elapsed / textFadeDuration, 1);
          const e = textEase(t);
          if (textRef.current) {
            textRef.current.style.opacity = String(e);
            textRef.current.style.transform = `translateX(${lerp(8, 0, e)}px)`;
          }
          if (arrowRef.current) {
            arrowRef.current.style.opacity = String(e);
          }
          if (t >= 1) {
            setP('done');
            onAnimationEnd?.();
            return;
          }
        }
        rafRef.current = requestAnimationFrame(tick);
      }

      el.style.width = collapsedWidth + 'px';
      el.style.opacity = '1';
      if (textRef.current) {
        textRef.current.style.opacity = '0';
        textRef.current.style.transform = 'translateX(8px)';
      }
      if (arrowRef.current) arrowRef.current.style.opacity = '0';

      rafRef.current = requestAnimationFrame(tick);
    }, [expandDuration, textFadeDuration, textFadeDelay, expandEasing, textEasing,
        collapsedWidth, width, onExpandEnd, onAnimationEnd, setP]);

    const reset = useCallback(() => {
      cancelAnimationFrame(rafRef.current);
      clearTimeout(timerRef.current);
      setP('idle');
      const el = containerRef.current;
      if (el) { el.style.width = collapsedWidth + 'px'; el.style.opacity = '0'; }
      if (textRef.current) { textRef.current.style.opacity = '0'; textRef.current.style.transform = 'translateX(8px)'; }
      if (arrowRef.current) arrowRef.current.style.opacity = '0';
    }, [collapsedWidth, setP]);

    useImperativeHandle(ref, () => ({ play, reset, getPhase: () => phaseRef.current }), [play, reset]);

    useEffect(() => {
      if (autoPlay) {
        const t = setTimeout(play, autoPlayDelay);
        return () => clearTimeout(t);
      }
    }, [autoPlay, autoPlayDelay, play]);

    useEffect(() => () => {
      cancelAnimationFrame(rafRef.current);
      clearTimeout(timerRef.current);
    }, []);

    const arrowBorder = arrowDirection === 'right'
      ? { borderTop: '8px solid transparent', borderBottom: '8px solid transparent', borderLeft: `9px solid ${arrowColor}`, right: '-8px' }
      : { borderTop: '8px solid transparent', borderBottom: '8px solid transparent', borderRight: `9px solid ${arrowColor}`, left: '-8px' };

    return (
      <>
        <span ref={measureRef} aria-hidden="true" style={{
          position: 'absolute', visibility: 'hidden', whiteSpace: 'nowrap',
          fontSize, fontWeight: 500, padding: '6px 8px',
        }}>{text}</span>

        <div ref={containerRef} className={className} style={{
          display: 'inline-flex', alignItems: 'center',
          height, width: collapsedWidth, borderRadius,
          background, overflow: 'hidden',
          opacity: phase === 'idle' ? 0 : 1,
          whiteSpace: 'nowrap', position: 'relative',
          ...style,
        }}>
          <span ref={textRef} style={{
            color: textColor, fontSize, fontWeight: 500,
            lineHeight: 1.4, opacity: 0, transform: 'translateX(8px)',
            padding: '6px 8px', willChange: 'opacity, transform',
          }}>{text}</span>

          {showArrow && (
            <div ref={arrowRef} style={{
              position: 'absolute', top: '50%', transform: 'translateY(-50%)',
              width: 0, height: 0, opacity: 0, ...arrowBorder,
            }} />
          )}
        </div>
      </>
    );
  }
);

BubbleExpand.displayName = 'BubbleExpand';
