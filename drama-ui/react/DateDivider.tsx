import React from 'react';
import { colors, radius, gradients } from './tokens';

interface DateDividerProps { date: string; }

export const DateDivider: React.FC<DateDividerProps> = ({ date }) => (
  <div style={{ display: 'flex', alignItems: 'center', width: '100%' }}>
    <div style={{ flex: '0 0 28.5px', height: 1, background: gradients.dividerLeft }} />
    <span style={{
      display: 'flex', alignItems: 'center', padding: '0 8px', height: 20,
      borderRadius: radius.full, background: colors.bgBlue2,
      fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
      lineHeight: '1.33', color: colors.textBlue1, textTransform: 'capitalize' as const, whiteSpace: 'nowrap' as const,
    }}>{date}</span>
    <div style={{ flex: 1, height: 1, background: gradients.dividerRight }} />
  </div>
);
