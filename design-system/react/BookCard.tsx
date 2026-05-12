import React from 'react';
import { Tag, TagVariant } from './Tag';
import { GenreTag } from './GenreTag';

interface BookCardProps {
  coverUrl: string;
  title: string;
  description: string;
  genres: string[];
  badge?: TagVariant;
}

export const BookCard: React.FC<BookCardProps> = ({ coverUrl, title, description, genres, badge }) => (
  <div style={{ position: 'relative', width: 225, borderRadius: 12, overflow: 'hidden', background: '#141621' }}>
    <img src={coverUrl} alt={title} style={{ width: '100%', height: 300, objectFit: 'cover', display: 'block' }} />
    <div style={{ position: 'absolute', top: 260, left: 0, right: 0, display: 'flex', flexDirection: 'column' }}>
      <div style={{ height: 40, background: 'linear-gradient(180deg, rgba(20,22,33,0) 0%, rgba(20,22,33,1) 100%)' }} />
      <div style={{ background: '#141621', padding: '0 4px 4px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
          {genres.map(g => <GenreTag key={g} label={g} />)}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4, padding: '0 4px 4px' }}>
          <h3 style={{
            fontFamily: "'Lexend Deca', sans-serif", fontWeight: 400, fontSize: 20,
            lineHeight: '1.4', color: '#FFF', textTransform: 'capitalize', margin: 0,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
          }}>{title}</h3>
          <p style={{
            fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12,
            lineHeight: '1.33', color: '#6C7398', textTransform: 'capitalize', margin: 0,
            height: 32, overflow: 'hidden',
          }}>{description}</p>
        </div>
      </div>
    </div>
    {badge && <div style={{ position: 'absolute', top: 8, right: 0 }}><Tag variant={badge} /></div>}
  </div>
);
