import React, {
  useRef,
  useEffect,
  useCallback,
  useImperativeHandle,
  forwardRef,
  type CSSProperties,
} from 'react';
import { resolveMotionLevel, BUBBLE_EXPAND_DEFAULTS } from '@kinetic-motion/core';

export type BubbleArrowDirection = 'left' | 'right';

export interface BubbleExpandProps {
  /** 气泡文字 */
  text: string;
  /** 气泡背景（任意 CSS background 值），默认品牌蓝 */
  background?: string;
  /** 文字颜色，默认 #fff */
  textColor?: string;
  /** 展开时长（ms），默认 650 */
  expandDuration?: number;
  /** 文字淡入时长（ms），默认 300 */
  textFadeDuration?: number;
  /** 是否显示指向来源的小箭头（预留），默认 false */
  showArrow?: boolean;
  /** 展开锚点方向：right 右对齐向左展开；left 左对齐向右展开。默认 right */
  arrowDirection?: BubbleArrowDirection;
  /** 气泡高度（px），默认 22 */
  height?: number;
  /** 文字字号（px），默认 12 */
  fontSize?: number;
  /** 挂载后自动播放，默认 true */
  autoPlay?: boolean;
  /** 自动播放延迟（ms），默认 300 */
  autoPlayDelay?: number;
  /** 阻尼比 zeta（越小回弹越明显），默认 0.5 */
  zeta?: number;
  /** 角频率 omega，默认 9.0 */
  omega?: number;
  className?: string;
}

export interface BubbleExpandHandle {
  /** 从收起态弹性展开 */
  play: () => void;
}

/** 阻尼谐振子步响应（与 iOS/Android/Web 预览同款公式） */
function springBounce(t: number, zeta: number, omega: number): number {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  const wd = omega * Math.sqrt(1 - zeta * zeta);
  const env = Math.exp(-zeta * omega * t);
  return 1 - env * (Math.cos(wd * t) + (zeta / Math.sqrt(1 - zeta * zeta)) * Math.sin(wd * t));
}

/**
 * BubbleExpand — 气泡展开动效组件
 *
 * 从收起态用 `scaleX` 以右（或左）边缘为锚点弹性展开为带文字的气泡，文字在展开
 * 后段（默认 70%）淡入。展开曲线为阻尼谐振子（zeta=0.5, omega=9.0），带轻微
 * 过冲回弹，与 iOS `BubbleExpandView` / Android `BubbleExpandView` 同款参数。
 *
 * @example
 * <BubbleExpand text="限时免费" autoPlay />
 *
 * @example 命令式触发
 * const ref = useRef<BubbleExpandHandle>(null);
 * <BubbleExpand ref={ref} text="限时免费" autoPlay={false} />
 * // ref.current?.play();
 */
export const BubbleExpand = forwardRef<BubbleExpandHandle, BubbleExpandProps>(
  function BubbleExpand(
    {
      text,
      background = '#186CE5',
      textColor = '#ffffff',
      expandDuration = BUBBLE_EXPAND_DEFAULTS.expandDuration,
      textFadeDuration = BUBBLE_EXPAND_DEFAULTS.textFadeDuration,
      showArrow = false,
      arrowDirection = 'right',
      height = 22,
      fontSize = 12,
      autoPlay = true,
      autoPlayDelay = 300,
      zeta = BUBBLE_EXPAND_DEFAULTS.zeta,
      omega = BUBBLE_EXPAND_DEFAULTS.omega,
      className,
    },
    ref,
  ) {
    const bodyRef = useRef<HTMLDivElement>(null);
    const textRef = useRef<HTMLSpanElement>(null);
    const rafRef = useRef<number | null>(null);

    const origin = arrowDirection === 'right' ? 'right center' : 'left center';

    const play = useCallback(() => {
      const body = bodyRef.current;
      const txt = textRef.current;
      if (!body) return;
      if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);

      // reduced/none 动效级别：直接展示最终态
      if (resolveMotionLevel() !== 'full') {
        body.style.transform = 'scaleX(1)';
        if (txt) txt.style.opacity = '1';
        return;
      }

      body.style.transformOrigin = origin;
      body.style.transform = 'scaleX(0)';
      if (txt) txt.style.opacity = '0';

      const fadeStart = 1 - textFadeDuration / expandDuration;
      let t0 = 0;
      const tick = (now: number) => {
        if (!t0) t0 = now;
        const p = Math.min((now - t0) / expandDuration, 1);
        const s = springBounce(p, zeta, omega);
        body.style.transform = `scaleX(${Math.max(0.001, s)})`;
        if (txt && p > fadeStart) {
          txt.style.opacity = String(Math.min((p - fadeStart) / (1 - fadeStart), 1));
        }
        if (p < 1) {
          rafRef.current = requestAnimationFrame(tick);
        } else {
          body.style.transform = 'scaleX(1)';
          if (txt) txt.style.opacity = '1';
          rafRef.current = null;
        }
      };
      rafRef.current = requestAnimationFrame(tick);
    }, [origin, expandDuration, textFadeDuration, zeta, omega]);

    useImperativeHandle(ref, () => ({ play }), [play]);

    useEffect(() => {
      if (!autoPlay) return;
      const id = setTimeout(play, autoPlayDelay);
      return () => {
        clearTimeout(id);
        if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
      };
    }, [autoPlay, autoPlayDelay, play]);

    // 初始态：autoPlay 时收起（scaleX 0 + 文字透明），否则展示完整气泡
    const collapsed = autoPlay;

    const containerStyle: CSSProperties = {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: arrowDirection === 'right' ? 'flex-end' : 'flex-start',
    };
    const bodyStyle: CSSProperties = {
      height,
      borderRadius: 8,
      background,
      display: 'inline-flex',
      alignItems: 'center',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      transformOrigin: origin,
      transform: collapsed ? 'scaleX(0)' : 'scaleX(1)',
      willChange: 'transform',
    };
    const textStyle: CSSProperties = {
      color: textColor,
      fontWeight: 700,
      fontSize,
      padding: '0 12px',
      opacity: collapsed ? 0 : 1,
    };

    return (
      <div className={className} style={containerStyle}>
        <div ref={bodyRef} style={bodyStyle} data-arrow={showArrow ? arrowDirection : undefined}>
          <span ref={textRef} style={textStyle}>
            {text}
          </span>
        </div>
      </div>
    );
  },
);
