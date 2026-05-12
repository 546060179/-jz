# Presence 生命周期

`<Presence>` 解决的核心问题：**当一个组件被从 React/Vue 树里移除时，它的退出动画来不及播放就 unmount 了**。

## 不用 Presence 时

```tsx
// ❌ 错误：show 变 false 的瞬间 Motion 直接消失，看不到退出动画
{show && (
  <Motion in={show} effect="scale-fade-in">
    <Modal />
  </Motion>
)}
```

## 用 Presence 时

```tsx
import { Motion, Presence } from '@fade-animation/react';

<Presence>
  {show && (
    <Motion key="modal" in effect="scale-fade-in">
      <Modal />
    </Motion>
  )}
</Presence>
```

`<Presence>` 会：
1. 检测到 `show` 从 true 变 false
2. 保留 Motion 元素在 DOM 中，将 `in` 置为 `false`
3. 等 Motion 播完退出动画（触发 `onAnimationEnd`）
4. 才真正从 DOM 移除

## 关键规则

**子元素必须有 `key`**：Presence 通过 key 追踪元素身份。

**子元素必须支持 `in` 和 `onAnimationEnd`**：`Motion` / `Fade` / `FadeIn` / `FadeOut` 默认支持。把原生 `<div>` 直接放进 Presence 会在 dev 下 console.warn。

## 多元素并行 vs 串行

```tsx
// mode="sync" (默认)：A 退出的同时 B 进入，两者同屏
<Presence>
  {tab === 'a' && <Motion key="a"><PanelA /></Motion>}
  {tab === 'b' && <Motion key="b"><PanelB /></Motion>}
</Presence>

// mode="wait"：B 等 A 完全退出后才进入
<Presence mode="wait">
  {tab === 'a' && <Motion key="a"><PanelA /></Motion>}
  {tab === 'b' && <Motion key="b"><PanelB /></Motion>}
</Presence>
```

## 监听所有退出完成

```tsx
<Presence onExitComplete={() => console.log('All exited')}>
  {show && <Motion key="m" in><M /></Motion>}
</Presence>
```

## 初次挂载不播放动画

```tsx
// 页面加载时，第一批 items 直接显示，不播放进入动画
<Presence :initial="false">
  {items.map((item) => (
    <Motion key={item.id} in><Item /></Motion>
  ))}
</Presence>
```

## 退出途中又恢复

如果用户快速点击"关闭"又立刻"打开"，Presence 会自动取消正在播放的退出动画，让 Motion 重新播放进入动画。不需要手动处理。

## 原生端对应

iOS / Android 上没有 Presence 组件，因为原生端的"从视图树移除"本身就是阻塞调用。对应写法：

```swift
// iOS
modalView.motion(entering: false, effects: EffectPresets.scaleFadeOut) { [weak self] in
  self?.modalView.removeFromSuperview()  // 动画结束才移除
}
```

```kotlin
// Android
MotionAnimator(modalView).start(
  entering = false,
  effects = EffectPresets.SCALE_FADE_OUT,
  onEnd = { (modalView.parent as? ViewGroup)?.removeView(modalView) }
)
```
