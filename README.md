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

## 安装 / 接入

### Web（React / Vue）

```bash
npm install @fade-animation/react   # 或 @fade-animation/vue
# 依赖 @fade-animation/core 会被自动带入
```

### iOS（Swift Package Manager）

`packages/ios` 是一个独立的 Swift Package（`FadeAnimation`，最低 iOS 13），全部 API 已 `public`，可直接依赖。

- Xcode：File → Add Package Dependencies… 填入仓库地址，选择 `FadeAnimation` 库。
- 或在 `Package.swift` 中：

```swift
dependencies: [
    // 本地路径依赖（monorepo 内）
    .package(path: "packages/ios")
    // 或独立仓库：.package(url: "https://github.com/<org>/fade-animation-ios", from: "0.1.0")
]
```

```swift
import FadeAnimation

view.fadeIn(options: FadeOptions(intent: .enter))
MotionAnimator(targetView: card).start(entering: true, effects: EffectPresets.scaleFadeIn)
```

### Android（Gradle / Maven）

`packages/android` 通过 `maven-publish` 发布，坐标 `com.fadeanimation:fade-animation-android:0.1.0`。

```bash
# 发到本地 ~/.m2 便于验证
cd packages/android && ./gradlew publishToMavenLocal
```

```kotlin
// settings.gradle.kts 里确保有 mavenLocal()（或你的私有仓库）
dependencyResolutionManagement {
    repositories { mavenLocal(); google(); mavenCentral() }
}

// app/build.gradle.kts
dependencies {
    implementation("com.fadeanimation:fade-animation-android:0.1.0")
}
```

```kotlin
import com.fadeanimation.*

view.fadeIn(options = FadeOptions(intent = MotionIntent.ENTER))
MotionAnimator(card).start(entering = true, effects = EffectPresets.SCALE_FADE_IN)
```

> 说明：Android 端为 `kotlin("jvm")` 库，Android framework 依赖为 `compileOnly`，由宿主 App 在运行时提供（兼容 API 21+）。

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
| blur-fade-in | fade(0.6→1) + blur(14→0) | 模糊淡入（"由糊变清"，刻意留 0.6 初始透明度以区别于纯淡入） |
| blur-fade-out | fade(1→0) + blur(0→14) | 模糊淡出 |
| flip-x-in | fade + flip X轴(90→0) | X轴翻转进入 |
| flip-x-out | fade + flip X轴(0→90) | X轴翻转退出 |
| flip-y-in | fade + flip Y轴(90→0) | Y轴翻转进入 |
| flip-y-out | fade + flip Y轴(0→90) | Y轴翻转退出 |
| collapse-in | fade + collapse(0→auto) | 折叠展开 |
| collapse-out | fade + collapse(auto→0) | 折叠收起 |
| bounce-in | fade + scale(0.3→1) | 弹性缩放进入（配 easing="bounce"） |
| zoom-in | fade + scale(0.5→1) | 缩放进入（图片/卡片聚焦） |
| zoom-slide-in | fade + scale(0.9→1) + slide↑ | 缩放上滑进入 |
| spin-in | fade + rotate(-180→0) | 旋转进入 |

## 预置动效组件（业务组件）

除通用效果预设外，库还内置了一批开箱即用的业务动效组件。这些组件封装了完整的视图 + 动画逻辑，对应 `docs/components.html` 里 native/custom 类效果。**iOS（Swift）与 Android（Kotlin）均已提供，类名一致。**

| 组件（iOS / Android 同名） | 对应效果 | 说明 |
|------------|---------|------|
| `TypingDotsView` | 打字点点 | 聊天"正在输入"跑马灯脉冲 |
| `MarqueePulseAnimator` | 跑马灯/脉冲 | 元素循环流光/脉冲 |
| `BubbleExpandView` | 气泡展开 | 阻尼谐振子弹性展开 + 文字后段淡入 |
| `ToastView` | Toast 提示 | pill 消息条（配合 MotionAnimator 滑入） |
| `NotificationBanner` | 通知横幅 | 应用内通知卡片（图标 + 标题） |
| `SpotlightOverlayView` | 聚光灯引导 | 半透明遮罩挖空高亮 + 提示 |
| `ContinueWatchingView` | 最近播放浮层 | 5 阶段序列：滑入→停留→详情淡出→收缩→变形小浮窗 |

> **Web（React / Vue）** 也导出了对应的业务组件：`TypingDots`、`BubbleExpand`、`ContinueWatching`（`@fade-animation/react` 与 `@fade-animation/vue` 同名，用 scaleX 弹簧展开 / CSS transition 分阶段驱动，尊重 `prefers-reduced-motion`）。

```swift
// 气泡展开
let bubble = BubbleExpandView()
bubble.text = "限时免费"
bubble.expandDuration = 0.65
bubble.arrowDirection = .right
view.addSubview(bubble)
bubble.play()

// 最近播放浮层
let bar = ContinueWatchingView()
bar.configure(cover: UIImage(named: "cover"), title: "剧名", subtitle: "EP.1 / EP.100")
view.addSubview(bar)
bar.show()
```

```kotlin
// Android — 类名与参数和 iOS 对齐
// 气泡展开
val bubble = BubbleExpandView(context)
bubble.text = "限时免费"
bubble.expandDurationMs = 650L
bubble.arrowDirection = BubbleExpandView.ArrowDirection.RIGHT
container.addView(bubble)
bubble.play()

// 最近播放浮层：滑入→停留→详情淡出→收缩→变形小浮窗
val bar = ContinueWatchingView(context)
bar.timing = CWTiming(collapseDelay = 3000L)
bar.configure(cover = drawable, title = "剧名", subtitle = "EP.1 / EP.100")
container.addView(bar)
bar.show()
```

> Android 端组件为 `kotlin("jvm")` 库中的 `View` 子类，Android framework 依赖为 `compileOnly`，由宿主 App 在运行时提供。逻辑层（Spring/Stagger/契约等）由 JVM 单测覆盖；`View` 组件由 Robolectric 冒烟测试在纯 JVM 下验证可实例化/绘制/触发动画不崩（`NativeComponentsSmokeTest`）。像素级真机表现仍建议在模拟器/真机上确认。

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
| bounce | cubic-bezier(0.34, 1.56, 0.64, 1) | 过冲回落，弹性入场 |

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

原生端同名 API（数值与 Web 完全一致）：

```swift
// iOS
let delays = stagger(items.count, options: StaggerOptions(interval: 60))
```

```kotlin
// Android
val delays = stagger(items.size, StaggerOptions(interval = 60L))
```

### planSequence — 序列编排

按顺序累计每步的 delay + duration，返回每步应使用的累计延迟。四端一致：

```ts
import { planSequence } from '@fade-animation/core';

const plan = planSequence([
  { effects: [{ type: 'fade' }], duration: 350 },
  { effects: [{ type: 'scale', from: 0.3, to: 1 }], delay: 50, duration: 700 },
]);
// plan.stepDelays / plan.stepDurations / plan.totalDuration
```

### spring — 弹簧物理

基于阻尼谐振子模型（stiffness / damping / mass），四端共用同一套数值积分，手感一致。预设：`gentle` / `snappy` / `bouncy` / `slow` / `noWobble`。

```tsx
// React：useSpring 返回 0→1 进度，帧率无关（120Hz / 60Hz 一致）
const progress = useSpring(show, { config: 'bouncy' });
<div style={{ transform: `scale(${0.9 + 0.1 * progress})` }} />
```

```swift
// iOS：SpringAnimator 用 CADisplayLink 驱动，回调 0→1 进度
let anim = SpringAnimator(config: SpringPresets.bouncy)
anim.start(onUpdate: { p in view.transform = CGAffineTransform(scaleX: 0.9 + 0.1 * p, y: 0.9 + 0.1 * p) })
```

```kotlin
// Android：SpringAnimator 用 Choreographer 驱动
val anim = SpringAnimator(SpringPresets.BOUNCY)
anim.start(onUpdate = { p -> view.scaleX = 0.9f + 0.1f * p; view.scaleY = 0.9f + 0.1f * p })
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
# Web（core + react + vue，共 203 个测试）
pnpm install
pnpm build
pnpm test

# iOS（67 个测试，含 public API 黑盒冒烟测试、预置组件冒烟测试与跨端契约测试）
cd packages/ios && xcodebuild -scheme FadeAnimation -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Android（62 个测试：57 逻辑 + 5 Robolectric View 冒烟；已固定 Gradle daemon 使用 JDK 17）
cd packages/android && ./gradlew test
```

> 注：Android 使用 `gradle/gradle-daemon-jvm.properties` 将 Gradle 守护进程固定到 JDK 17（当前 Kotlin 2.1.10 工具链无法在 JDK 25 下运行）。

## 跨端一致性契约

`contract/motion-contract.json` 是动效设计令牌的**单一事实源**（timing / distance / easing 控制点 / intent 默认 / spring 预设）。三端各有一份契约测试读取同一份 JSON 并断言各自实现与之一致：

- Web：`packages/core/src/contract.test.ts`
- iOS：`packages/ios/Tests/FadeAnimationTests/ContractTests.swift`
- Android：`packages/android/src/test/kotlin/com/fadeanimation/ContractTest.kt`

这样当某个令牌（如新增 `bounce` 缓动）只改了部分端时，对应端的契约测试会立即失败，避免"端上表现和 Web 不一致"的回归。`.github/workflows/ci.yml` 在每次 push / PR 时并行跑三端测试。

## License

MIT
