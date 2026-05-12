import React from 'react';

/** Play filled icon (16x16) — used in play count overlay */
export const IconPlayFilled: React.FC<{ size?: number; color?: string }> = ({ size = 16, color = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M4.85 13.35L13.41 8.68a.67.67 0 00.02-1.39L4.87 2.36A.67.67 0 003.67 3.05v9.6c0 .61.65.99 1.18.7z" fill={color} stroke={color} strokeWidth="1.33"/>
  </svg>
);

/** Play liner icon (12x12) — outline style */
export const IconPlayLiner: React.FC<{ size?: number; color?: string }> = ({ size = 12, color = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 12 12" fill="none">
    <path d="M3.21 1.5v9l6.29-4.5L3.21 1.5z" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
  </svg>
);

/** Search icon (24x24) */
export const IconSearch: React.FC<{ size?: number; color?: string }> = ({ size = 24, color = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <path d="M17.5 17.5L21 21" stroke={color} strokeWidth="2" strokeLinecap="round"/>
    <circle cx="11.5" cy="11.5" r="8" stroke={color} strokeWidth="2"/>
  </svg>
);

/** List edit icon (16x16) */
export const IconListEdit: React.FC<{ size?: number; color?: string }> = ({ size = 16, color = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M2 4h8M2 8h6M2 12h4" stroke={color} strokeWidth="1.5" strokeLinecap="round"/>
    <path d="M12 6l2 2-4 4H8v-2l4-4z" stroke={color} strokeWidth="1.5" strokeLinejoin="round"/>
  </svg>
);

/** Remind / Bell icon (16x16) */
export const IconRemind: React.FC<{ size?: number; color?: string }> = ({ size = 16, color = '#141621' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M3.67 6.67a4.33 4.33 0 018.66 0V12H3.67V6.67z" fill={color}/>
    <rect x="7.33" y="1.33" width="1.33" height="2" fill={color}/>
    <path d="M9.33 13.33a1.33 1.33 0 01-2.66 0h2.66z" fill={color}/>
    <rect x="2.67" y="10.67" width="10.67" height="1.33" fill={color}/>
  </svg>
);

/** Checkin / Check icon (16x16) */
export const IconCheckin: React.FC<{ size?: number; color?: string }> = ({ size = 16, color = '#5A68FF' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
    <path d="M3.33 8l3.34 3.33L12.67 5" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

/** FAQ icon (10x10) */
export const IconFAQ: React.FC<{ size?: number; color?: string }> = ({ size = 10, color = '#fff' }) => (
  <svg width={size} height={size} viewBox="0 0 10 10" fill="none">
    <circle cx="5" cy="5" r="4" stroke={color} strokeWidth="1.2"/>
    <path d="M3.8 3.8a1.2 1.2 0 012.2.67c0 .8-1.2 1-1.2 1" stroke={color} strokeWidth="1" strokeLinecap="round"/>
    <circle cx="5" cy="7.2" r="0.5" fill={color}/>
  </svg>
);

/** More / Chevron right icon (12x12) */
export const IconMore: React.FC<{ size?: number; color?: string }> = ({ size = 12, color = '#FA5E7B' }) => (
  <svg width={size} height={size} viewBox="0 0 12 12" fill="none">
    <path fillRule="evenodd" clipRule="evenodd" d="M4.15 2.15a.5.5 0 01.7 0l2.8 2.79a1.5 1.5 0 010 2.12l-2.8 2.79a.5.5 0 01-.7-.7L6.94 6.35a.5.5 0 000-.7L4.15 2.85a.5.5 0 010-.7z" fill={color}/>
  </svg>
);

/** Fire icon (12x12) — used in rank tag */
export const IconFire: React.FC<{ size?: number; color?: string }> = ({ size = 12, color = '#FA5E7B' }) => (
  <svg width={size} height={size} viewBox="0 0 12 12" fill="none">
    <path d="M6 11c2.06 0 3.75-1.63 3.75-3.73 0-.51-.03-1.06-.31-1.92-.29-.86-.34-.97-.64-1.5-.13 1.08-.82 1.53-1 1.66 0-.14-.41-1.69-1.05-2.61A4.5 4.5 0 004.8 1c0 .77-.22 1.91-.53 2.49-.31.58-.37.6-.75 1.03-.39.43-.56.57-.88 1.09A3.1 3.1 0 002.25 7.35C2.25 9.45 3.94 11 6 11z" fill={color}/>
  </svg>
);
