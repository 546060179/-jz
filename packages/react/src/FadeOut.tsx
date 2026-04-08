import React from 'react';
import { Fade, type FadeComponentProps } from './Fade';

export type FadeOutProps = Omit<FadeComponentProps, 'in'>;

/**
 * FadeOut 便捷别名，等价于 `<Fade in={false} {...props}>`。
 */
export const FadeOut: React.FC<FadeOutProps> = (props) => {
  return <Fade in={false} {...props} />;
};
