import React from 'react';

/** Home icon — active state with gradient */
export const IconHome = ({ active = false }: { active?: boolean }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path fillRule="evenodd" clipRule="evenodd" d="M11.43 2.68a1 1 0 011.21.05l9 7.5a1 1 0 01-.64 1.77H20v8a1 1 0 01-1 1H5a1 1 0 01-1-1v-8H3a1 1 0 01-.64-1.77l9-7.5.07-.05zM11.54 11.48c-.67-.42-1.54.05-1.54.84v3.36c0 .79.87 1.27 1.54.84l2.64-1.68a1 1 0 000-1.69l-2.64-1.67z"
      fill={active ? 'url(#homeGrad)' : '#C4C7D6'} />
    {active && <defs><radialGradient id="homeGrad" cx="0" cy="0" r="1" gradientTransform="matrix(5.5 12 -12.2 5.6 7.7 6.4)" gradientUnits="userSpaceOnUse"><stop stopColor="#99A0FF"/><stop offset="0.85" stopColor="white"/></radialGradient></defs>}
  </svg>
);

/** Short icon */
export const IconShort = ({ active = false }: { active?: boolean }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M16.5 15.5V3.5H4.5V20.5H16.5C18.71 20.5 20.5 18.71 20.5 16.5V10"
      stroke={active ? '#fff' : '#C4C7D6'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

/** Reward icon */
export const IconReward = ({ active = false }: { active?: boolean }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M18 7h-1H5a1 1 0 00-1 1v12a1 1 0 001 1h13a1 1 0 001-1V8a1 1 0 00-1-1z"
      fill={active ? 'url(#rewardGrad)' : 'none'} stroke={active ? 'none' : '#C4C7D6'} strokeWidth="2" />
    <path fillRule="evenodd" clipRule="evenodd" d="M4.22 3.75c.67-1.68 2.75-2.31 4.23-1.22l2.55 1.74 3.05-2.22c1.47-1.07 3.56-.47 4.24 1.22.8 1.99-.84 4.1-2.96 3.81l-3.84-.52-4.29.57c-2.13.28-3.78-1.84-2.98-3.83z"
      fill={active ? 'url(#rewardGrad2)' : 'none'} stroke={active ? 'none' : '#C4C7D6'} strokeWidth="2" />
    {active && <defs>
      <linearGradient id="rewardGrad" x1="13" y1="15" x2="4.4" y2="8.2" gradientUnits="userSpaceOnUse"><stop stopColor="#6A74FF"/><stop offset="1" stopColor="#E9E9E9"/></linearGradient>
      <radialGradient id="rewardGrad2" cx="0" cy="0" r="1" gradientTransform="matrix(0 6 -13.6 0 11.5 2)" gradientUnits="userSpaceOnUse"><stop offset="0.13" stopColor="#D194FF"/><stop offset="0.51" stopColor="#A744F3"/><stop offset="0.86" stopColor="#1F0072"/></radialGradient>
    </defs>}
  </svg>
);

/** Collect / My List icon */
export const IconCollect = ({ active = false }: { active?: boolean }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M19 15.5V3H5v18l7-3.5L19 21"
      stroke={active ? '#fff' : '#C4C7D6'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

/** Profile icon */
export const IconProfile = ({ active = false }: { active?: boolean }) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M12 13a5 5 0 100-10 5 5 0 000 10z" stroke={active ? '#fff' : '#C4C7D6'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    <path d="M12 13c-4.42 0-8 3.58-8 8h16c0-4.42-3.58-8-8-8z" stroke={active ? '#fff' : '#C4C7D6'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);
