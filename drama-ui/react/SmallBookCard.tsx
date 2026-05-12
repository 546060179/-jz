import React from 'react';
import { Tag, TagVariant } from './Tag';
import { GenreTag } from './GenreTag';
import { IconPlayFilled } from './Icons';
import { colors, radius } from './tokens';

interface SmallBookCardProps {
  coverUrl: string;
  title: string;
  playCount: string;
  genres: string[];
  badge?: TagVariant;
}

export const SmallBookCard: React.FC<SmallBookCardProps> = ({ coverUrl, title, playCount, genres, badge }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 4, position: 'relative' }}>
    <div style={{ position: 'relative', width: 117, height: 156, borderRadius: radius.base, overflow: 'hidden' }}>
      <img src={coverUrl} alt={title} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      <div style={{
        position: 'absolute', bottom: 4, right: 4, display: 'flex', alignItems: 'center',
        gap: 4, padding: '0 4px', height: 20, borderRadius: radius.md,
        background: colors.bgBlue1, backdropFilter: 'blur(40px)',
      }}>
        <IconPlayFilled size={10} />
        <span style={{ fontFamily: "'Lexend Deca', sans-serif", fontWeight: 500, fontSize: 10, lineHeight: '1.6', color: colors.fillWhite }}>
          {playCount}
        </span>
      </div>
      {badge && <div style={{ position: 'absolute', top: 4, right: 0 }}><Tag variant={badge} /></div>}
    </div>
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, padding: '0 4px' }}>
      <p style={{
        fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
        lineHeight: '1.33', color: colors.textBlue, textTransform: 'capitalize' as const, margin: 0,
        height: 32, overflow: 'hidden',
      }}>{title}</p>
      <div style={{ display: 'flex', gap: 4 }}>
        {genres.map(g => <GenreTag key={g} label={g} dark />)}
      </div>
    </div>
  </div>
);
