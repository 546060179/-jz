// Drama UI Design Tokens — Auto-generated from Figma

export const colors = {
  // White / Transparent
  fillWhite: '#FFFFFF',
  fillWhite1: 'rgba(255, 255, 255, 0.2)',
  textWhite: 'rgba(255, 255, 255, 0.68)',
  // Blue
  bgBlue: '#141621',
  fillBlue: '#5A68FF',
  textBlue: '#C4C7D6',
  bgBlue1: 'rgba(20, 22, 33, 0.12)',
  fillBlue1: '#545472',
  bgBlue2: 'rgba(194, 202, 240, 0.12)',
  bgBlue3: '#050713',
  textBlue1: '#6C7398',
  // Red
  fillRed: '#FA5E7B',
  // Orange
  textOrange: '#FFE0B5',
} as const;

export const gradients = {
  new: 'linear-gradient(90deg, #CECECE 0%, #6A74FF 100%)',
  hot: 'linear-gradient(90deg, #CECECE 0%, #FA5E7B 100%)',
  tabBorder: 'linear-gradient(90deg, #CECECE 0%, #4051FF 100%)',
  cover: 'linear-gradient(180deg, rgba(20,22,33,0) 0%, #141621 100%)',
  dividerLeft: 'linear-gradient(90deg, rgba(194,202,240,0) 0%, rgba(194,202,240,0.12) 100%)',
  dividerRight: 'linear-gradient(90deg, rgba(194,202,240,0.12) 0%, rgba(194,202,240,0) 100%)',
} as const;

export const spacing = { xs: 4, sm: 8, md: 12, base: 16, lg: 24, xl2: 40, xl3: 52 } as const;
export const radius = { sm: 6, md: 8, base: 12, lg: 16, xl: 20, full: 100 } as const;

export const typography = {
  captionMedium: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 500, fontSize: 9, lineHeight: '1.25em' },
  captionRegular: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 400, fontSize: 9, lineHeight: '1.25em' },
  captionRegular1: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 400, fontSize: 10, lineHeight: '1.25em' },
  bodySmLight: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 12, lineHeight: '1.25em' },
  bodySmMedium: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 500, fontSize: 12, lineHeight: '1.25em' },
  bodyRegular: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 400, fontSize: 14, lineHeight: '1.25em' },
  bodyLgLight: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 16, lineHeight: '1.25em' },
  headingSm: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 400, fontSize: 20, lineHeight: '1.25em' },
  headingLg: { fontFamily: "'Lexend Deca', sans-serif", fontWeight: 300, fontSize: 28, lineHeight: '1.25em' },
} as const;

export const effects = {
  blurBg: 'blur(40px)',
  shadowInner: 'inset 0px -1px 3px 0px rgba(255, 255, 255, 1)',
  shadowDrop: '0px 1px 4px 0px rgba(127, 115, 255, 0.6)',
  shadowTab: '0px 4px 8px 0px rgba(127, 115, 255, 0.59)',
} as const;
