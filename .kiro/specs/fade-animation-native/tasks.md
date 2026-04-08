# 实现计划：Fade Animation Native

## 概述

基于需求文档和设计文档，将 Fade Animation Native 的实现拆分为 Android (Kotlin) 和 iOS (Swift) 两个平台模块。每个平台按照「数据模型 → 配置解析 → 动画控制器 → 扩展函数 → 集成联调」的顺序递增实现，确保每一步都可独立验证。

## 任务

- [x] 1. Android 模块：数据模型与默认值
  - [x] 1.1 创建 Android 模块项目结构和基础文件
    - 创建 Kotlin 源码目录和测试目录
    - 配置 JUnit 5 和 jqwik 依赖
    - _Requirements: 8.1, 8.4_

  - [x] 1.2 实现 `PresetSpeed` 枚举和 `Defaults` 常量对象
    - 定义 `PresetSpeed` enum class，包含 FAST(150)、NORMAL(300)、SLOW(600)
    - 定义 `Defaults` object，包含 DURATION=300L、DELAY=0L、INTERPOLATOR=AccelerateDecelerateInterpolator()、PRESET=PresetSpeed.NORMAL
    - _Requirements: 4.1, 4.2, 4.3, 8.4_

  - [x] 1.3 实现 `FadeOptions` 数据类和 `FadeConfig` 数据类
    - `FadeOptions`：fadeIn、duration、delay、interpolator、preset、onAnimationEnd，所有可选参数使用 Kotlin 可空类型
    - `FadeConfig`：duration、delay、interpolator、reducedMotion，所有字段非空
    - _Requirements: 8.4, 8.5_

- [x] 2. Android 模块：配置解析逻辑 `resolveConfig`
  - [x] 2.1 实现 `ReducedMotionHelper` 对象
    - 通过 `Settings.Global.ANIMATOR_DURATION_SCALE` 检测动画缩放值
    - 值为 0 时返回 true
    - _Requirements: 6.1, 6.2_

  - [x] 2.2 实现 `resolveConfig(options: FadeOptions, context: Context): FadeConfig`
    - 负数 duration 回退 300ms，负数 delay 回退 0ms
    - 无效 preset 回退 NORMAL
    - 自定义 duration 优先于 preset
    - null interpolator 回退 AccelerateDecelerateInterpolator
    - reduced-motion 启用时 duration=0、delay=0
    - _Requirements: 1.2-1.7, 2.2-2.7, 4.1-4.4, 6.1, 6.2, 10.1-10.5_

  - [ ]* 2.3 编写 resolveConfig 属性测试 — Property 1: 自定义值覆盖默认值
    - **Property 1: 自定义值覆盖默认值**
    - 生成随机非负 duration/delay 和有效 interpolator，验证输出与输入一致
    - **Validates: Requirements 1.5, 1.6, 1.7, 2.5, 2.6, 2.7**

  - [ ]* 2.4 编写 resolveConfig 属性测试 — Property 2: 自定义 Duration 优先于预设速度
    - **Property 2: 自定义 Duration 优先于预设速度**
    - 生成随机 PresetSpeed 和随机非负 duration，验证自定义 duration 优先
    - **Validates: Requirements 4.4**

  - [ ]* 2.5 编写 resolveConfig 属性测试 — Property 3: 负数 Duration/Delay 回退默认值
    - **Property 3: 负数 Duration/Delay 回退默认值**
    - 生成随机负数 duration/delay，验证回退到默认值
    - **Validates: Requirements 10.1, 10.2**

  - [ ]* 2.6 编写 resolveConfig 属性测试 — Property 4: 无效预设速度回退默认值
    - **Property 4: 无效预设速度回退默认值**
    - 生成无效 preset 输入，验证回退到 300ms
    - **Validates: Requirements 10.3**

  - [ ]* 2.7 编写 resolveConfig 属性测试 — Property 5: Reduced-motion 下 Duration 和 Delay 归零
    - **Property 5: Reduced-motion 下 Duration 和 Delay 归零**
    - 生成任意配置组合，mock reduced-motion 为 true，验证 duration 和 delay 为 0
    - **Validates: Requirements 6.1, 6.2**

  - [ ]* 2.8 编写 resolveConfig 单元测试
    - 测试默认值返回 duration=300, delay=0, easing=AccelerateDecelerateInterpolator
    - 测试预设速度映射 fast→150, normal→300, slow→600
    - 测试 null easing 回退平台默认
    - _Requirements: 1.2-1.4, 2.2-2.4, 4.1-4.3, 10.5_

- [x] 3. Android 模块：FadeAnimator 核心动画控制器
  - [x] 3.1 实现 `FadeAnimator` 类
    - 构造函数接收 targetView: View 和 options: FadeOptions
    - `start(fadeIn, onEnd)` 方法：调用 resolveConfig 获取配置，使用 ViewPropertyAnimator 执行 alpha 动画
    - `cancel()` 方法：取消当前动画并清理
    - 通过 withEndAction 或 AnimatorListenerAdapter 触发 onEnd 回调，确保仅调用一次
    - 监听 onViewDetachedFromWindow 自动取消动画
    - _Requirements: 1.1, 2.1, 3.1-3.5, 5.1-5.4, 8.2, 8.3, 8.6_

  - [ ]* 3.2 编写 FadeAnimator 属性测试 — Property 8: fadeIn 属性决定不透明度方向
    - **Property 8: fadeIn 属性决定不透明度方向**
    - 生成随机 boolean 值，验证 fadeIn=true 时目标 opacity=1，fadeIn=false 时目标 opacity=0
    - **Validates: Requirements 1.1, 2.1, 3.2, 3.3**

  - [ ]* 3.3 编写 FadeAnimator 属性测试 — Property 7: 回调仅触发一次
    - **Property 7: 回调仅触发一次**
    - 执行带回调的动画，验证回调调用次数为 1
    - **Validates: Requirements 5.1, 5.2, 5.4**

  - [ ]* 3.4 编写 FadeAnimator 属性测试 — Property 6: Reduced-motion 下回调仍被调用
    - **Property 6: Reduced-motion 下回调仍被调用**
    - mock reduced-motion 为 true，验证回调被调用恰好一次
    - **Validates: Requirements 6.3**

  - [ ]* 3.5 编写 FadeAnimator 属性测试 — Property 9: 运行时切换 fadeIn 触发新动画
    - **Property 9: 运行时切换 fadeIn 属性触发新动画**
    - 启动动画后切换 fadeIn 方向重新调用 start，验证目标 opacity 随之改变
    - **Validates: Requirements 3.4**

  - [ ]* 3.6 编写 FadeAnimator 属性测试 — Property 11: 视图移除时取消动画
    - **Property 11: 视图移除时取消动画并清理资源**
    - 启动动画后模拟视图移除，验证动画被取消且无回调触发
    - **Validates: Requirements 8.6**

- [x] 4. Android 模块：View 扩展函数与集成
  - [x] 4.1 实现 View 扩展函数 `fadeIn()`、`fadeOut()`、`fade()`
    - `fadeIn()` 等价于 `fade(fadeIn = true)`
    - `fadeOut()` 等价于 `fade(fadeIn = false)`
    - `fade()` 默认 fadeIn=true
    - _Requirements: 3.5, 3.6, 3.7, 8.1_

  - [ ]* 4.2 编写扩展函数属性测试 — Property 10: FadeIn/FadeOut 与 Fade 的等价性
    - **Property 10: FadeIn/FadeOut 与 Fade 的等价性**
    - 生成随机 FadeOptions，验证 fadeIn() 与 fade(fadeIn: true) 配置等价，fadeOut() 与 fade(fadeIn: false) 等价
    - **Validates: Requirements 3.6, 3.7**

- [x] 5. Checkpoint — Android 模块验证
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. iOS 模块：数据模型与默认值
  - [x] 6.1 创建 iOS 模块项目结构和基础文件
    - 创建 Swift 源码目录和测试目录
    - 配置 XCTest 和 SwiftCheck 依赖
    - _Requirements: 9.1, 9.4_

  - [x] 6.2 实现 `PresetSpeed` 枚举和 `Defaults` 常量枚举
    - 定义 `PresetSpeed` enum，包含 fast(150)、normal(300)、slow(600)
    - 定义 `Defaults` enum，包含 duration=300、delay=0、curve=.easeInOut、preset=.normal
    - _Requirements: 4.1, 4.2, 4.3, 9.4_

  - [x] 6.3 实现 `FadeOptions` 结构体和 `FadeConfig` 结构体
    - `FadeOptions`：fadeIn、duration、delay、curve、preset、onAnimationEnd，所有可选参数使用 Swift Optional
    - `FadeConfig`：duration(TimeInterval)、delay(TimeInterval)、curve、reducedMotion，所有字段非可选
    - _Requirements: 9.4, 9.5_

- [x] 7. iOS 模块：配置解析逻辑 `resolveConfig`
  - [x] 7.1 实现 `ReducedMotionHelper` 枚举
    - 通过 `UIAccessibility.isReduceMotionEnabled` 检测
    - _Requirements: 7.1, 7.2_

  - [x] 7.2 实现 `resolveConfig(options: FadeOptions) -> FadeConfig`
    - 负数 duration 回退 300ms，负数 delay 回退 0ms
    - 无效 preset 回退 .normal
    - 自定义 duration 优先于 preset
    - nil curve 回退 .easeInOut
    - reduced-motion 启用时 duration=0、delay=0
    - 内部将毫秒转换为秒（TimeInterval）
    - _Requirements: 1.2-1.7, 2.2-2.7, 4.1-4.4, 7.1, 7.2, 10.1-10.5_

  - [ ]* 7.3 编写 resolveConfig 属性测试 — Property 1: 自定义值覆盖默认值
    - **Property 1: 自定义值覆盖默认值**
    - 生成随机非负 duration/delay 和有效 curve，验证输出与输入一致
    - **Validates: Requirements 1.5, 1.6, 1.7, 2.5, 2.6, 2.7**

  - [ ]* 7.4 编写 resolveConfig 属性测试 — Property 2: 自定义 Duration 优先于预设速度
    - **Property 2: 自定义 Duration 优先于预设速度**
    - **Validates: Requirements 4.4**

  - [ ]* 7.5 编写 resolveConfig 属性测试 — Property 3: 负数 Duration/Delay 回退默认值
    - **Property 3: 负数 Duration/Delay 回退默认值**
    - **Validates: Requirements 10.1, 10.2**

  - [ ]* 7.6 编写 resolveConfig 属性测试 — Property 4: 无效预设速度回退默认值
    - **Property 4: 无效预设速度回退默认值**
    - **Validates: Requirements 10.3**

  - [ ]* 7.7 编写 resolveConfig 属性测试 — Property 5: Reduced-motion 下 Duration 和 Delay 归零
    - **Property 5: Reduced-motion 下 Duration 和 Delay 归零**
    - mock isReduceMotionEnabled 为 true，验证 duration 和 delay 为 0
    - **Validates: Requirements 7.1, 7.2**

  - [ ]* 7.8 编写 resolveConfig 单元测试
    - 测试默认值返回 duration=0.3s, delay=0s, curve=.easeInOut
    - 测试预设速度映射 fast→0.15s, normal→0.3s, slow→0.6s
    - 测试 nil curve 回退平台默认
    - _Requirements: 1.2-1.4, 2.2-2.4, 4.1-4.3, 10.5_

- [x] 8. iOS 模块：FadeAnimator 核心动画控制器
  - [x] 8.1 实现 `FadeAnimator` 类
    - init 接收 targetView: UIView 和 options: FadeOptions
    - `start(fadeIn:onEnd:)` 方法：调用 resolveConfig 获取配置，使用 UIView.animate 执行 alpha 动画
    - `cancel()` 方法：取消当前动画并清理
    - 通过 completion block 触发 onEnd 回调，确保仅调用一次
    - 在 deinit 中自动取消动画并清理资源
    - _Requirements: 1.1, 2.1, 3.1-3.5, 5.1-5.4, 9.2, 9.3, 9.6_

  - [ ]* 8.2 编写 FadeAnimator 属性测试 — Property 8: fadeIn 属性决定不透明度方向
    - **Property 8: fadeIn 属性决定不透明度方向**
    - **Validates: Requirements 1.1, 2.1, 3.2, 3.3**

  - [ ]* 8.3 编写 FadeAnimator 属性测试 — Property 7: 回调仅触发一次
    - **Property 7: 回调仅触发一次**
    - **Validates: Requirements 5.1, 5.2, 5.4**

  - [ ]* 8.4 编写 FadeAnimator 属性测试 — Property 6: Reduced-motion 下回调仍被调用
    - **Property 6: Reduced-motion 下回调仍被调用**
    - **Validates: Requirements 7.3**

  - [ ]* 8.5 编写 FadeAnimator 属性测试 — Property 9: 运行时切换 fadeIn 触发新动画
    - **Property 9: 运行时切换 fadeIn 属性触发新动画**
    - **Validates: Requirements 3.4**

  - [ ]* 8.6 编写 FadeAnimator 属性测试 — Property 11: 视图移除时取消动画
    - **Property 11: 视图移除时取消动画并清理资源**
    - **Validates: Requirements 9.6**

- [x] 9. iOS 模块：UIView 扩展方法与集成
  - [x] 9.1 实现 UIView 扩展方法 `fadeIn()`、`fadeOut()`、`fade()`
    - `fadeIn()` 等价于 `fade(fadeIn: true)`
    - `fadeOut()` 等价于 `fade(fadeIn: false)`
    - `fade()` 默认 fadeIn=true
    - _Requirements: 3.5, 3.6, 3.7, 9.1_

  - [ ]* 9.2 编写扩展方法属性测试 — Property 10: FadeIn/FadeOut 与 Fade 的等价性
    - **Property 10: FadeIn/FadeOut 与 Fade 的等价性**
    - **Validates: Requirements 3.6, 3.7**

- [x] 10. Checkpoint — iOS 模块验证
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. 最终检查点
  - 确认 Android 和 iOS 两个模块所有测试通过
  - 确认所有需求（1-10）均已被实现任务覆盖
  - Ensure all tests pass, ask the user if questions arise.

## 备注

- 标记 `*` 的子任务为可选测试任务，可跳过以加速 MVP 交付
- 每个任务引用了具体的需求编号，确保可追溯性
- Android 使用 JUnit 5 + jqwik 进行属性测试，iOS 使用 XCTest + SwiftCheck
- 属性测试验证设计文档中的 11 个正确性属性，单元测试覆盖边界情况
- 检查点任务确保增量验证
