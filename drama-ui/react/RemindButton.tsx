import React from 'react';
import { colors, radius, gradients } from './tokens';

interface RemindButtonProps { reserved: boolean; onToggle: () => void; }

/** Remind bell icon — matches Figma icon/Filled/24/icon_remind */
const RemindIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <path d="M3.67 6.67a4.33 4.33 0 018.66 0V12H3.67V6.67z" fill="#141621"/>
    <rect x="7.33" y="1.33" width="1.33" height="2" fill="#141621"/>
    <path d="M9.33 13.33a1.33 1.33 0 01-2.66 0h2.66z" fill="#141621"/>
    <rect x="2.67" y="10.67" width="10.67" height="1.33" fill="#141621"/>
  </svg>
);

/** Calendar checkin icon — matches Figma icon/filled/24/icon_checkin */
const CheckinIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <path d="M13.33 13.67H3.33c-1.47 0-2.67-1.19-2.67-2.67V7h16v6.67c0 1.47-1.19 2.67-2.67 2.67zM6.69 10.44l-1.41-1.41-.94.94 2.36 2.36 3.3-3.3-.94-.94-2.36 2.36zM4 2.67h6V2h1.33v.67H13.33v3H.67v-3H2.67V2H4v.67z" fill="#5A68FF"/>
  </svg>
);

export const RemindButton: React.FC<RemindButtonProps> = ({ reserved, onToggle }) => (
  <button onClick={onToggle} style={{
    display: 'inline-flex', justifyContent: 'center', alignItems: 'center',
    gap: 2, padding: 8, height: 24, borderRadius: radius.md, border: 'none', cursor: 'pointer',
    fontFamily: "'Lexend Deca', sans-serif", fontWeight: 500, fontSize: 12,
    lineHeight: '1.33', textTransform: 'capitalize' as const,
    background: reserved ? colors.bgBlue : gradients.new,
    color: reserved ? colors.fillBlue : colors.bgBlue3,
  }}>
    {reserved ? <CheckinIcon /> : <RemindIcon />}
    {reserved ? 'Reserved' : 'Remind Me'}
  </button>
);
