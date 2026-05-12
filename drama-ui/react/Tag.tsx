import React from 'react';
import { colors, radius } from './tokens';

export type TagVariant = 'new' | 'hot' | 'free' | 'exclusive' | 'members-only';

interface TagProps { variant: TagVariant; label?: string; }

const variantStyles: Record<TagVariant, React.CSSProperties> = {
  new: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: colors.bgBlue },
  hot: { background: 'linear-gradient(-90deg, #CECECE 0%, #FA5E7B 100%)', color: colors.bgBlue },
  free: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: colors.bgBlue },
  exclusive: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: colors.bgBlue },
  'members-only': { background: 'linear-gradient(270deg, #2634C7 0%, #121732 100%)', color: colors.textOrange },
};

const defaultLabels: Record<TagVariant, string> = {
  new: 'New', hot: 'Hot', free: 'Free', exclusive: 'Exclusive', 'members-only': 'Members Only',
};

/** SVG tail decoration (4×20, extends below the 16px tag) */
const TagTail = () => (
  <svg width="4" height="20" viewBox="0 0 4 20" style={{ display: 'block' }}>
    <rect width="4" height="18" fill="#CECECE" />
    <rect y="16" width="4" height="4" fill="#545472" />
  </svg>
);

export const Tag: React.FC<TagProps> = ({ variant, label }) => {
  const hasTail = variant !== 'members-only';
  return (
    <div style={{ display: 'inline-flex', alignItems: 'flex-end', height: hasTail ? 26 : 16 }}>
      <div style={{
        display: 'inline-flex', alignItems: 'center', height: 16,
        borderRadius: `${radius.sm}px 0 0 ${radius.sm}px`, padding: '0 2px 0 8px', gap: 2,
        fontFamily: "'Lexend Deca', sans-serif", fontSize: 9, fontWeight: 500, lineHeight: '1.33',
        ...variantStyles[variant],
      }}>
        {label ?? defaultLabels[variant]}
      </div>
      {hasTail && <TagTail />}
    </div>
  );
};
