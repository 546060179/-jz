# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与 [语义化版本](https://semver.org/lang/zh-CN/)。

三端(`@fade-animation/core`·`@fade-animation/react`·`@fade-animation/vue`、Android `com.fadeanimation:fade-animation-android`、iOS `FadeAnimation` SwiftPM)版本号统一发布，共享同一份跨端契约 `contract/motion-contract.json`。

## [0.3.0] - 2026-07-21

### Added
- **业务组件三端补齐**：`BubbleExpand`、`ContinueWatching`、`ToastView`、`NotificationBanner`、`SpotlightOverlayView` 五个组件在 iOS(Swift)与 Android(Kotlin)均已提供，类名一致。
- **Web 业务组件**：React/Vue 新增 `BubbleExpand`、`ContinueWatching`；Vue 补齐 `TypingDots`（此前仅 React 有），实现框架间对等。
- **缓动与预设**：新增 `bounce` 缓动与 `bounce-in`/`zoom-in`/`zoom-slide-in`/`spin-in` 预设（五端）。
- **契约扩展**：`contract/motion-contract.json` 新增 `effectPresets.blurFadeIn` 与 `components`(BubbleExpand 的 zeta/omega/时长、ContinueWatching 5 段时长)，三端契约测试各加断言。Web 组件默认值统一取自 core `componentDefaults`。
- **Android 运行时测试**：新增 5 个 View 组件的 Robolectric 冒烟测试（`kotlin("jvm")` 模块经 aar→classes.jar transform 消费 androidx.test）。

### Changed
- **blur-in 观感统一（破坏性观感变更，非 API）**：`blur-fade-in` 预设由 `fade(0→1)+blur(8→0)` 改为 `fade(0.6→1)+blur(14→0)`，"由糊变清"成为主视觉，与纯淡入清晰区分。iOS `applyBlur` 归一分母 8→14。五端一致。
- **文档**：`docs/components.html` 中库外效果的 iOS/Android/Web 示例代码全部指向真实库 API（消除引用不存在类的伪代码）。

### Notes
- `blur` 单效果默认值仍为 8px（仅 `blur-fade-in` 预设参数调整）。
- `marquee` / `vip-shimmer` 等长时循环动效有意不进库，文档建议用 CSS/平台原生实现。

## [0.2.0] - 早期

### Added
- Web 端 `Motion`/`Fade`/`FadeGroup`/`Presence`/`TypingDots`(React)、Spring 物理、序列编排、Collapse/Flip 效果。
- 跨端一致性契约 `contract/motion-contract.json` 与三端契约测试、CI 三端并行 job。

## [0.1.0] - 初始

### Added
- Motion Design Tokens（timing/distance/easing/intent）、`fade`/`scale`/`slide`/`rotate`/`blur` 效果与预设，React/Vue/iOS/Android 四端基础实现。

[0.3.0]: https://github.com/546060179/-jz/releases/tag/v0.3.0
