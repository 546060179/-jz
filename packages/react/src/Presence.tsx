import React, {
  Children,
  cloneElement,
  isValidElement,
  useCallback,
  useEffect,
  useRef,
  useState,
  type ReactElement,
  type ReactNode,
} from 'react';

/**
 * 子节点必须带有 `key` 属性，Presence 通过 key 追踪哪些元素进入 / 离开。
 * 当一个元素从 children 中移除时，Presence 保留它并触发退出动画，
 * 动画完成后再从 DOM 销毁。
 *
 * 子节点需要接受 `in` 和 `onAnimationEnd` 两个 prop（Motion / Fade 默认支持）。
 */

/** 子组件必须满足的最小 props 约束 */
export interface PresenceChildProps {
  /** 是否进入（true）或退出（false） */
  in?: boolean;
  /** 动画结束回调，Presence 用它来决定何时卸载元素 */
  onAnimationEnd?: () => void;
}

export type PresenceChild = ReactElement<PresenceChildProps>;

export interface PresenceProps {
  /** 子节点，必须是带 key 的 Motion / Fade / 其他支持 in + onAnimationEnd 的组件 */
  children?: ReactNode;
  /** 所有子节点都退出后触发 */
  onExitComplete?: () => void;
  /** 初次挂载是否播放进入动画，默认 true */
  initial?: boolean;
  /**
   * 退出模式：
   * - `'sync'` (默认): 多个子节点同时退出时并行播放
   * - `'wait'`: 多个子节点退出时串行播放，前一个退出动画完成后才播放下一个；
   *   同时，如果有退出中的元素，新元素的进入会等到所有退出完成后才开始
   */
  mode?: 'sync' | 'wait';
}

interface TrackedChild {
  key: string;
  element: PresenceChild;
  /** 'entering' | 'present' | 'exiting' | 'pending-enter' (wait 模式下排队中) */
  state: 'entering' | 'present' | 'exiting' | 'pending-enter';
}

function toKey(child: ReactElement, index: number): string {
  const k = (child as ReactElement & { key?: string | null }).key;
  return k != null ? String(k) : `__presence_${index}`;
}

function getValidChildren(children: ReactNode): PresenceChild[] {
  const arr: PresenceChild[] = [];
  Children.forEach(children, (c) => {
    if (isValidElement(c)) arr.push(c as PresenceChild);
  });
  return arr;
}

/**
 * 开发环境下，对第一次看到的子组件检查是否支持 `in` 和 `onAnimationEnd`。
 * 这只是一次性 console.warn，不影响运行。
 */
function warnIfIncompatible(child: PresenceChild): void {
  // 只对原生 DOM 元素做检查；自定义组件无法在运行时内省 props
  if (typeof child.type === 'string') {
    // eslint-disable-next-line no-console
    console.warn(
      `[Presence] child <${child.type}> is a native DOM element; it cannot receive ` +
        `"in" / "onAnimationEnd" props. Wrap it in <Motion> or <Fade> so Presence can ` +
        `drive the exit animation.`,
    );
  }
}

/**
 * 管理子组件的进入和退出生命周期。
 *
 * @example 基础用法（sync 模式）
 * <Presence>
 *   {show && (
 *     <Motion key="modal" in effect="scale-fade-in">
 *       <Modal />
 *     </Motion>
 *   )}
 * </Presence>
 *
 * @example 多元素串行退出（wait 模式）
 * <Presence mode="wait">
 *   {tab === 'a' && <Motion key="a"><PanelA /></Motion>}
 *   {tab === 'b' && <Motion key="b"><PanelB /></Motion>}
 * </Presence>
 */
export const Presence: React.FC<PresenceProps> = ({
  children,
  onExitComplete,
  initial = true,
  mode = 'sync',
}) => {
  const currentChildren = getValidChildren(children);
  const currentKeys = currentChildren.map((c, i) => toKey(c, i));

  const [tracked, setTracked] = useState<TrackedChild[]>(() => {
    currentChildren.forEach(warnIfIncompatible);
    return currentChildren.map((el, i) => ({
      key: toKey(el, i),
      element: initial ? el : cloneElement(el, { in: el.props.in !== false }),
      state: 'entering',
    }));
  });

  const isFirstRenderRef = useRef(true);
  const onExitCompleteRef = useRef(onExitComplete);
  /** wait 模式下排队中、等待退出完成后再进入的子节点 */
  const pendingEnterRef = useRef<PresenceChild[]>([]);

  useEffect(() => {
    onExitCompleteRef.current = onExitComplete;
  });

  /** 处理单个元素的退出动画完成：从 tracked 中移除，触发 onExitComplete，启动任何排队的进入 */
  const handleExitEnd = useCallback(
    (exitingKey: string, originalOnAnimationEnd?: () => void) => {
      setTracked((list) => {
        const filtered = list.filter((x) => x.key !== exitingKey);

        // wait 模式：所有 exiting 都结束了，把 pending-enter 转换为 entering
        if (mode === 'wait' && pendingEnterRef.current.length > 0) {
          const stillExiting = filtered.some((x) => x.state === 'exiting');
          if (!stillExiting) {
            const pending = pendingEnterRef.current;
            pendingEnterRef.current = [];
            pending.forEach((el) => {
              filtered.push({
                key: toKey(el, 0),
                element: el,
                state: 'entering',
              });
            });
          }
        }

        // 所有退出都完成
        const anyExiting = filtered.some((x) => x.state === 'exiting');
        if (!anyExiting && onExitCompleteRef.current) {
          const hasAnyLeaving = list.some((x) => x.state === 'exiting');
          if (hasAnyLeaving) onExitCompleteRef.current();
        }

        return filtered;
      });

      if (typeof originalOnAnimationEnd === 'function') originalOnAnimationEnd();
    },
    [mode],
  );

  useEffect(() => {
    if (isFirstRenderRef.current) {
      isFirstRenderRef.current = false;
      return;
    }

    // 新出现的子节点检查兼容性
    currentChildren.forEach(warnIfIncompatible);

    setTracked((prev) => {
      const prevByKey = new Map(prev.map((t) => [t.key, t]));
      const currentByKey = new Map(
        currentChildren.map((el, i) => [toKey(el, i), { el, index: i }]),
      );

      // 判断本轮结束后是否还会有 exiting 元素（包括这轮新标记的）
      const willHaveExiting =
        prev.some((x) => x.state === 'exiting') ||
        prev.some((x) => !currentByKey.has(x.key));

      const next: TrackedChild[] = [];

      // 1. 先保留/重建当前 children 中列出的节点
      currentChildren.forEach((el, i) => {
        const key = toKey(el, i);
        const existing = prevByKey.get(key);

        if (!existing) {
          // 全新节点
          if (mode === 'wait' && willHaveExiting) {
            // wait 模式：有元素即将或正在退出，当前节点进入排队
            pendingEnterRef.current.push(el);
            // 不加入 next —— 保持不可见直到 pending 被处理
          } else {
            next.push({ key, element: el, state: 'entering' });
          }
        } else if (existing.state === 'exiting') {
          // 之前在退出，现在又出现 → 取消退出，强制触发进入
          // 关键：clone 出一个新的 element 并强制 in=true，这样 Motion 会重新播放进入动画
          const revived = cloneElement(el, {
            in: true,
          });
          next.push({ key, element: revived, state: 'entering' });
        } else {
          // 已存在且非退出状态：更新为当前 element
          next.push({ key, element: el, state: 'present' });
        }
      });

      // 2. 处理不在当前 children 中的旧节点：标记退出
      prev.forEach((t) => {
        if (currentByKey.has(t.key)) return;

        if (t.state === 'exiting') {
          // 已经在退出中：保留到原位置
          const originalIndex = prev.indexOf(t);
          next.splice(Math.min(originalIndex, next.length), 0, t);
          return;
        }

        // 之前是 entering/present，现在标记为退出
        const exitingElement = cloneElement(t.element, {
          in: false,
          onAnimationEnd: () => handleExitEnd(t.key, t.element.props.onAnimationEnd),
        });
        const originalIndex = prev.indexOf(t);
        next.splice(Math.min(originalIndex, next.length), 0, {
          key: t.key,
          element: exitingElement,
          state: 'exiting',
        });
      });

      return next;
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentKeys.join('|'), mode]);

  return <>{tracked.map((t) => cloneElement(t.element, { key: t.key }))}</>;
};
