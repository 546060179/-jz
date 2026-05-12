import React from 'react';
import { colors, radius } from './tokens';

interface GenreTagProps { label: string; dark?: boolean; }

export const GenreTag: React.FC<GenreTagProps> = ({ label, dark }) => (
  <span style={{
    display: 'inline-flex', alignItems: 'center', height: 20,
    padding: '0 6px', borderRadius: radius.md,
    background: dark ? colors.bgBlue : colors.bgBlue3,
    fontFamily: "'Lexend Deca', sans-serif",
    fontSize: 9, fontWeight: dark ? 500 : 400, lineHeight: '1.56',
    color: dark ? '#5D67F4' : colors.fillBlue,
  }}>
    {label}
  </span>
);
