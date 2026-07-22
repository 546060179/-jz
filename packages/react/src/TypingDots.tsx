import React, { type CSSProperties } from 'react';
import { TIMING_SCALES, EASING_CURVES, stagger } from '@kinetic-motion/core';

export interface TypingDotsProps {
  /** 圆点数量，默认 3 */
  count?: number;
  /** 圆点直径（px），默认 8 */
  dotSize?: number;
  /** 圆点间距（px），默认 6 */
  gap?: number;
  /** 暗态颜色，默认 #4C4B50（Neutral/T-b31） */
  dimColor?: string;
  /** 亮态颜色，默认 #828386（Neutral/T-b53） */
  brightColor?: string;
  /** 容器背景色，默认 #23252A（Neutral/T-b16） */
  backgroundColor?: string;
  /** 单个圆点动画周期（ms），默认 TIMING_SCALES.t4 (500) */
  cycleDuration?: number;
  /** 圆点间交错延迟（ms），默认 150 */
  staggerInterval?: number;
  /** 容器圆角，默认 '0px 12px 12px 12px' */
  borderRadius?: string;
  /** 容器内边距，默认 '12px' */
  padding?: string;
  className?: string;
}

// 生成唯一 keyframes 名称避免冲突
const KEYFRAMES_NAME = 'typing-dots-pulse';

// 注入全局 keyframes（仅一次）
let injected = false;
function injectKeyframes() {
  if (injected || typeof document === 'undefined') return;
  const style = document.createElement('style');
  style.textContent = `
@keyframes ${KEYFRAMES_NAME} {
  0%, 100% { opacity: 0.4; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.15); }
}`;
  document.head.appendChild(style);
  injected = true;
}

/**
 * TypingDots — 聊天"正在输入"跑马灯动效组件
 *
 * 基于 Figma ShortMax 对话框加载效果：三个圆点以交错节奏
 * 依次亮暗脉冲，形成跑马灯式的波浪动画。
 *
 * 使用库内 design tokens：
 * - TIMING_SCALES.t4 作为默认周期
 * - EASING_CURVES.expressive 作为缓动曲线
 * - stagger() 计算交错延迟
 *
 * @example
 * <TypingDots />
 *
 * @example
 * <TypingDots count={4} dotSize={6} gap={8} cycleDuration={600} />
 */
export const TypingDots: React.FC<TypingDotsProps> = ({
  count = 3,
  dotSize = 8,
  gap = 6,
  dimColor = '#4C4B50',
  brightColor = '#828386',
  backgroundColor = '#23252A',
  cycleDuration = TIMING_SCALES.t4,
  staggerInterval = 150,
  borderRadius = '0px 12px 12px 12px',
  padding = '12px',
  className,
}) => {
  injectKeyframes();

  const delays = stagger(count, { interval: staggerInterval });
  // 总动画周期 = 单点周期 + 所有交错延迟
  const totalDuration = cycleDuration + (count - 1) * staggerInterval;

  const containerStyle: CSSProperties = {
    display: 'inline-flex',
    alignItems: 'center',
    gap: `${gap}px`,
    padding,
    backgroundColor,
    borderRadius,
    height: 44,
    boxSizing: 'border-box',
  };

  const dotStyle = (delayMs: number): CSSProperties => ({
    width: dotSize,
    height: dotSize,
    borderRadius: '50%',
    backgroundColor: dimColor,
    animation: `${KEYFRAMES_NAME} ${totalDuration}ms ${EASING_CURVES.expressive} ${delayMs}ms infinite`,
    willChange: 'opacity, transform',
  });

  return (
    <div className={className} style={containerStyle} role="status" aria-label="Loading">
      {delays.map((d, i) => (
        <div key={i} style={dotStyle(d)} aria-hidden="true" />
      ))}
    </div>
  );
};
