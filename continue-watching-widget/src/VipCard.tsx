import React, { CSSProperties } from 'react';

/**
 * VIP 会员卡片组件 — 基于 Figma 设计 (node 2179:12188)
 *
 * 背景光效使用 Figma 中的椭圆光晕图片精确还原，
 * 叠加流光扫过动效（shimmer）。
 */

export interface VipCardProps {
  /** 套餐名称 */
  title?: string;
  /** 描述文字 */
  description?: string;
  /** 续费说明 */
  renewInfo?: string;
  /** 当前价格 */
  price?: string;
  /** 原价（删除线） */
  originalPrice?: string;
  /** 标签文字，如 "23:40:12" */
  tagTime?: string;
  /** 标签折扣，如 "20% Off" */
  tagDiscount?: string;
  /** 背景光晕图片 URLs（5 张椭圆光效图） */
  glowImages?: {
    top?: string;
    left?: string;
    right?: string;
    bottomWide?: string;
    bottomCenter?: string;
  };
  /** 卡片宽度 */
  width?: number | string;
  /** 卡片高度 */
  height?: number | string;
  /** 流光动画时长（秒） */
  shimmerDuration?: number;
  /** 暂停动画 */
  paused?: boolean;
  onClick?: () => void;
  className?: string;
  style?: CSSProperties;
}

// ---- keyframes 注入 ----
const SHIMMER_KF = 'vip-card-shimmer-sweep';
const GLOW_KF = 'vip-card-glow-breathe';
let injected = false;

function injectKeyframes() {
  if (injected || typeof document === 'undefined') return;
  injected = true;
  const s = document.createElement('style');
  s.textContent = `
@keyframes ${SHIMMER_KF} {
  0%   { transform: translateX(-150%) skewX(-20deg); }
  100% { transform: translateX(350%) skewX(-20deg); }
}
@keyframes ${GLOW_KF} {
  0%, 100% { opacity: 0.7; transform: scale(1); }
  50%      { opacity: 1;   transform: scale(1.05); }
}`;
  document.head.appendChild(s);
}

/** 默认光晕图片 — 来自 Figma MCP 资源（7 天有效） */
const DEFAULT_GLOW: Required<VipCardProps>['glowImages'] = {
  top: 'https://www.figma.com/api/mcp/asset/da51b120-1316-457c-8b4a-529b84494b15',
  left: 'https://www.figma.com/api/mcp/asset/e6ec762a-8ddc-4a16-b132-92c6f72c7347',
  right: 'https://www.figma.com/api/mcp/asset/19d30f2f-3b33-4faa-bfc1-407f5fe1ae78',
  bottomWide: 'https://www.figma.com/api/mcp/asset/31a0d302-2c2b-4c90-8532-dd9af7ccf68a',
  bottomCenter: 'https://www.figma.com/api/mcp/asset/5cdcd1b5-31e5-4f24-9824-37c52f3d076e',
};

export const VipCard: React.FC<VipCardProps> = ({
  title = 'Monthly Pass Pro',
  description = 'Unlock all series for 1 month',
  renewInfo = 'Renew at $199.99/month · Auto renew · Cancel anytime',
  price = '$16.99',
  originalPrice = '$199.99',
  tagTime,
  tagDiscount,
  glowImages,
  width = 307,
  height = 128,
  shimmerDuration = 3,
  paused = false,
  onClick,
  className,
  style,
}) => {
  injectKeyframes();
  const glow = { ...DEFAULT_GLOW, ...glowImages };

  const container: CSSProperties = {
    position: 'relative',
    width,
    height,
    borderRadius: 20,
    overflow: 'hidden',
    background: 'linear-gradient(158.5deg, rgba(5,7,19,0) 17.7%, rgb(5,7,19) 56.3%)',
    border: '1px solid rgba(185,179,235,0.4)',
    display: 'flex',
    flexDirection: 'column',
    padding: 16,
    gap: 8,
    fontFamily: '"Lexend Deca", sans-serif',
    cursor: onClick ? 'pointer' : undefined,
    boxSizing: 'border-box',
    ...style,
  };

  const glowBase: CSSProperties = {
    position: 'absolute',
    pointerEvents: 'none',
    animation: `${GLOW_KF} 4s ease-in-out infinite`,
  };

  const imgFill: CSSProperties = {
    display: 'block',
    width: '100%',
    height: '100%',
    maxWidth: 'none',
  };

  return (
    <div style={{ position: 'relative', display: 'inline-block' }}>
      {/* 标签 */}
      {(tagTime || tagDiscount) && (
        <div style={{
          position: 'absolute', top: 0, right: 0, zIndex: 2,
          display: 'flex', alignItems: 'center', gap: 4,
          padding: '0 8px', height: 20,
          background: 'linear-gradient(to left, #f2d7b8, #9ea5ff)',
          borderRadius: '10px 10px 0 10px',
          fontSize: 10, fontWeight: 500, color: '#2a0693',
          fontFamily: '"Lexend Deca", sans-serif',
          textTransform: 'capitalize',
        }}>
          {tagTime && <span>{tagTime}</span>}
          {tagTime && tagDiscount && <span style={{ width: 1, height: 8, background: '#2a0693' }} />}
          {tagDiscount && <span>{tagDiscount}</span>}
        </div>
      )}

      <div
        className={className}
        style={container}
        onClick={onClick}
        role={onClick ? 'button' : undefined}
        tabIndex={onClick ? 0 : undefined}
        onKeyDown={onClick ? (e) => { if (e.key === 'Enter' || e.key === ' ') onClick(); } : undefined}
      >
        {/* 背景光晕 — Figma 椭圆图片 */}
        {glow.top && (
          <div style={{ ...glowBase, width: 364, height: 230, top: -100, left: -100, opacity: 0.6, animationDelay: '2s' }}>
            <img src={glow.top} alt="" style={imgFill} />
          </div>
        )}
        {glow.left && (
          <div style={{ ...glowBase, width: 372, height: 278, bottom: -120, right: 80, transform: 'rotate(10.84deg)', opacity: 0.8 }}>
            <img src={glow.left} alt="" style={imgFill} />
          </div>
        )}
        {glow.right && (
          <div style={{ ...glowBase, width: 368, height: 373, bottom: -115, right: -80, transform: 'rotate(9.87deg) skewX(1.51deg)', opacity: 0.8, animationDelay: '1s' }}>
            <img src={glow.right} alt="" style={imgFill} />
          </div>
        )}
        {glow.bottomWide && (
          <div style={{ ...glowBase, width: 335, height: 42, bottom: -10, left: -44, opacity: 0.5, animationDelay: '0.5s' }}>
            <img src={glow.bottomWide} alt="" style={imgFill} />
          </div>
        )}
        {glow.bottomCenter && (
          <div style={{ ...glowBase, width: 157, height: 45, bottom: -12, left: 52, opacity: 0.6, animationDelay: '1.5s' }}>
            <img src={glow.bottomCenter} alt="" style={imgFill} />
          </div>
        )}

        {/* 标题 */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, position: 'relative', zIndex: 1 }}>
          <VipLogo />
          <span style={{
            fontSize: 18, fontWeight: 500, lineHeight: '28px',
            background: 'linear-gradient(to left, #ffe0b5, #ffffff)',
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            textTransform: 'capitalize' as const, whiteSpace: 'nowrap' as const,
          }}>{title}</span>
        </div>

        {/* 内容 */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, flex: 1, position: 'relative', zIndex: 1, textTransform: 'capitalize' as const }}>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column' as const, gap: 4, fontSize: 10, lineHeight: '12px' }}>
            <span style={{ color: '#c4c7d6' }}>{description}</span>
            <span style={{ color: 'rgba(196,199,214,0.6)' }}>{renewInfo}</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column' as const, alignItems: 'center', gap: 2, padding: '0 16px 0 8px', color: '#ffe0b5', whiteSpace: 'nowrap' as const }}>
            <span style={{ fontSize: 24, lineHeight: '32px' }}>{price}</span>
            {originalPrice && (
              <span style={{ fontSize: 12, lineHeight: '16px', fontWeight: 300, textDecoration: 'line-through' }}>{originalPrice}</span>
            )}
          </div>
        </div>

        {/* 流光 */}
        <div aria-hidden="true" style={{
          position: 'absolute', top: '-20%', left: 0,
          width: '45%', height: '160%', pointerEvents: 'none',
          background: 'linear-gradient(90deg, transparent 0%, rgba(158,165,255,0.04) 15%, rgba(200,190,255,0.1) 35%, rgba(242,215,184,0.18) 50%, rgba(200,190,255,0.1) 65%, rgba(158,165,255,0.04) 85%, transparent 100%)',
          animation: `${SHIMMER_KF} ${shimmerDuration}s 1s ease-in-out infinite`,
          animationPlayState: paused ? 'paused' : 'running',
          willChange: 'transform',
        }} />
      </div>
    </div>
  );
};

function VipLogo() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" aria-hidden="true">
      <rect x="3" y="6" width="14" height="10" rx="2" fill="url(#vip-grad)" opacity="0.9" />
      <text x="10" y="13.5" textAnchor="middle" fontSize="7" fontWeight="700" fill="#1a1028" fontFamily="Lexend Deca, sans-serif">VIP</text>
      <defs>
        <linearGradient id="vip-grad" x1="3" y1="6" x2="17" y2="16">
          <stop stopColor="#ffe0b5" />
          <stop offset="1" stopColor="#c9a46c" />
        </linearGradient>
      </defs>
    </svg>
  );
}

export default VipCard;
