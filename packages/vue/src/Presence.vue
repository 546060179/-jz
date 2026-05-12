<script lang="ts">
import {
  cloneVNode,
  defineComponent,
  type PropType,
  type VNode,
} from 'vue';

type PresenceState = 'entering' | 'present' | 'exiting';

interface Tracked {
  key: string | number;
  vnode: VNode;
  state: PresenceState;
}

function keyOf(v: VNode, fallbackIndex = 0): string | number {
  if (v.key != null && (typeof v.key === 'string' || typeof v.key === 'number')) {
    return v.key;
  }
  return `__presence_${fallbackIndex}`;
}

function warnIfIncompatible(v: VNode) {
  if (typeof v.type === 'string') {
    console.warn(
      `[Presence] child <${v.type}> is a native DOM element; it cannot receive ` +
        `"in" / "@animation-end". Wrap it in <Motion> or <Fade>.`,
    );
  }
}

function cloneWithProps(
  v: VNode,
  overrides: { in?: boolean; onAnimationEnd?: (...a: unknown[]) => void },
): VNode {
  return cloneVNode(v, overrides);
}

/**
 * 管理子组件的进入 / 退出生命周期。
 *
 * 子组件必须支持：
 *   - `in` prop：控制进入 / 退出
 *   - `@animation-end` emit 或 `onAnimationEnd` prop：通知动画结束
 */
export default defineComponent({
  name: 'Presence',
  props: {
    initial: { type: Boolean, default: true },
    mode: { type: String as PropType<'sync' | 'wait'>, default: 'sync' },
  },
  emits: ['exit-complete'],
  data() {
    return {
      // 响应式：用于触发 re-render
      trackedVersion: 0,
    };
  },
  // 非响应式内部状态
  created() {
    const self = this as unknown as {
      _tracked: Tracked[];
      _pendingEnter: VNode[];
      _prevKeySig: string;
      _mode: string;
    };
    self._tracked = [];
    self._pendingEnter = [];
    self._prevKeySig = '';
    self._mode = this.mode;
  },
  render() {
    // Read reactive counter so changes force re-render
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const _v = this.trackedVersion;

    const self = this as unknown as {
      _tracked: Tracked[];
      _pendingEnter: VNode[];
      _prevKeySig: string;
      _mode: string;
    };

    // 收集当前 children
    const slotVNodes = this.$slots.default?.() ?? [];
    const currentChildren: VNode[] = [];
    const collect = (nodes: unknown[]) => {
      nodes.forEach((n) => {
        if (!n) return;
        if (Array.isArray(n)) {
          collect(n);
        } else if (typeof n === 'object' && 'type' in (n as VNode)) {
          currentChildren.push(n as VNode);
        }
      });
    };
    collect(slotVNodes as unknown[]);

    const currentKeySig =
      currentChildren.map((v, i) => keyOf(v, i)).join('|') + '::' + this.mode;

    // 仅当 children 签名变化时，才同步（否则复用已有 _tracked）
    if (currentKeySig !== self._prevKeySig) {
      if (self._prevKeySig === '') {
        // 首次渲染
        currentChildren.forEach(warnIfIncompatible);
        self._tracked = currentChildren.map((v, i) => {
          const vn = this.initial
            ? v
            : cloneWithProps(v, { in: (v.props?.in as boolean | undefined) !== false });
          return {
            key: keyOf(v, i),
            vnode: vn,
            state: 'entering' as PresenceState,
          };
        });
      } else {
        this.syncChildren(currentChildren);
      }
      self._prevKeySig = currentKeySig;
      self._mode = this.mode;
    }

    return self._tracked.map((t) => cloneVNode(t.vnode, { key: String(t.key) }));
  },
  methods: {
    forceRerender(this: any) {
      this.trackedVersion++;
    },
    handleExit(this: any, exitingKey: string | number, originalHandler?: (...a: unknown[]) => void) {
      return (...args: unknown[]) => {
        const self = this as {
          _tracked: Tracked[];
          _pendingEnter: VNode[];
          forceRerender: () => void;
          $emit: (e: string, ...args: unknown[]) => void;
          mode: string;
        };
        const prev = self._tracked;
        const filtered = prev.filter((x) => x.key !== exitingKey);

        if (self.mode === 'wait' && self._pendingEnter.length > 0) {
          const stillExiting = filtered.some((x) => x.state === 'exiting');
          if (!stillExiting) {
            const pending = self._pendingEnter;
            self._pendingEnter = [];
            pending.forEach((vn, i) => {
              filtered.push({
                key: keyOf(vn, filtered.length + i),
                vnode: vn,
                state: 'entering',
              });
            });
          }
        }

        const anyExiting = filtered.some((x) => x.state === 'exiting');
        const hadExiting = prev.some((x) => x.state === 'exiting');
        self._tracked = filtered;
        self.forceRerender();
        if (!anyExiting && hadExiting) self.$emit('exit-complete');

        if (typeof originalHandler === 'function') originalHandler(...args);
      };
    },
    syncChildren(this: any, current: VNode[]) {
      current.forEach(warnIfIncompatible);

      const self = this as {
        _tracked: Tracked[];
        _pendingEnter: VNode[];
        mode: string;
        handleExit: (k: string | number, o?: (...a: unknown[]) => void) => (...a: unknown[]) => void;
      };

      const prev = self._tracked;
      const prevByKey = new Map(prev.map((t) => [t.key, t]));
      const currentKeys = new Set<string | number>();
      current.forEach((v, i) => currentKeys.add(keyOf(v, i)));

      const willHaveExiting =
        prev.some((x) => x.state === 'exiting') ||
        prev.some((x) => !currentKeys.has(x.key));

      const next: Tracked[] = [];

      current.forEach((vn, i) => {
        const key = keyOf(vn, i);
        const existing = prevByKey.get(key);

        if (!existing) {
          if (self.mode === 'wait' && willHaveExiting) {
            self._pendingEnter.push(vn);
          } else {
            next.push({ key, vnode: vn, state: 'entering' });
          }
        } else if (existing.state === 'exiting') {
          const revived = cloneWithProps(vn, { in: true });
          next.push({ key, vnode: revived, state: 'entering' });
        } else {
          next.push({ key, vnode: vn, state: 'present' });
        }
      });

      prev.forEach((t, idx) => {
        if (currentKeys.has(t.key)) return;
        if (t.state === 'exiting') {
          next.splice(Math.min(idx, next.length), 0, t);
          return;
        }
        const origHandler = (t.vnode.props?.onAnimationEnd ?? null) as
          | ((...a: unknown[]) => void)
          | null;
        const patched = cloneWithProps(t.vnode, {
          in: false,
          onAnimationEnd: self.handleExit(t.key, origHandler ?? undefined),
        });
        next.splice(Math.min(idx, next.length), 0, {
          key: t.key,
          vnode: patched,
          state: 'exiting',
        });
      });

      self._tracked = next;
    },
  },
});
</script>
