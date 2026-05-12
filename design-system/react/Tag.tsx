import React from 'react';

export type TagVariant = 'new' | 'hot' | 'free' | 'exclusive' | 'members-only';

interface TagProps {
  variant: TagVariant;
  label?: string;
}

const variantStyles: Record<TagVariant, React.CSSProperties> = {
  new: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: '#141621' },
  hot: { background: 'linear-gradient(-90deg, #CECECE 0%, #FA5E7B 100%)', color: '#141621' },
  free: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: '#141621' },
  exclusive: { background: 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)', color: '#141621' },
  'members-only': { background: 'linear-gradient(270deg, #2634C7 0%, #121732 100%)', color: '#FFE0B5' },
};

const defaultLabels: Record<TagVariant, string> = {
  new: 'New', hot: 'Hot', free: 'Free', exclusive: 'Exclusive', 'members-only': 'Members Only',
};

export const Tag: React.FC<TagProps> = ({ variant, label }) => (
  <div style={{
    display: 'inline-flex', alignItems: 'center', height: 16,
    borderRadius: '6px 0 0 6px', padding: '0 2px 0 8px', gap: 2,
    fontFamily: "'Lexend Deca', sans-serif", fontSize: 9, fontWeight: 500, lineHeight: '1.33',
    ...variantStyles[variant],
  }}>
    {label ?? defaultLabels[variant]}
  </div>
);
