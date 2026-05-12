import React from 'react';

interface RemindButtonProps {
  reserved: boolean;
  onToggle: () => void;
}

const RemindIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <path d="M8 2C5.24 2 3 4.24 3 7v3l-1 1v1h12v-1l-1-1V7c0-2.76-2.24-5-5-5zm0 13c1.1 0 2-.9 2-2H6c0 1.1.9 2 2 2z" fill="currentColor"/>
  </svg>
);

const CheckIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
    <path d="M6 10.8L3.2 8l-1.06 1.06L6 12.9l8-8-1.06-1.06L6 10.8z" fill="currentColor"/>
  </svg>
);

export const RemindButton: React.FC<RemindButtonProps> = ({ reserved, onToggle }) => (
  <button onClick={onToggle} style={{
    display: 'inline-flex', justifyContent: 'center', alignItems: 'center',
    gap: 2, padding: 8, height: 24, borderRadius: 8, border: 'none', cursor: 'pointer',
    fontFamily: "'Lexend Deca', sans-serif", fontWeight: 500, fontSize: 12,
    lineHeight: '1.33', textTransform: 'capitalize',
    background: reserved ? '#141621' : 'linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)',
    color: reserved ? '#5A68FF' : '#050713',
  }}>
    {reserved ? <CheckIcon /> : <RemindIcon />}
    {reserved ? 'Reserved' : 'Remind Me'}
  </button>
);
