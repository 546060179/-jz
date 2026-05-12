import React from 'react';

interface DateDividerProps {
  date: string;
}

export const DateDivider: React.FC<DateDividerProps> = ({ date }) => (
  <div style={{ display: 'flex', alignItems: 'center', width: '100%' }}>
    <div style={{ flex: '0 0 28.5px', height: 1, background: 'linear-gradient(90deg, rgba(194,202,240,0) 0%, rgba(194,202,240,0.12) 100%)' }} />
    <span style={{
      display: 'flex', alignItems: 'center', padding: '0 8px', height: 20,
      borderRadius: 100, background: 'rgba(194, 202, 240, 0.12)',
      fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
      lineHeight: '1.33', color: '#6C7398', textTransform: 'capitalize', whiteSpace: 'nowrap',
    }}>{date}</span>
    <div style={{ flex: 1, height: 1, background: 'linear-gradient(90deg, rgba(194,202,240,0.12) 0%, rgba(194,202,240,0) 100%)' }} />
  </div>
);
