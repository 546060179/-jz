import React from 'react';
import { colors, radius, effects } from './tokens';

interface TabbarItem { id: string; label: string; icon: React.ReactNode; }
interface TabbarProps { items: TabbarItem[]; activeId: string; onChange: (id: string) => void; }

export const Tabbar: React.FC<TabbarProps> = ({ items, activeId, onChange }) => (
  <nav style={{
    display: 'flex', width: 343, height: 56,
    background: 'rgba(20, 22, 33, 0.76)', backdropFilter: effects.blurBg,
    borderRadius: radius.xl,
  }}>
    {items.map(item => {
      const active = item.id === activeId;
      return (
        <button key={item.id} onClick={() => onChange(item.id)} style={{
          display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
          alignItems: 'center', flex: 1, paddingBottom: 8,
          cursor: 'pointer', border: 'none', background: 'none',
        }}>
          <div style={{ width: 24, height: 24, marginBottom: 2 }}>{item.icon}</div>
          <span style={{
            fontFamily: "'Lexend Deca', sans-serif",
            fontSize: 9, lineHeight: '1.56', textAlign: 'center' as const,
            fontWeight: active ? 600 : 400,
            color: active ? colors.fillWhite : colors.textBlue,
          }}>{item.label}</span>
        </button>
      );
    })}
  </nav>
);
