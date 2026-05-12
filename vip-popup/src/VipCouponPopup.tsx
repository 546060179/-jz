/**
 * VIP 会员限时优惠弹窗组件
 *
 * 调用动效组件库 <Motion> 组件，使用 flip-x-in 翻转出现效果。
 * 基于 Figma 设计稿 node 2925:34630 → Group 1410148484 弹窗层。
 */
import React, { useState, useEffect } from 'react';
import { Motion } from '@fade-animation/react';
import type { MotionEffect } from '@fade-animation/core';

export interface VipCouponPopupProps {
  /** 控制弹窗显示 */
  visible: boolean;
  /** 关闭回调 */
  onClose?: () => void;
  /** 立即开通回调 */
  onSubscribe?: () => void;
}

/** 翻转进入效果：绕 X 轴从 90° 翻转到 0°，配合淡入和缩放 */
const FLIP_IN_EFFECTS: MotionEffect[] = [
  { type: 'fade', from: 0, to: 1 },
  { type: 'flip', axis: 'x', from: 90, to: 0, perspective: 1000 },
  { type: 'scale', from: 0.85, to: 1 },
];

/** 遮罩淡入效果 */
const MASK_EFFECTS: MotionEffect[] = [
  { type: 'fade', from: 0, to: 1 },
];

export const VipCouponPopup: React.FC<VipCouponPopupProps> = ({
  visible,
  onClose,
  onSubscribe,
}) => {
  const [countdown, setCountdown] = useState('23:59:59');

  useEffect(() => {
    if (!visible) return;
    let total = 23 * 3600 + 59 * 60 + 59;
    const timer = setInterval(() => {
      if (total <= 0) { clearInterval(timer); return; }
      total--;
      const h = String(Math.floor(total / 3600)).padStart(2, '0');
      const m = String(Math.floor((total % 3600) / 60)).padStart(2, '0');
      const s = String(total % 60).padStart(2, '0');
      setCountdown(`${h}:${m}:${s}`);
    }, 1000);
    return () => clearInterval(timer);
  }, [visible]);

  if (!visible) return null;

  return (
    <div style={styles.wrapper}>
      {/* 遮罩层 - 淡入 */}
      <Motion in={visible} effect={MASK_EFFECTS} intent="enter" duration={300}>
        <div style={styles.mask} onClick={onClose} />
      </Motion>

      {/* 弹窗卡片 - 翻转进入 */}
      <Motion
        in={visible}
        effect={FLIP_IN_EFFECTS}
        intent="enter"
        duration={500}
        easing="expressive"
      >
        <div style={styles.popupContainer}>
          {/* 呼吸光背景 */}
          <div style={styles.glowBg}>
            <img src="assets/glow-bg.png" alt="" style={{ width: '100%', height: '100%' }} />
          </div>

          {/* 卡片 */}
          <div style={styles.cardWrapper}>
            <img src="assets/card-shape.svg" alt="" style={styles.cardShape} />

            <div style={styles.cardBody}>
              {/* 顶部装饰 */}
              <div style={styles.cardTopDecor}>
                <div style={styles.gradientBg} />
                <img src="assets/checker-pattern.png" alt="" style={styles.checker} />
              </div>

              {/* 角色 */}
              <img src="assets/character.png" alt="" style={styles.character} />

              {/* 边框 */}
              <img src="assets/card-border.svg" alt="" style={styles.cardBorder} />

              {/* 毛玻璃底部 */}
              <div style={styles.glassBottom} />
            </div>

            {/* 标题 */}
            <div style={styles.titleBanner}>
              <img src="assets/title-banner.png" alt="" style={{ width: '100%', height: '100%' }} />
              <span style={styles.titleText}>会员限时优惠</span>
            </div>

            {/* 优惠券 */}
            <div style={styles.couponArea}>
              <div style={styles.couponBg} />
              <div style={styles.couponPrice}>
                <span style={styles.couponAmount}>20</span>
                <span style={styles.couponUnit}>元</span>
              </div>
              <div style={styles.couponDivider} />
              <div style={styles.couponInfo}>
                <div style={styles.couponName}>包周优惠券</div>
                <div style={styles.couponDesc}>仅连续包周可用</div>
              </div>
            </div>

            {/* 可用时间 */}
            <div style={styles.expireInfo}>
              <span style={{ color: '#832604' }}>可用时间：</span>
              <span style={{ color: '#FF383C', fontVariantNumeric: 'tabular-nums' }}>{countdown}</span>
            </div>

            {/* CTA 按钮 */}
            <button style={styles.ctaButton} onClick={onSubscribe}>
              立即开通
            </button>
          </div>
        </div>
      </Motion>

      {/* 关闭按钮 - 延迟淡入 */}
      <Motion in={visible} effect={MASK_EFFECTS} intent="enter" delay={600} duration={300}>
        <div style={styles.closeBtn} onClick={onClose}>
          <img src="assets/close-btn.svg" alt="关闭" style={{ width: 36, height: 36 }} />
        </div>
      </Motion>
    </div>
  );
};

const styles: Record<string, React.CSSProperties> = {
  wrapper: {
    position: 'fixed',
    inset: 0,
    zIndex: 1000,
  },
  mask: {
    position: 'absolute',
    inset: 0,
    background: 'rgba(0,0,0,0.6)',
  },
  popupContainer: {
    position: 'absolute',
    top: 190,
    left: 0,
    width: 375,
    height: 431,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    transformOrigin: 'center center',
  },
  glowBg: {
    position: 'absolute',
    top: 0, left: 0,
    width: 375, height: 375,
    pointerEvents: 'none',
    opacity: 0.6,
  },
  cardWrapper: {
    position: 'absolute',
    top: 7, left: 57,
    width: 260, height: 360,
  },
  cardShape: {
    position: 'absolute',
    top: 10, left: -4,
    width: 284, height: 360,
    pointerEvents: 'none',
  },
  cardBody: {
    position: 'absolute',
    top: 17, left: 0,
    width: 260, height: 343,
    borderRadius: 16,
    overflow: 'hidden',
    background: 'linear-gradient(180deg, #FDF4D7 0%, #FFFAEC 68%)',
    boxShadow: 'inset 0 0 10px 4px rgba(255,255,255,1)',
  },
  cardTopDecor: {
    position: 'relative',
    width: 260, height: 86,
    overflow: 'hidden',
  },
  gradientBg: {
    position: 'absolute',
    inset: 0,
    background: 'linear-gradient(180deg, rgba(196,196,196,1) 0%, rgba(94,94,94,0) 100%)',
    opacity: 0.15,
  },
  checker: {
    position: 'absolute',
    top: -33, left: -41,
    width: 341, height: 192,
    objectFit: 'cover',
    opacity: 0.08,
  },
  character: {
    position: 'absolute',
    top: 10, right: -20,
    width: 151, height: 141,
    objectFit: 'cover',
    zIndex: 2,
  },
  cardBorder: {
    position: 'absolute',
    top: 0, left: 0,
    width: 260, height: 343,
    pointerEvents: 'none',
    zIndex: 3,
  },
  glassBottom: {
    position: 'absolute',
    bottom: 0, left: 0,
    width: 260, height: 199,
    backdropFilter: 'blur(4px)',
    background: 'rgba(255,255,255,0.3)',
    boxShadow: 'inset 0 2px 4px 0 rgba(255,255,255,1)',
    zIndex: 4,
  },
  titleBanner: {
    position: 'absolute',
    top: 94, left: 0,
    width: 184, height: 44,
    zIndex: 10,
  },
  titleText: {
    position: 'absolute',
    top: 2, left: 16,
    fontFamily: "'Alimama ShuHeiTi', 'PingFang SC', sans-serif",
    fontWeight: 700,
    fontSize: 24,
    lineHeight: '1.2',
    color: '#010000',
  },
  couponArea: {
    position: 'absolute',
    top: 186, left: 22,
    width: 216, height: 74,
    zIndex: 10,
  },
  couponBg: {
    position: 'absolute',
    inset: 0,
    borderRadius: 12,
    background: 'linear-gradient(143deg, rgba(255,152,74,1) 0%, rgba(255,71,54,1) 100%)',
    boxShadow: 'inset 2px 0 3px 0 rgba(255,255,255,0.5), inset -2px 0 3px 0 rgba(255,255,255,0.5)',
  },
  couponPrice: {
    position: 'absolute',
    top: 16, left: 20,
    display: 'flex',
    alignItems: 'flex-end',
    gap: 2,
    color: '#FFF',
  },
  couponAmount: {
    fontFamily: "'D-DIN-PRO', sans-serif",
    fontWeight: 700,
    fontSize: 40,
    lineHeight: '1.05',
  },
  couponUnit: {
    fontWeight: 600,
    fontSize: 20,
    lineHeight: '1.4',
    marginBottom: 4,
  },
  couponDivider: {
    position: 'absolute',
    top: 16, left: 98,
    width: 0, height: 42,
    borderLeft: '1px solid rgba(255,255,255,0.5)',
  },
  couponInfo: {
    position: 'absolute',
    top: 16, left: 112,
    color: '#FFF',
  },
  couponName: {
    fontWeight: 600,
    fontSize: 16,
    lineHeight: '1.5',
  },
  couponDesc: {
    fontSize: 12,
    lineHeight: '1.5',
    opacity: 0.85,
  },
  expireInfo: {
    position: 'absolute',
    top: 135, left: 16,
    display: 'flex',
    alignItems: 'center',
    gap: 4,
    zIndex: 10,
    fontSize: 14,
    lineHeight: '1.57',
  },
  ctaButton: {
    position: 'absolute',
    top: 286, left: 22,
    width: 216, height: 48,
    zIndex: 10,
    border: 'none',
    cursor: 'pointer',
    borderRadius: 99,
    background: 'linear-gradient(180deg, rgba(255,87,0,1) 0%, rgba(239,82,0,1) 100%)',
    boxShadow: '0 0 0 5px #FFF, 0 0 0 4px #F1E7E0, 0 3.7px 4.8px 0 rgba(255,88,0,0.15), 0 10.3px 13.4px 0 rgba(255,88,0,0.22), inset 0 1px 4px 2px #FFEDDB, inset 0 1px 18px 2px #FFEDDB',
    color: '#FFF',
    fontFamily: "'Alimama ShuHeiTi', 'PingFang SC', sans-serif",
    fontWeight: 700,
    fontSize: 20,
    letterSpacing: '0.04em',
    lineHeight: '1.2',
  },
  closeBtn: {
    position: 'absolute',
    top: 585, left: 170,
    cursor: 'pointer',
  },
};

export default VipCouponPopup;
