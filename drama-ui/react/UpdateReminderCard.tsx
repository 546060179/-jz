import React from 'react';
import { DateDivider } from './DateDivider';
import { RemindButton } from './RemindButton';
import { colors, radius } from './tokens';

interface UpdateReminderCardProps {
  date: string; coverUrl: string; title: string;
  reserved: boolean; onToggleRemind: () => void;
}

export const UpdateReminderCard: React.FC<UpdateReminderCardProps> = ({ date, coverUrl, title, reserved, onToggleRemind }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 8, width: 117 }}>
    <DateDivider date={date} />
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, width: 117 }}>
      <img src={coverUrl} alt={title} style={{ width: 117, height: 156, borderRadius: radius.base, objectFit: 'cover' }} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 4px' }}>
        <p style={{
          fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
          lineHeight: '1.33', color: colors.textBlue, textTransform: 'capitalize' as const,
          margin: 0, height: 32, overflow: 'hidden',
        }}>{title}</p>
        <RemindButton reserved={reserved} onToggle={onToggleRemind} />
      </div>
    </div>
  </div>
);
