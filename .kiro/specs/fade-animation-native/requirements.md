# 需求文档

## 简介

Fade Animation Native 是对现有 Fade Animation Library 的原生平台扩展，新增 Android (Kotlin) 和 iOS (Swift) 两个原生平台的适配。该扩展保持与 Web 版本一致的 API 设计理念和功能特性，提供 FadeIn（淡入）和 FadeOut（淡出）两个核心组件，以及统一的 Fade 组件（通过 `in` 属性控制方向）。支持自定义动画属性（时长、延迟、缓动函数）、预设速度方案、动画结束回调，以及原生平台的无障碍动效偏好检测（Android Animator duration scale、iOS UIAccessibility.isReduceMotionEnabled）。所有组件均提供强类型定义（Kotlin 类型安全、Swift 类型安全）。

## 术语表

- **Animation_Library**: 淡入淡出动效组件库的整体系统（原生平台扩展部分）
- **FadeIn_Component**: 淡入动画组件，将子视图从透明渐变为可见
- **FadeOut_Component**: 淡出动画组件，将子视图从可见渐变为透明
- **Fade_Component**: 统一淡入淡出组件，通过 `in` 属性控制动画方向
- **Duration**: 动画持续时长，单位为毫秒（ms）
- **Delay**: 动画开始前的延迟时间，单位为毫秒（ms）
- **Easing**: 缓动函数，控制动画的速度曲线（Android 使用 TimeInterpolator，iOS 使用 UIView.AnimationCurve 或自定义 timing function）
- **Preset_Speed**: 预设速度方案，包含 fast（150ms）、normal（300ms）、slow（600ms）三种
- **onAnimationEnd_Callback**: 动画结束时触发的回调函数
- **Reduced_Motion_Android**: Android 系统中的 Animator duration scale 设置，当值为 0 时表示用户关闭了动画效果
- **Reduced_Motion_iOS**: iOS 系统中的 UIAccessibility.isReduceMotionEnabled 设置，当值为 true 时表示用户启用了"减少动态效果"
- **Android_View**: Android 平台的 View 组件，作为动画的目标载体
- **iOS_UIView**: iOS 平台的 UIView 组件，作为动画的目标载体

## 需求

### 需求 1：FadeIn 淡入动画组件

**用户故事：** 作为原生移动端开发者，我希望使用 FadeIn 组件包裹子视图，使其以淡入效果出现在屏幕上。

#### 验收标准

1. WHEN FadeIn_Component 被添加到视图层级时，THE FadeIn_Component SHALL 将子视图的不透明度从 0 过渡到 1
2. THE FadeIn_Component SHALL 默认使用 normal Preset_Speed（300ms）作为 Duration
3. THE FadeIn_Component SHALL 默认使用 0ms 作为 Delay
4. THE FadeIn_Component SHALL 默认使用平台原生的 ease 缓动曲线作为 Easing（Android: AccelerateDecelerateInterpolator，iOS: .curveEaseInOut）
5. WHEN Duration 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Duration 值覆盖默认值
6. WHEN Delay 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Delay 值覆盖默认值
7. WHEN Easing 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Easing 值覆盖默认值

### 需求 2：FadeOut 淡出动画组件

**用户故事：** 作为原生移动端开发者，我希望使用 FadeOut 组件包裹子视图，使其以淡出效果从屏幕上消失。

#### 验收标准

1. WHEN FadeOut_Component 被添加到视图层级时，THE FadeOut_Component SHALL 将子视图的不透明度从 1 过渡到 0
2. THE FadeOut_Component SHALL 默认使用 normal Preset_Speed（300ms）作为 Duration
3. THE FadeOut_Component SHALL 默认使用 0ms 作为 Delay
4. THE FadeOut_Component SHALL 默认使用平台原生的 ease 缓动曲线作为 Easing
5. WHEN Duration 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Duration 值覆盖默认值
6. WHEN Delay 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Delay 值覆盖默认值
7. WHEN Easing 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Easing 值覆盖默认值

### 需求 3：统一 Fade 组件

**用户故事：** 作为原生移动端开发者，我希望使用统一的 Fade 组件，通过 `in` 属性灵活控制淡入或淡出方向，并支持运行时动态切换。

#### 验收标准

1. THE Fade_Component SHALL 提供 `in` 布尔属性控制动画方向
2. WHEN `in` 属性为 true 时，THE Fade_Component SHALL 执行淡入动画（不透明度从 0 到 1）
3. WHEN `in` 属性为 false 时，THE Fade_Component SHALL 执行淡出动画（不透明度从 1 到 0）
4. WHEN `in` 属性在运行时从 true 变为 false（或从 false 变为 true）时，THE Fade_Component SHALL 触发对应方向的新动画过渡
5. WHEN `in` 属性未被传入时，THE Fade_Component SHALL 默认使用 true（淡入行为）
6. THE FadeIn_Component SHALL 等价于 `in` 属性为 true 的 Fade_Component
7. THE FadeOut_Component SHALL 等价于 `in` 属性为 false 的 Fade_Component

### 需求 4：预设速度方案

**用户故事：** 作为原生移动端开发者，我希望通过预设速度名称快速设置动画时长，而不必每次手动指定毫秒值。

#### 验收标准

1. WHEN "fast" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 150ms
2. WHEN "normal" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 300ms
3. WHEN "slow" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 600ms
4. WHEN Preset_Speed 和自定义 Duration 同时被传入时，THE Animation_Library SHALL 优先使用自定义 Duration 值

### 需求 5：动画结束回调

**用户故事：** 作为原生移动端开发者，我希望在动画播放结束后执行自定义逻辑（如移除视图、触发下一步操作）。

#### 验收标准

1. WHEN 动画过渡完成时，THE FadeIn_Component SHALL 调用 onAnimationEnd_Callback（如果已传入）
2. WHEN 动画过渡完成时，THE FadeOut_Component SHALL 调用 onAnimationEnd_Callback（如果已传入）
3. WHEN onAnimationEnd_Callback 未被传入时，THE Animation_Library SHALL 正常完成动画而不触发任何回调
4. THE Animation_Library SHALL 确保 onAnimationEnd_Callback 在每次动画完成时仅被调用一次

### 需求 6：Android 平台无障碍 - Animator Duration Scale

**用户故事：** 作为对动画敏感的 Android 用户，我希望当系统关闭动画效果（Animator duration scale 为 0）时，动画被自动跳过，以避免不适。

#### 验收标准

1. WHILE Android 系统的 Animator duration scale 设置为 0 时，THE Animation_Library SHALL 将 Duration 设置为 0ms 以跳过动画
2. WHILE Android 系统的 Animator duration scale 设置为 0 时，THE Animation_Library SHALL 将 Delay 设置为 0ms
3. WHILE Android 系统的 Animator duration scale 设置为 0 时，THE Animation_Library SHALL 仍然调用 onAnimationEnd_Callback（如果已传入）
4. WHEN Android 系统的 Animator duration scale 在运行时发生变化时，THE Animation_Library SHALL 在下一次动画触发时应用新的设置

### 需求 7：iOS 平台无障碍 - Reduce Motion

**用户故事：** 作为对动画敏感的 iOS 用户，我希望当系统开启"减少动态效果"时，动画被自动跳过，以避免不适。

#### 验收标准

1. WHILE iOS 系统的 UIAccessibility.isReduceMotionEnabled 为 true 时，THE Animation_Library SHALL 将 Duration 设置为 0ms 以跳过动画
2. WHILE iOS 系统的 UIAccessibility.isReduceMotionEnabled 为 true 时，THE Animation_Library SHALL 将 Delay 设置为 0ms
3. WHILE iOS 系统的 UIAccessibility.isReduceMotionEnabled 为 true 时，THE Animation_Library SHALL 仍然调用 onAnimationEnd_Callback（如果已传入）
4. WHEN iOS 系统的 Reduce Motion 设置在运行时发生变化时，THE Animation_Library SHALL 在下一次动画触发时应用新的设置

### 需求 8：Android (Kotlin) 平台实现

**用户故事：** 作为 Android 开发者，我希望在 Android 项目中直接导入并使用 Kotlin 实现的 FadeIn、FadeOut 和 Fade 组件。

#### 验收标准

1. THE Animation_Library SHALL 提供 Kotlin 实现的 FadeIn_Component、FadeOut_Component 和 Fade_Component
2. THE Animation_Library SHALL 使用 Android 原生的 ObjectAnimator 或 ViewPropertyAnimator 实现不透明度动画
3. THE Animation_Library SHALL 支持将任意 Android_View 作为动画目标子视图
4. THE Animation_Library SHALL 为所有组件提供 Kotlin 强类型定义（使用 sealed class 或 enum class 定义 Preset_Speed）
5. THE Animation_Library SHALL 使用 Kotlin 的可空类型（nullable types）标记所有可选参数
6. WHEN 组件从视图层级移除时，THE Animation_Library SHALL 取消正在进行的动画并清理资源，防止内存泄漏

### 需求 9：iOS (Swift) 平台实现

**用户故事：** 作为 iOS 开发者，我希望在 iOS 项目中直接导入并使用 Swift 实现的 FadeIn、FadeOut 和 Fade 组件。

#### 验收标准

1. THE Animation_Library SHALL 提供 Swift 实现的 FadeIn_Component、FadeOut_Component 和 Fade_Component
2. THE Animation_Library SHALL 使用 UIView.animate 或 UIViewPropertyAnimator 实现不透明度动画
3. THE Animation_Library SHALL 支持将任意 iOS_UIView 作为动画目标子视图
4. THE Animation_Library SHALL 为所有组件提供 Swift 强类型定义（使用 enum 定义 PresetSpeed）
5. THE Animation_Library SHALL 使用 Swift 的 Optional 类型标记所有可选参数
6. WHEN 组件从视图层级移除时，THE Animation_Library SHALL 取消正在进行的动画并清理资源，防止内存泄漏

### 需求 10：输入校验与降级处理

**用户故事：** 作为原生移动端开发者，我希望在传入无效属性值时获得合理的降级行为，而不是应用崩溃。

#### 验收标准

1. IF Duration 传入负数值，THEN THE Animation_Library SHALL 使用默认 Duration（300ms）
2. IF Delay 传入负数值，THEN THE Animation_Library SHALL 使用默认 Delay（0ms）
3. IF Preset_Speed 传入不在 "fast" | "normal" | "slow" 范围内的值，THEN THE Animation_Library SHALL 使用 normal Preset_Speed（300ms）
4. IF onAnimationEnd_Callback 为 null 时，THEN THE Animation_Library SHALL 正常完成动画而不触发任何回调
5. IF Easing 传入 null 或无效值时，THEN THE Animation_Library SHALL 使用平台默认的 ease 缓动曲线
