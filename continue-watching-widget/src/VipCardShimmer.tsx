import React, { CSSProperties } from 'react';

/**
 * VIP 订阅卡片流光动效组件
 *
 * 在卡片表面叠加一道斜向光带，从左下角滑向右上角，循环播放。
 * 光带颜色取自 Figma 设计中的紫蓝-金色渐变色系。
 */

export interface VipCardShimmerProps {
  /** 卡片内容 */
  children: React.ReactNode;
  /** 卡片宽度，默认 307px（Figma 选中态宽度） */
  width?: number | string;
  /** 卡片高度，默认 128px */
  height?: number | string;
  /** 圆角，默认 20px */
  borderRadius?: number | string;
  /** 动画持续时间（秒），默认 3 */
  duration?: number;
  /** 动画延迟（秒），默认 0 */
  delay?: number;
  /** 是否暂停动画 */
  paused?: boolean;
  /** 额外 className */
  className?: string;
  /** 额外 style */
  style?: CSSProperties;
}

// 生成唯一 keyframes 名称避免冲突
const KEYFRAME_NAME = 'vip-card-shimmer';

// 注入全局 keyframes（仅执行一次）
let injected = false;
function injectKeyframes() {
  if (injected || typeof document === 'undefined') return;
  injected = true;
  const style = document.createElement('style');
  style.textContent = `
@keyframes ${KEYFRAME_NAME} {
  0% {
    transform: translateX(-100%) rotate(-25deg);
  }
  100% {
    transform: translateX(300%) rotate(-25deg);
  }
}`;
  document.head.appendChild(style);
}

export const VipCardShimmer: React.FC<VipCardShimmerProps> = ({
  children,
  width = 307,
  height = 128,
  borderRadius = 20,
  duration = 3,
  delay = 0,
  paused = false,
  className,
  style,
}) => {
  injectKeyframes();

  const containerStyle: CSSProperties = {
    position: 'relative',
    width,
    height,
    borderRadius,
    overflow: 'hidden',
    // Figma 卡片背景：深色渐变 + 紫蓝描边
    background:
      'linear-gradient(171deg, rgba(5,7,19,0) 4%, rgba(5,7,19,1) 69%)',
    border: '1px solid',
    borderImage:
      'linear-gradient(180deg, rgba(185,179,235,0.4) 0%, rgba(185,179,235,1) 100%) 1',
    boxSizing: 'border-box',
    ...style,
  };

  // 流光层：一道倾斜的半透明渐变光带
  const shimmerStyle: CSSProperties = {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '60%',
    height: '200%',
    pointerEvents: 'none',
    background:
      'linear-gradient(90deg, transparent 0%, rgba(158,165,255,0.08) 25%, rgba(242,215,184,0.18) 50%, rgba(158,165,255,0.08) 75%, transparent 100%)',
    animation: `${KEYFRAME_NAME} ${duration}s ${delay}s ease-in-out infinite`,
    animationPlayState: paused ? 'paused' : 'running',
    willChange: 'transform',
  };

  return (
    <div className={className} style={containerStyle}>
      {children}
      <div style={shimmerStyle} aria-hidden="true" />
    </div>
  );
};

export default VipCardShimmer;
