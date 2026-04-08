# Fade Animation Library

跨框架、跨平台的动效设计系统。提供系统化的 Motion Design Tokens、7 种动效效果、编排工具，支持 React、Vue、Android (Kotlin)、iOS (Swift)。

## 支持的效果

| 效果 | 说明 | Web | Android | iOS |
|------|------|-----|---------|-----|
| fade | 透明度渐变 | ✅ | ✅ | ✅ |
| scale | 缩放 | ✅ | ✅ | ✅ |
| slide | 位移滑动 | ✅ | ✅ | ✅ |
| rotate | 2D 旋转 | ✅ | ✅ | ✅ |
| blur | 模糊 | ✅ | ✅ (API 31+) | ✅ |
| flip | 3D 翻转 | ✅ | ✅ | ✅ |
| collapse | 折叠展开 | ✅ | ✅ | ✅ |

## 包结构

```
packages/
├── core/     # @fade-animation/core — 框架无关的核心逻辑、tokens、工具函数
├── react/    # @fade-animation/react — React 组件（Fade、Motion、FadeGroup）
├── vue/      # @fade-animation/vue — Vue 组件（Fade、Motion、FadeGroup）
├── android/  # Android Kotlin 模块（FadeAnimator、MotionAnimator）
└── ios/      # iOS Swift Package（FadeAnimator、MotionAnimator）
```

## 快速开始

### React

```tsx
import { Fade, Motion, FadeGroup } from '@fade-animation/react';

// 基础淡入
<Fade in={show}>Hello</Fade>

// 使用 intent 自动推导 timing + easing
<Fade in={show} intent="enter">Hello</Fade>

// 通用动效：缩放淡入
<Motion in={show} effect="scale-fade-in" intent="enter">
  <Card />
</Motion>

// 3D 翻转
<Motion in={show} effect="flip-y-in">
  <Card />
</Motion>

// 折叠展开（手风琴效果）
<Motion in={expanded} effect={[{ type: 'collapse' }, { type: 'fade' }]}>
  <CollapsibleContent />
</Motion>

// 自定义效果组合
<Motion
  in={show}
  effect={[
    { type: 'fade', from: 0, to: 1 },
    { type: 'flip', axis: 'x', from: 90, to: 0 },
  ]}
  duration={500}
>
  <Card />
</Motion>

// 编排：多元素交错淡入
<FadeGroup in={show} intent="enter" stagger={{ interval: 50 }}>
  <Card>1</Card>
  <Card>2</Card>
  <Card>3</Card>
</FadeGroup>
```

### Vue

```vue
<template>
  <Fade :in="show" intent="enter">Hello</Fade>

  <Motion :in="show" effect="flip-y-in">
    <Card />
  </Motion>

  <Motion :in="expanded" :effect="[{ type: 'collapse' }, { type: 'fade' }]">
    <CollapsibleContent />
  </Motion>

  <FadeGroup :in="show" intent="enter" :stagger-interval="50">
    <Card>1</Card>
    <Card>2</Card>
  </FadeGroup>
</template>

<script setup>
import { Fade, Motion, FadeGroup } from '@fade-animation/vue';
</script>
```

### Android (Kotlin)

```kotlin
// 基础淡入
view.fadeIn()

// 使用 intent
view.fadeIn(options = FadeOptions(intent = MotionIntent.ENTER))

// 3D 翻转
val animator = MotionAnimator(view)
animator.start(entering = true, effects = EffectPresets.FLIP_Y_IN)

// 折叠展开
animator.start(entering = true, effects = EffectPresets.COLLAPSE_IN)

// 自定义组合
animator.start(
    entering = true,
    effects = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Flip(axis = FlipAxis.X, from = 90f, to = 0f)
    ),
    onEnd = { /* 动画结束 */ }
)
```

### iOS (Swift)

```swift
// 基础淡入
view.fadeIn()

// 使用 intent
view.fadeIn(options: FadeOptions(intent: .enter))

// 3D 翻转
let animator = MotionAnimator(targetView: view)
animator.start(entering: true, effects: EffectPresets.flipYIn)

// 折叠展开
animator.start(entering: true, effects: EffectPresets.collapseIn)

// 自定义组合
animator.start(entering: true, effects: [
    .fade(from: 0, to: 1),
    .flip(axis: .x, from: 90, to: 0)
])
```

## 效果类型详解

### fade — 透明度

```tsx
{ type: 'fade', from: 0, to: 1 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| from | number | 0 (enter) / 1 (exit) | 起始透明度 |
| to | number | 1 (enter) / 0 (exit) | 目标透明度 |

### scale — 缩放

```tsx
{ type: 'scale', from: 0.95, to: 1 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| from | number | 0.95 (enter) / 1 (exit) | 起始缩放比 |
| to | number | 1 (enter) / 0.95 (exit) | 目标缩放比 |

### slide — 位移

```tsx
{ type: 'slide', direction: 'up', distance: 16 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| direction | 'up' \| 'down' \| 'left' \| 'right' | 'up' | 滑动方向 |
| distance | number | 16 | 滑动距离 (px) |

### rotate — 2D 旋转

```tsx
{ type: 'rotate', from: -10, to: 0 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| from | number | -10 (enter) / 0 (exit) | 起始角度 (deg) |
| to | number | 0 (enter) / 10 (exit) | 目标角度 (deg) |

### blur — 模糊

```tsx
{ type: 'blur', from: 8, to: 0 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| from | number | 8 (enter) / 0 (exit) | 起始模糊半径 (px) |
| to | number | 0 (enter) / 8 (exit) | 目标模糊半径 (px) |

### flip — 3D 翻转

```tsx
{ type: 'flip', axis: 'y', from: 90, to: 0, perspective: 800 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| axis | 'x' \| 'y' | 'y' | 翻转轴 |
| from | number | 0 | 起始角度 (deg) |
| to | number | 180 | 目标角度 (deg) |
| perspective | number | 800 | 透视距离 (px) |
| backfaceVisibility | 'visible' \| 'hidden' | 'hidden' | 背面可见性 |
| flipped | boolean | — | 布尔快捷方式：true=0→180, false=180→0 |

> ⚠️ flip 和 rotate 不能同时使用，同时存在时 rotate 会被忽略并输出警告。

### collapse — 折叠展开

```tsx
{ type: 'collapse', collapsedHeight: 0 }
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| collapsedHeight | number | 0 | 折叠后高度 (px) |

折叠效果会自动测量子内容高度，展开完成后设置 max-height 为 none 允许内容自由伸缩。首次渲染不播放动画。

## Effect Presets（效果预设）

| 预设名 | 效果 | 说明 |
|--------|------|------|
| fade-in | fade(0→1) | 淡入 |
| fade-out | fade(1→0) | 淡出 |
| scale-fade-in | fade + scale(0.95→1) | 缩放淡入 |
| scale-fade-out | fade + scale(1→0.95) | 缩放淡出 |
| slide-up-in | fade + slide↑ | 从下方滑入 |
| slide-down-out | fade + slide↓ | 向下滑出 |
| slide-left-in | fade + slide← | 从左侧滑入 |
| slide-right-in | fade + slide→ | 从右侧滑入 |
| rotate-fade-in | fade + rotate(-10→0) | 旋转淡入 |
| rotate-fade-out | fade + rotate(0→10) | 旋转淡出 |
| blur-fade-in | fade + blur(8→0) | 模糊淡入 |
| blur-fade-out | fade + blur(0→8) | 模糊淡出 |
| flip-x-in | fade + flip X轴(90→0) | X轴翻转进入 |
| flip-x-out | fade + flip X轴(0→90) | X轴翻转退出 |
| flip-y-in | fade + flip Y轴(90→0) | Y轴翻转进入 |
| flip-y-out | fade + flip Y轴(0→90) | Y轴翻转退出 |
| collapse-in | fade + collapse(0→auto) | 折叠展开 |
| collapse-out | fade + collapse(auto→0) | 折叠收起 |

## Motion Design Tokens

### Timing Scales（时间刻度）

| Token | 别名 | 值 | 用途 |
|-------|------|-----|------|
| t1 | extra-fast | 100ms | 微交互、按钮状态 |
| t2 | fast | 150ms | tooltip、badge |
| t3 | normal | 300ms | 卡片、面板 |
| t4 | slow | 500ms | 页面切换 |
| t5 | extra-slow | 700ms | 复杂编排、全屏过渡 |

### Easing Curves（缓动曲线）

| 名称 | 值 | 用途 |
|------|-----|------|
| productive | cubic-bezier(0.2, 0, 0.38, 0.9) | 功能性动效 |
| expressive | cubic-bezier(0.4, 0.14, 0.3, 1) | 表现性动效 |
| enter | cubic-bezier(0, 0, 0.3, 1) | 元素进入 |
| exit | cubic-bezier(0.4, 0, 1, 1) | 元素离开 |
| linear | linear | 循环动画 |

### Motion Intent（动效意图）

| Intent | 默认 Timing | 默认 Easing | 用途 |
|--------|------------|------------|------|
| enter | t3 (300ms) | enter | 元素进入视图 |
| exit | t2 (150ms) | exit | 元素离开视图 |
| focus | t2 (150ms) | expressive | 吸引注意力 |
| feedback | t1 (100ms) | productive | 操作反馈 |
| delight | t4 (500ms) | expressive | 品牌个性 |

### Distance Scales（距离刻度）

| Token | 别名 | 值 | 用途 |
|-------|------|-----|------|
| d1 | micro | 4px | 图标抖动 |
| d2 | small | 8px | tooltip 弹出 |
| d3 | medium | 16px | 卡片滑动 |
| d4 | large | 32px | 抽屉滑出 |
| d5 | full | 64px | 全屏过渡 |

## 工具函数

### dynamicDuration — 动态时长

根据元素尺寸和移动距离自动推算合理时长：

```ts
import { dynamicDuration } from '@fade-animation/core';

dynamicDuration({ size: 50 })      // → 100ms (小组件)
dynamicDuration({ size: 300 })     // → 300ms (中等)
dynamicDuration({ distance: 200 }) // → 200ms
```

### stagger — 编排工具

计算多元素交错延迟：

```ts
import { stagger } from '@fade-animation/core';

stagger(5, { interval: 50 })                          // → [0, 50, 100, 150, 200]
stagger(5, { interval: 50, direction: 'center' })     // → [100, 50, 0, 50, 100]
stagger(5, { interval: 50, direction: 'reverse' })    // → [200, 150, 100, 50, 0]
```

### CSS Token 输出

```ts
import { generateCSSTokens, injectCSSTokens } from '@fade-animation/core';

const css = generateCSSTokens();  // 生成 CSS Custom Properties 字符串
injectCSSTokens();                // 直接注入到 <head>
```

### Motion Level — 动效级别控制

```ts
import { setMotionLevel } from '@fade-animation/core';

setMotionLevel('full');      // 完整动效
setMotionLevel('reduced');   // 减弱动效（clamp 到 100ms）
setMotionLevel('none');      // 完全跳过动画
setMotionLevel(undefined);   // 跟随系统 prefers-reduced-motion
```

## Props 优先级

duration 解析：`duration` > `timing` > `preset` > `intent` > 默认值 (300ms)

easing 解析：`easing` > `intent` > 默认值 ('ease')

## 无障碍

- 自动检测 `prefers-reduced-motion`（Web）、`Animator duration scale`（Android）、`UIAccessibility.isReduceMotionEnabled`（iOS）
- 支持 `setMotionLevel()` 全局覆盖
- `reduced` 模式保留过渡感但缩短到 100ms，`none` 模式完全跳过

## 开发

```bash
pnpm install    # 安装依赖
pnpm build      # 构建所有 Web 包
pnpm test       # 运行全部 162 个测试
```

## License

MIT
