import React from 'react';
import { colors, effects, radius, typography } from './tokens';

interface Tab { label: string; value: string; }
interface TabPillProps { tabs: Tab[]; activeValue: string; onChange: (v: string) => void; }

export const TabPill: React.FC<TabPillProps> = ({ tabs, activeValue, onChange }) => (
  <div style={{ display: 'inline-flex', gap: 0 }}>
    {tabs.map(tab => {
      const active = tab.value === activeValue;
      if (active) {
        return (
          <div key={tab.value} style={{
            display: 'inline-flex', borderRadius: radius.base, padding: 2,
            background: 'linear-gradient(90deg, #CECECE 0%, #4051FF 100%)',
            boxShadow: effects.shadowTab,
          }}>
            <button onClick={() => onChange(tab.value)} style={{
              display: 'flex', justifyContent: 'center', alignItems: 'center',
              padding: '4px 12px', height: 36, borderRadius: radius.base - 2,
              background: 'rgba(20, 22, 33, 0.9)', backdropFilter: effects.blurBg,
              border: 'none', cursor: 'pointer',
              ...typography.headingSm, fontSize: 16, fontWeight: 500,
              color: '#BDC3FF', textTransform: 'capitalize' as const,
            }}>
              {tab.label}
            </button>
          </div>
        );
      }
      return (
        <button key={tab.value} onClick={() => onChange(tab.value)} style={{
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          padding: '4px 12px', height: 40, borderRadius: radius.base,
          background: colors.bgBlue2, backdropFilter: effects.blurBg,
          border: 'none', cursor: 'pointer',
          ...typography.bodyRegular, fontSize: 14, fontWeight: 400,
          color: colors.textWhite, textTransform: 'capitalize' as const,
        }}>
          {tab.label}
        </button>
      );
    })}
  </div>
);
