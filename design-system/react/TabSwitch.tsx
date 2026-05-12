import React from 'react';

interface Tab { label: string; value: string; }

interface TabSwitchProps {
  tabs: Tab[];
  activeValue: string;
  onChange: (value: string) => void;
}

export const TabSwitch: React.FC<TabSwitchProps> = ({ tabs, activeValue, onChange }) => (
  <div style={{ display: 'inline-flex', gap: 0 }}>
    {tabs.map(tab => {
      const active = tab.value === activeValue;
      return (
        <button key={tab.value} onClick={() => onChange(tab.value)} style={{
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          padding: '4px 12px', height: 40, borderRadius: 12,
          background: 'rgba(194, 202, 240, 0.12)',
          backdropFilter: 'blur(40px)', cursor: 'pointer',
          fontFamily: "'Lexend Deca', sans-serif", textTransform: 'capitalize',
          border: active ? '2px solid transparent' : 'none',
          borderImage: active ? 'linear-gradient(90deg, #CECECE 0%, #4051FF 100%) 1' : 'none',
          boxShadow: active ? '0 4px 8px rgba(127, 115, 255, 0.59)' : 'none',
          fontWeight: active ? 500 : 400,
          fontSize: active ? 16 : 14,
          color: active ? '#BDC3FF' : 'rgba(255, 255, 255, 0.68)',
        }}>
          {tab.label}
        </button>
      );
    })}
  </div>
);
