import React from 'react';
import { colors, radius } from './tokens';
import { IconFire, IconMore } from './Icons';

interface RankTagProps { rank: number; category?: string; }

export const RankTag: React.FC<RankTagProps> = ({ rank, category = 'Most Popular' }) => (
  <div style={{
    display: 'inline-flex', alignItems: 'center', gap: 2, padding: '0 6px', height: 16,
    borderRadius: radius.full, border: '1px solid rgba(250, 94, 123, 0.4)',
    fontFamily: "'Lexend Deca', sans-serif", fontSize: 10, fontWeight: 500, lineHeight: '1.6', color: colors.fillRed,
  }}>
    <IconFire size={12} />
    <span>{rank}th in {category}</span>
    <IconMore size={12} />
  </div>
);
