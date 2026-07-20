import React, { type ReactNode, Children } from 'react';
import { stagger, type StaggerOptions, type FadeProps } from '@fade-animation/core';
import { Fade } from './Fade';

export interface FadeGroupProps extends Omit<FadeProps, 'delay'> {
  /** 编排配置 */
  stagger: StaggerOptions;
  children?: ReactNode;
}

/**
 * 编排组件：为多个子元素自动计算交错延迟，实现有节奏的淡入/淡出效果。
 *
 * @example
 * <FadeGroup in={true} intent="enter" stagger={{ interval: 50 }}>
 *   <Card>1</Card>
 *   <Card>2</Card>
 *   <Card>3</Card>
 * </FadeGroup>
 */
export const FadeGroup: React.FC<FadeGroupProps> = ({
  stagger: staggerOpts,
  children,
  ...fadeProps
}) => {
  const childArray = Children.toArray(children);
  const delays = stagger(childArray.length, staggerOpts);

  return (
    <>
      {childArray.map((child, index) => {
        // 优先复用子元素自身的 key，避免用数组下标做 key 导致列表
        // 增删/重排时 React 复用错误的 DOM 节点、动画错乱。
        const childKey =
          React.isValidElement(child) && child.key != null ? child.key : index;
        return (
          <Fade key={childKey} {...fadeProps} delay={delays[index]}>
            {child}
          </Fade>
        );
      })}
    </>
  );
};
