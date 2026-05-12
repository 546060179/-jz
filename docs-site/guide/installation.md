# 安装

Kinetic UI 按端独立发布。根据你的项目选择对应包：

## Web — React

```bash
npm install @fade-animation/react
# 或
pnpm add @fade-animation/react
```

核心包 `@fade-animation/core` 会被自动拉下来作为依赖。

## Web — Vue 3

```bash
npm install @fade-animation/vue
```

> Vue 2 暂未支持。如果你在 Vue 2 项目中需要动效，可以用 `@fade-animation/core` 直接调用底层工具（`stagger`、`planSequence`、`createSpring` 等）。

## iOS — Swift Package Manager

在 `Package.swift` 里加：

```swift
dependencies: [
  .package(url: "https://github.com/xxx/fade-animation-ios.git", from: "0.2.0")
]
```

然后 `import FadeAnimation`。

## Android — Gradle

在 `build.gradle.kts` 里加：

```kotlin
dependencies {
  implementation("com.fadeanimation:fade-animation:0.2.0")
}
```

## 仅需要 token 体系（框架无关）

如果只想用 tokens 或弹簧引擎，不用包组件：

```bash
npm install @fade-animation/core
```

Core 包导出 `TIMING_SCALES`、`EASING_CURVES`、`createSpring`、`stagger`、`planSequence`、`resolveConfig` 等底层工具。

## Peer Dependencies

| 包 | peer |
|---|---|
| `@fade-animation/react` | React >= 16.8 |
| `@fade-animation/vue` | Vue >= 3.3 |
| `FadeAnimation` (iOS) | iOS 13+ |
| `com.fadeanimation` (Android) | API 21+ |
