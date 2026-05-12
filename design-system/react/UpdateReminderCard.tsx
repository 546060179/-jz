import React from 'react';
import { DateDivider } from './DateDivider';
import { RemindButton } from './RemindButton';

interface UpdateReminderCardProps {
  date: string;
  coverUrl: string;
  title: string;
  reserved: boolean;
  onToggleRemind: () => void;
}

export const UpdateReminderCard: React.FC<UpdateReminderCardProps> = ({ date, coverUrl, title, reserved, onToggleRemind }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 8, width: 117 }}>
    <DateDivider date={date} />
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, width: 117 }}>
      <div style={{ width: 117, height: 156, borderRadius: 12, overflow: 'hidden' }}>
        <img src={coverUrl} alt={title} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 4px' }}>
        <p style={{
          fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
          lineHeight: '1.33', color: '#C4C7D6', textTransform: 'capitalize', margin: 0,
          height: 32, overflow: 'hidden',
        }}>{title}</p>
        <RemindButton reserved={reserved} onToggle={onToggleRemind} />
      </div>
    </div>
  </div>
);
