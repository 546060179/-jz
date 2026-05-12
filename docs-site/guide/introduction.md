# 介绍

Kinetic UI 是一套跨框架、跨平台的动效设计系统。它把"动效行为"和"视觉样式"解耦，让设计师和开发用同一套 token 体系沟通，让同一个动效可以在 Web、iOS、Android 上精准复现。

## 为什么做这件事

在短视频、短剧等强交互产品里，动效质量直接影响"看起来是否像大厂产品"。但实际开发时有三个常见痛点：

1. **跨端不一致**：同一个弹窗动画，Web 上是 300ms ease-out，iOS 改成 0.4s spring，Android 又换成 350ms OvershootInterpolator。三端看起来完全不同。
2. **无法传达设计意图**：Figma 上写"expressive ease, 500ms"，但代码里只能看到 `cubic-bezier(0.4, 0.14, 0.3, 1)`。设计 token 在翻译过程中丢失了。
3. **重复造轮子**：每个项目都在重新实现 Modal 弹窗的 fade + scale，重新实现 Toast 的 slide-up，重新实现 TypingDots 的交错脉冲。

Kinetic UI 的目标是把这些打包成**一套最小的动效基础设施**：

- 不做完整 UI 组件库（不会有按钮、表单）
- 不做视觉特效库（不会有粒子、3D 背景）
- 只做"让任何 UI 元素正确地进入、退出、反馈"这件事

## 核心原则

**Prop-First**：每个组件通过 props 配置，不需要改源码。

**Intent-Driven**：用 `intent="enter"` 这样的语义化属性自动推导 duration + easing，而不是每次手填 `300` + `cubic-bezier(...)`。

**Cross-Platform Tokens**：`TIMING_SCALES.t3` 在 Web 是 300ms，在 iOS 是 `.t3.durationMs`，在 Android 是 `TimingScale.T3.durationMs` —— 同一个 token 三端都有。

**Accessibility by Default**：自动响应系统的 `prefers-reduced-motion`，开发者不需要手动处理。

## 和其他方案的差异

| | framer-motion | React Spring | Ant Motion | **Kinetic UI** |
|---|---|---|---|---|
| 跨端 | 只有 Web | 只有 Web | 只有 Web | **Web + iOS + Android** |
| 设计 token | 无 | 无 | 有基础 | **完整四维体系** |
| 包大小 | ~60KB | ~30KB | ~100KB | **~15KB (core)** |
| 手势 | 完整 | 无 | 无 | 当前依赖外部库 |
| 布局动画 | FLIP | 无 | 无 | 规划中 |
| 适配声明式原生 | - | - | - | 规划中 (SwiftUI / Compose) |

Kinetic UI **不是** framer-motion 的替代品。在 Web 上做炫酷单页动画时 framer-motion 更强。Kinetic UI 的价值是**四端一致性 + 设计系统对齐**。

## 下一步

- 查看 [安装](./installation)
- 阅读 [快速开始](./quick-start)
- 浏览 [组件总览](/components/overview)
