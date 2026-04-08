import React from 'react';
import { Fade, type FadeComponentProps } from './Fade';

export type FadeInProps = Omit<FadeComponentProps, 'in'>;

/**
 * FadeIn 便捷别名，等价于 `<Fade in={true} {...props}>`。
 */
export const FadeIn: React.FC<FadeInProps> = (props) => {
  return <Fade in={true} {...props} />;
};
