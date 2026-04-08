# 实现计划：Flip & Collapse 效果

## 概述

在现有 Fade Animation Library 的 effects 体系上扩展 Flip（3D 翻转）和 Collapse（折叠展开）两种动效。实现覆盖 Core（TypeScript）、React、Vue、Android（Kotlin）、iOS（Swift）五个层面，按"类型定义 → CSS 解析 → 冲突检测 → Web 组件 → 原生平台 → 预设 → 测试"的顺序递增推进。

## 任务

- [x] 1. Core 层：FlipEffect 与 CollapseEffect 类型定义
  - [x] 1.1 在 `packages/core/src/effects.ts` 中新增 FlipEffect 接口
    - type 字段值为 `"flip"`
    - 可选属性：axis（`"x" | "y"`，默认 `"y"`）、from（默认 0）、to（默认 180）、perspective（默认 800）、backfaceVisibility（`"visible" | "hidden"`，默认 `"hidden"`）、flipped（可选布尔值）
    - 将 FlipEffect 加入 MotionEffect 联合类型和 EffectType
    - _需求：1.1, 1.2, 1.3, 1.4, 1.5, 17.1, 19.1_

  - [x] 1.2 在 `packages/core/src/effects.ts` 中新增 CollapseEffect 接口
    - type 字段值为 `"collapse"`
    - 可选属性：collapsedHeight（`number`，默认 0）
    - 将 CollapseEffect 加入 MotionEffect 联合类型和 EffectType
    - _需求：2.1, 2.2, 2.3_

  - [ ]* 1.3 为 FlipEffect 和 CollapseEffect 类型定义编写单元测试
    - 在 `packages/core/src/effects.test.ts` 中验证默认值、类型区分
    - _需求：23.1_

- [x] 2. Core 层：resolveEffectStyles 扩展 Flip 解析
  - [x] 2.1 在 `packages/core/src/resolveEffectStyles.ts` 中实现 FlipEffect 的 CSS 样式解析
    - 根据 axis 生成 `perspective(Npx) rotateX/Y(deg)` transform 函数
    - 处理 flipped 布尔语义：flipped=true 时 from=0, to=180；flipped=false 时 from=180, to=0；from/to 优先
    - entering=true 时 from→to，entering=false 时 to→from
    - 设置 `backface-visibility` 样式
    - 将 transform 函数按效果数组顺序拼接到同一 transform 属性
    - 将 `"transform"` 加入 transitionProperties
    - _需求：3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 17.2, 19.2, 19.3, 19.4_

  - [ ]* 2.2 为 FlipEffect CSS 解析编写属性测试
    - **属性 1：Flip 样式解析幂等性** — 相同 FlipEffect 参数多次传入返回相同结果
    - **验证：需求 24.1, 24.3**

  - [ ]* 2.3 为 FlipEffect CSS 解析编写单元测试
    - 覆盖 axis=x/y、自定义 from/to、flipped 布尔值、backfaceVisibility、与其他 transform 效果组合
    - _需求：23.2, 24.1_

- [x] 3. Core 层：resolveEffectStyles 扩展 Collapse 解析
  - [x] 3.1 在 `packages/core/src/resolveEffectStyles.ts` 中实现 CollapseEffect 的 CSS 样式解析
    - 函数签名扩展：增加可选 `contentHeight?: number` 参数，由 Motion 组件传入实际测量高度
    - entering=true：from 的 max-height 为 `collapsedHeight + "px"`，to 的 max-height 为 `contentHeight + "px"`
    - entering=false：from 的 max-height 为 `contentHeight + "px"`，to 的 max-height 为 `collapsedHeight + "px"`
    - from 和 to 均设置 `overflow: "hidden"`
    - 将 `"max-height"` 加入 transitionProperties
    - _需求：4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [ ]* 3.2 为 CollapseEffect CSS 解析编写属性测试
    - **属性 2：Collapse 样式解析幂等性** — 相同 CollapseEffect 参数多次传入返回相同结果
    - **验证：需求 24.2, 24.4**

  - [ ]* 3.3 为 CollapseEffect CSS 解析编写单元测试
    - 覆盖 entering=true/false、自定义 collapsedHeight、contentHeight 传入
    - _需求：23.2, 24.2_

- [x] 4. Core 层：冲突检测与效果预设
  - [x] 4.1 在 `packages/core/src/resolveEffectStyles.ts` 中实现 Flip + Rotate 冲突检测
    - 预设展开后检测：先将预设名称解析为效果数组，再检测
    - 同时存在时 console.warn 输出格式化警告，忽略 RotateEffect，优先执行 FlipEffect
    - _需求：12.1, 12.2, 12.4, 12.5_

  - [x] 4.2 在 `packages/core/src/effects.ts` 的 EFFECT_PRESETS 中新增 Flip 预设
    - `flip-x-in`：绕 X 轴从 90deg→0deg + fade in
    - `flip-x-out`：绕 X 轴从 0deg→90deg + fade out
    - `flip-y-in`：绕 Y 轴从 90deg→0deg + fade in
    - `flip-y-out`：绕 Y 轴从 0deg→90deg + fade out
    - _需求：5.1, 5.2, 5.3, 5.4_

  - [x] 4.3 在 `packages/core/src/effects.ts` 的 EFFECT_PRESETS 中新增 Collapse 预设
    - `collapse-in`：collapsedHeight=0 + fade in
    - `collapse-out`：collapsedHeight=0 + fade out
    - _需求：6.1, 6.2_

  - [ ]* 4.4 为冲突检测和新预设编写单元测试
    - 验证 Flip+Rotate 冲突时 console.warn 被调用、RotateEffect 被忽略
    - 验证所有新预设的效果数组内容正确
    - _需求：12.1, 12.2, 12.4, 23.3_

  - [ ]* 4.5 为冲突检测编写属性测试
    - **属性 3：Flip+Rotate 互斥** — 任意包含 Flip 和 Rotate 的效果数组，解析结果中不包含 rotate transform
    - **验证：需求 12.1, 12.2**

- [x] 5. 检查点 — Core 层验证
  - 确保所有 Core 层测试通过，如有问题请向用户确认。

- [x] 6. Web 组件层：React Motion 扩展 Collapse 支持
  - [x] 6.1 在 `packages/react/src/Motion.tsx` 中扩展 Collapse 高度测量与初始渲染逻辑
    - 检测效果数组中是否包含 CollapseEffect
    - 使用 `useRef` 标记首次渲染，跳过初始动画（需求 20.4）
    - 首次渲染：expanded=false 时直接设置 max-height 为 collapsedHeight；expanded=true 时设置 max-height 为 none
    - 使用 `scrollHeight` 测量子内容实际高度
    - 使用 `ResizeObserver` 监听子内容高度变化，更新内部 contentHeight 记录
    - 展开动画完成后设置 max-height 为 "none"
    - 折叠动画触发前先将 max-height 从 "none" 设为当前 scrollHeight，再过渡到 collapsedHeight
    - 将 contentHeight 传入 resolveEffectStyles
    - _需求：11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 20.1, 20.2, 20.4_

  - [ ]* 6.2 为 React Motion 的 Collapse 行为编写单元测试
    - 验证初始渲染跳过动画、展开/折叠样式切换
    - _需求：23.4_

  - [ ]* 6.3 为 React Motion 的 Collapse 编写属性测试
    - **属性 4：初始渲染不触发动画** — 任意 CollapseEffect 参数，首次渲染时 transition 为 none 或 duration=0
    - **验证：需求 20.1, 20.2**

- [x] 7. Web 组件层：Vue Motion 扩展 Collapse 支持
  - [x] 7.1 在 `packages/vue/src/Motion.vue` 中扩展 Collapse 高度测量与初始渲染逻辑
    - 检测效果数组中是否包含 CollapseEffect
    - 使用 `onMounted` 标记首次渲染，跳过初始动画（需求 20.5）
    - 首次渲染逻辑同 React 端
    - 使用 `scrollHeight` 测量、`ResizeObserver` 监听
    - 展开完成后 max-height 设为 "none"，折叠前先锁定当前高度
    - 将 contentHeight 传入 resolveEffectStyles
    - _需求：11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 20.1, 20.2, 20.5_

  - [ ]* 7.2 为 Vue Motion 的 Collapse 行为编写单元测试
    - 验证初始渲染跳过动画、展开/折叠样式切换
    - _需求：23.4_

- [x] 8. 检查点 — Web 层验证
  - 确保所有 Web 层测试通过，如有问题请向用户确认。

- [x] 9. Android 层：MotionEffect 与 MotionAnimator 扩展
  - [x] 9.1 在 `packages/android/src/main/kotlin/com/fadeanimation/MotionEffect.kt` 中新增 Flip 和 Collapse 密封子类
    - `Flip` 子类：axis（`FlipAxis` 枚举 X/Y）、from、to、perspective、backfaceVisibility
    - `Collapse` 子类：collapsedHeight（`CollapseHeight` 密封类，支持 `Fixed(value)` 和 `Auto`）
    - 新增 `FlipAxis` 枚举和 `CollapseHeight` 密封类
    - _需求：1.6, 2.4_

  - [x] 9.2 在 `packages/android/src/main/kotlin/com/fadeanimation/MotionAnimator.kt` 中实现 Flip 动画
    - 使用 `Camera` + `Matrix` 实现 3D 翻转，通过 `ObjectAnimator` 或 `ValueAnimator` 驱动
    - 根据 axis 调用 camera.rotateX/rotateY
    - 将 perspective 应用为 Camera 的 z 轴距离
    - 处理 backfaceVisibility
    - 处理 Flip+Rotate 冲突检测（console.warn → Log.w）
    - _需求：7.1, 7.2, 7.3, 7.4, 7.5, 12.3, 17.3_

  - [x] 9.3 在 `packages/android/src/main/kotlin/com/fadeanimation/MotionAnimator.kt` 中实现 Collapse 动画
    - 使用 `ValueAnimator` 驱动 `ViewGroup.LayoutParams.height`
    - 动画前记录原始 LayoutParams，测量子内容实际高度
    - entering=true：从 collapsedHeight 过渡到 contentHeight，完成后恢复 WRAP_CONTENT
    - entering=false：从 contentHeight 过渡到 collapsedHeight，完成后设为固定值
    - 动画中设置 clipChildren/clipToPadding 为 true
    - 处理 collapsedHeight 为 Auto 的情况
    - _需求：9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

  - [x] 9.4 在 `packages/android/src/main/kotlin/com/fadeanimation/EffectPresets.kt` 中新增 Flip 和 Collapse 预设
    - FLIP_X_IN、FLIP_X_OUT、FLIP_Y_IN、FLIP_Y_OUT
    - COLLAPSE_IN、COLLAPSE_OUT
    - _需求：5.5, 6.3_

  - [ ]* 9.5 为 Android Flip/Collapse 实现编写 JUnit 单元测试
    - 验证 MotionEffect 子类构造、默认值、冲突检测逻辑
    - _需求：23.1, 23.5_

- [x] 10. iOS 层：MotionEffect 与 MotionAnimator 扩展
  - [x] 10.1 在 `packages/ios/Sources/FadeAnimation/MotionEffect.swift` 中新增 flip 和 collapse case
    - `flip` case：axis（`FlipAxis` 枚举 .x/.y）、from、to、perspective、backfaceVisibility
    - `collapse` case：collapsedHeight（`CollapseHeight` 枚举，支持 `.fixed(CGFloat)` 和 `.auto`）
    - 新增 `FlipAxis` 枚举和 `CollapseHeight` 枚举
    - 在 EffectPresets 中新增 flipXIn、flipXOut、flipYIn、flipYOut、collapseIn、collapseOut
    - _需求：1.7, 2.5, 5.6, 6.4_

  - [x] 10.2 在 `packages/ios/Sources/FadeAnimation/MotionAnimator.swift` 中实现 flip 动画
    - 使用 `CATransform3D` 实现 3D 翻转
    - 将 perspective 应用到 m34 属性（值为 -1/perspective）
    - 根据 axis 调用 `CATransform3DRotate` 绕 X/Y 轴旋转
    - 将 from/to 转换为弧度
    - 通过 `CALayer.isDoubleSided` 控制背面可见性
    - 处理 Flip+Rotate 冲突检测
    - _需求：8.1, 8.2, 8.3, 8.4, 8.5, 12.3, 17.4_

  - [x] 10.3 在 `packages/ios/Sources/FadeAnimation/MotionAnimator.swift` 中实现 collapse 动画
    - 使用 `UIView.animate` 驱动高度约束动画
    - 若无现成高度约束则动态创建 `NSLayoutConstraint`，优先级设为 999
    - entering=true：从 collapsedHeight 过渡到 contentHeight，完成后移除动态约束
    - entering=false：从 contentHeight 过渡到 collapsedHeight，完成后保留约束
    - 动画中设置 clipsToBounds 为 true
    - 通过 `systemLayoutSizeFitting` 或 `sizeToFit` 测量子内容高度
    - 处理 collapsedHeight 为 .auto 的情况
    - _需求：10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9_

  - [ ]* 10.4 为 iOS Flip/Collapse 实现编写 XCTest 单元测试
    - 验证 MotionEffect case 构造、默认值、冲突检测逻辑
    - _需求：23.1, 23.5_

- [x] 11. 检查点 — 原生层验证
  - 确保所有原生层测试通过，如有问题请向用户确认。

- [x] 12. 集成与端到端验证
  - [x] 12.1 在 `packages/core/src/index.ts` 中导出新增的 FlipEffect、CollapseEffect 类型和新预设名称
    - 确保 EffectPresetName 类型自动包含新预设
    - _需求：1.1, 2.1_

  - [x] 12.2 验证 Flip/Collapse 与 Fade 的组合效果在 resolveEffectStyles 中正确工作
    - 确保 Flip+Fade 同时生成 transform 和 opacity 过渡
    - 确保 Collapse+Fade 同时生成 max-height 和 opacity 过渡
    - _需求：13.1, 13.2_

  - [ ]* 12.3 为效果组合编写属性测试
    - **属性 5：Transform 合并顺序一致性** — 任意 transform 类效果数组，解析结果中 transform 函数顺序与数组顺序一致
    - **验证：需求 3.6**

  - [ ]* 12.4 为效果组合编写属性测试
    - **属性 6：Collapse overflow 始终为 hidden** — 任意 CollapseEffect 参数和 entering 值，from 和 to 的 overflow 均为 "hidden"
    - **验证：需求 4.5**

  - [ ]* 12.5 为效果组合编写属性测试
    - **属性 7：Flip 角度方向与 entering 一致** — entering=true 时 from 包含 from 角度、to 包含 to 角度；entering=false 时反转
    - **验证：需求 3.3, 24.1**

- [x] 13. 最终检查点 — 全量测试通过
  - 确保所有平台的测试通过，如有问题请向用户确认。

## 备注

- 标记 `*` 的任务为可选，可跳过以加速 MVP 交付
- 每个任务均引用了具体的需求编号，确保可追溯性
- 属性测试使用 Vitest + fast-check（Web 端）、JUnit 5 + jqwik（Android）、XCTest + SwiftCheck（iOS）
- 检查点任务用于阶段性验证，确保增量正确性
- Duration/Delay/Easing 自定义（需求 14）和 Reduced Motion（需求 15）复用现有基础设施，无需额外任务
- Easing 跨平台映射（需求 21）中 spring easing 为可选近似实现，复用现有 easing 映射逻辑
- 性能约束（需求 22）通过实现方式保证（CSS transition、ValueAnimator、UIView.animate），无需独立任务
- 嵌套 Collapse（需求 18）由各平台的高度测量机制自然支持，外层折叠时内层随之折叠
