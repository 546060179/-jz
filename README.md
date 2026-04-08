# Fade Animation Library

跨框架、跨平台的动效设计系统。提供系统化的 Motion Design Tokens、多种动效效果、编排工具，支持 React、Vue、Android (Kotlin)、iOS (Swift)。

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

// 编排：多元素交错淡入
<FadeGroup in={show} intent="enter" stagger={{ interval: 50 }}>
  <Card>1</Card>
  <Card>2
  <Card>3</Card>
</FadeGroup>
```

### Vue

```vue
<template>
  <Fade :in="show" intent="enter">Hello</Fade>

  <Motion :in="show" effect="slide-up-in" intent="enter">
    <Card />
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

// 通用动效：缩放淡入
view.scaleFadeIn()

// 从下方滑入
view.slideUpIn()

// 自定义组合
view.motion(
    entering = true,
    effects = listOf(
        MotionEffect.Fade(from = 0f, to = 1f),
        MotionEffect.Scale(from = 0.9f, to = 1f),
        MotionEffect.Slide(direction = SlideDirection.UP, distance = 24f)
    ),
    options = FadeOptions(timing = TimingScale.T3)
)
```

### iOS (Swift)

```swift
// 基础淡入
view.fadeIn()

// 使用 intent
view.fadeIn(options: FadeOptions(intent: .enter))

// 通用动效：缩放淡入
view.scaleFadeIn()

// 从下方滑入
view.slideUpIn()

// 自定义组合
view.motion(
    entering: true,
    effects: [
        .fade(from: 0, to: 1),
        .scale(from: 0.9, to: 1),
        .slide(direction: .up, distance: 24)
    ],
    options: FadeOptions(timing: .t3)
)
```

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

## 工具函数

### dynamicDuration — 动态时长

根据元素尺寸和移动距离自动推算合理时长：

```ts
import { dynamicDuration } from '@fade-animation/core';

dynamicDuration({ size: 50 })   // → 100ms (小组件)
dynamicDuration({ size: 300 })  // → 300ms (中等)
dynamicDuration({ distance: 200 }) // → 200ms
```

### stagger — 编排工具

计算多元素交错延迟：

```ts
import { stagger } from '@fade-animation/core';

stagger(5, { interval: 50 })
// → [0, 50, 100, 150, 200]

stagger(5, { interval: 50, direction: 'center' })
// → [100, 50, 0, 50, 100]

stagger(5, { interval: 50, direction: 'reverse' })
// → [200, 150, 100, 50, 0]
```

### CSS Token 输出

生成 CSS Custom Properties，供非框架页面使用：

```ts
import { generateCSSTokens, injectCSSTokens } from '@fade-animation/core';

// 生成 CSS 字符串
const css = generateCSSTokens();
// :root { --motion-t1: 100ms; --motion-easing-enter: cubic-bezier(...); ... }

// 直接注入到 <head>
injectCSSTokens();
```

### Motion Level — 动效级别控制

```ts
import { setMotionLevel } from '@fade-animation/core';

setMotionLevel('full');     // 完整动效
setMotionLevel('reduced');  // 减弱动效（clamp 到 100ms，保留过渡感）
setMotionLevel('none');     // 完全跳过动画
setMotionLevel(undefined);  // 跟随系统 prefers-reduced-motion
```

## Props 优先级

duration 解析优先级：`duration` > `timing` > `preset` > `intent` > 默认值 (300ms)

easing 解析优先级：`easing` > `intent` > 默认值 ('ease')

## 无障碍

- 自动检测 `prefers-reduced-motion`（Web）、`Animator duration scale`（Android）、`UIAccessibility.isReduceMotionEnabled`（iOS）
- 支持 `setMotionLevel()` 全局覆盖
- `reduced` 模式保留过渡感但缩短到 100ms，`none` 模式完全跳过

## 测试

```bash
npx vitest --run  # 运行全部 116 个测试
```

## License

MIT
