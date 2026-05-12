# 需求文档

## 简介

Jiuzhou（九州）动效组件库是一个跨框架、跨平台的动效设计系统。基于现有 Fade Animation Library 的架构经验，Jiuzhou 将其升级为一个完整的、品牌化的动效组件库，提供系统化的 Motion Design Tokens、多种动效效果（fade、scale、slide、rotate、blur、flip、collapse）、编排工具（stagger、sequence）、弹簧物理动画，以及统一的 Motion 组件。支持 React、Vue、Android（Kotlin）、iOS（Swift）四个平台，所有组件使用 TypeScript / 原生语言编写，提供完整的类型定义。

## 术语表

- **Jiuzhou_Library**: 九州动效组件库的整体系统
- **Motion_Component**: 通用动效组件，通过 `effect` 属性指定效果类型，通过 `in` 属性控制进入/退出方向
- **Fade_Component**: 淡入淡出专用组件，等价于 Motion_Component 使用 fade 效果
- **FadeGroup_Component**: 多元素编排组件，支持 stagger 交错动画
- **Effect**: 单一动效类型，包括 fade、scale、slide、rotate、blur、flip、collapse
- **Effect_Preset**: 效果预设，预定义的效果组合（如 scale-fade-in、flip-y-in 等）
- **Motion_Token**: 动效设计令牌，包括 Timing_Scale、Distance_Scale、Easing_Curve
- **Timing_Scale**: 时间刻度体系（t1=100ms 至 t5=700ms），类似排版 h1-h5 的时间层级
- **Distance_Scale**: 距离刻度体系（d1=4px 至 d5=64px），定义位移距离
- **Easing_Curve**: 缓动曲线，包括 productive、expressive、enter、exit、linear
- **Motion_Intent**: 动效意图，包括 enter、exit、focus、feedback、delight，自动推导 timing 和 easing
- **Spring_Animation**: 基于阻尼谐振子模型的弹簧物理动画
- **Spring_Preset**: 弹簧预设配置，包括 gentle、snappy、bouncy、slow、noWobble
- **Stagger**: 多元素交错延迟编排
- **Sequence**: 序列动画，按顺序执行多个动画步骤
- **Duration**: 动画持续时长，单位为毫秒（ms）
- **Delay**: 动画开始前的延迟时间，单位为毫秒（ms）
- **Reduced_Motion**: 用户在操作系统中设置的"减少动态效果"偏好
- **Motion_Level**: 动效级别控制，包括 full（完整）、reduced（减弱，clamp 到 100ms）、none（跳过）
- **Dynamic_Duration**: 根据元素尺寸和移动距离自动推算的合理时长
- **CSS_Token**: 以 CSS Custom Properties 形式输出的动效令牌

## 需求

### 需求 1：核心效果系统

**用户故事：** 作为前端开发者，我希望使用一套统一的效果类型系统来描述各种动效，以便灵活组合和复用。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 7 种 Effect 类型：fade、scale、slide、rotate、blur、flip、collapse
2. THE Jiuzhou_Library SHALL 为每种 Effect 类型定义独立的参数接口（包含 from、to 等属性）
3. THE Jiuzhou_Library SHALL 支持将多个 Effect 组合为数组，同时应用到同一元素上
4. WHEN flip 和 rotate Effect 同时存在于同一组合中时，THE Jiuzhou_Library SHALL 忽略 rotate 并输出控制台警告
5. THE Jiuzhou_Library SHALL 提供至少 18 种 Effect_Preset（包括 fade-in、fade-out、scale-fade-in、scale-fade-out、slide-up-in、slide-down-out、slide-left-in、slide-right-in、rotate-fade-in、rotate-fade-out、blur-fade-in、blur-fade-out、flip-x-in、flip-x-out、flip-y-in、flip-y-out、collapse-in、collapse-out）
6. WHEN Effect_Preset 名称被传入时，THE Jiuzhou_Library SHALL 将其解析为对应的 Effect 数组

### 需求 2：Motion Design Tokens

**用户故事：** 作为设计系统维护者，我希望通过系统化的设计令牌来统一管理动效参数，确保产品动效的一致性。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 5 级 Timing_Scale（t1=100ms、t2=150ms、t3=300ms、t4=500ms、t5=700ms）
2. THE Jiuzhou_Library SHALL 为 Timing_Scale 提供语义别名（extra-fast、fast、normal、slow、extra-slow）
3. THE Jiuzhou_Library SHALL 提供 5 级 Distance_Scale（d1=4px、d2=8px、d3=16px、d4=32px、d5=64px）
4. THE Jiuzhou_Library SHALL 为 Distance_Scale 提供语义别名（micro、small、medium、large、full）
5. THE Jiuzhou_Library SHALL 提供 5 种 Easing_Curve（productive、expressive、enter、exit、linear），每种使用 CSS cubic-bezier 值定义
6. THE Jiuzhou_Library SHALL 提供 5 种 Motion_Intent（enter、exit、focus、feedback、delight），每种包含推荐的 Timing_Scale 和 Easing_Curve 默认值

### 需求 3：Motion 通用动效组件

**用户故事：** 作为前端开发者，我希望使用一个通用的 Motion 组件来应用任意效果组合，而不必为每种效果创建单独的组件。

#### 验收标准

1. THE Motion_Component SHALL 接受 `effect` 属性，支持传入 Effect_Preset 名称（字符串）或 Effect 数组
2. THE Motion_Component SHALL 接受 `in` 布尔属性来控制进入/退出方向，默认为 true
3. WHEN `in` 属性从 false 变为 true 时，THE Motion_Component SHALL 播放进入动画
4. WHEN `in` 属性从 true 变为 false 时，THE Motion_Component SHALL 播放退出动画
5. THE Motion_Component SHALL 接受 `intent` 属性（Motion_Intent 类型），自动推导 Duration 和 Easing_Curve
6. THE Motion_Component SHALL 接受 `duration`、`delay`、`easing` 属性进行手动覆盖
7. THE Motion_Component SHALL 接受 `onAnimationEnd` 回调，在动画完成时调用一次
8. THE Motion_Component SHALL 接受 `className` 属性，透传到根 DOM 元素上

### 需求 4：Fade 专用组件

**用户故事：** 作为前端开发者，我希望使用简洁的 Fade 组件来实现淡入淡出效果，无需手动配置 effect 参数。

#### 验收标准

1. THE Fade_Component SHALL 通过 `in` 布尔属性控制淡入（true）和淡出（false），默认为 true
2. THE Fade_Component SHALL 默认使用 normal Timing_Scale（300ms）作为 Duration
3. THE Fade_Component SHALL 默认使用 "ease" 作为 Easing
4. WHEN Duration、Delay、Easing 属性被传入时，THE Fade_Component SHALL 使用传入值覆盖默认值
5. THE Jiuzhou_Library SHALL 提供 FadeIn 和 FadeOut 便捷别名组件，分别等价于 `<Fade in={true}>` 和 `<Fade in={false}>`
6. WHEN 动画过渡完成时，THE Fade_Component SHALL 调用 onAnimationEnd 回调（如果已传入）

### 需求 5：FadeGroup 编排组件

**用户故事：** 作为前端开发者，我希望让多个子元素以交错延迟的方式依次播放动画，实现列表或网格的编排效果。

#### 验收标准

1. THE FadeGroup_Component SHALL 接受 `stagger` 属性（包含 interval 和 direction 参数）
2. THE FadeGroup_Component SHALL 根据 stagger interval 为每个子元素计算递增的延迟值
3. WHEN stagger direction 为 "reverse" 时，THE FadeGroup_Component SHALL 反转延迟顺序（最后一个子元素先播放）
4. WHEN stagger direction 为 "center" 时，THE FadeGroup_Component SHALL 从中间向两端递增延迟
5. THE FadeGroup_Component SHALL 支持 `in` 属性统一控制所有子元素的进入/退出方向
6. THE FadeGroup_Component SHALL 支持 `intent` 属性统一设置所有子元素的动效意图

### 需求 6：弹簧物理动画

**用户故事：** 作为前端开发者，我希望使用基于物理模型的弹簧动画来实现更自然的交互效果。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 Spring_Animation 引擎，基于阻尼谐振子模型（stiffness、damping、mass、velocity 参数）
2. THE Jiuzhou_Library SHALL 提供 5 种 Spring_Preset（gentle、snappy、bouncy、slow、noWobble）
3. THE Spring_Animation SHALL 提供 step 函数，接受时间步长（秒），返回当前位置、速度和是否静止
4. THE Spring_Animation SHALL 提供 reset 函数，将状态重置到初始值
5. THE Jiuzhou_Library SHALL 提供 estimateSpringDuration 函数，通过模拟求解器预计算弹簧动画总时长
6. THE Jiuzhou_Library SHALL 为 React 提供 useSpring hook，为 Vue 提供 useSpring composable

### 需求 7：序列动画

**用户故事：** 作为前端开发者，我希望按顺序执行多个动画步骤，实现复杂的多阶段动效编排。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 planSequence 函数，接受 SequenceStep 数组和默认时长
2. THE planSequence 函数 SHALL 为每个步骤计算累计延迟（stepDelays）和实际时长（stepDurations）
3. THE planSequence 函数 SHALL 返回整个序列的总时长（totalDuration）
4. WHEN 步骤未指定 duration 时，THE planSequence 函数 SHALL 使用默认时长（t3=300ms）
5. WHEN 步骤指定了 delay 时，THE planSequence 函数 SHALL 将该 delay 累加到后续步骤的起始时间

### 需求 8：Stagger 编排工具

**用户故事：** 作为前端开发者，我希望使用工具函数计算多元素的交错延迟数组，以便在自定义场景中灵活使用。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 stagger 函数，接受元素数量和配置参数（interval、direction）
2. WHEN direction 为 "forward"（默认）时，THE stagger 函数 SHALL 返回从 0 开始递增的延迟数组
3. WHEN direction 为 "reverse" 时，THE stagger 函数 SHALL 返回从最大值开始递减的延迟数组
4. WHEN direction 为 "center" 时，THE stagger 函数 SHALL 返回从中间为 0 向两端递增的延迟数组

### 需求 9：动态时长计算

**用户故事：** 作为前端开发者，我希望根据元素尺寸或移动距离自动推算合理的动画时长，避免手动调参。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 dynamicDuration 函数，接受 size 或 distance 参数
2. WHEN size 参数被传入时，THE dynamicDuration 函数 SHALL 根据元素尺寸推算合理时长
3. WHEN distance 参数被传入时，THE dynamicDuration 函数 SHALL 根据移动距离推算合理时长
4. THE dynamicDuration 函数 SHALL 返回一个以毫秒为单位的 number 值

### 需求 10：Duration 解析优先级

**用户故事：** 作为前端开发者，我希望 Duration 的解析遵循明确的优先级规则，避免多个参数冲突时产生歧义。

#### 验收标准

1. THE Jiuzhou_Library SHALL 按以下优先级解析 Duration：duration > timing > preset > intent > 默认值（300ms）
2. THE Jiuzhou_Library SHALL 按以下优先级解析 Easing：easing > intent > 默认值（"ease"）
3. IF Duration 传入负数值，THEN THE Jiuzhou_Library SHALL 使用默认 Duration（300ms）
4. IF Delay 传入负数值，THEN THE Jiuzhou_Library SHALL 使用默认 Delay（0ms）

### 需求 11：CSS Token 输出

**用户故事：** 作为前端开发者，我希望将动效令牌以 CSS Custom Properties 的形式注入页面，以便在 CSS 中直接引用。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 generateCSSTokens 函数，返回包含所有 Motion_Token 的 CSS Custom Properties 字符串
2. THE Jiuzhou_Library SHALL 提供 injectCSSTokens 函数，将 CSS Custom Properties 直接注入到页面 `<head>` 中
3. THE generateCSSTokens 函数 SHALL 包含 Timing_Scale、Distance_Scale、Easing_Curve 的 CSS 变量

### 需求 12：无障碍访问 — 减少动态效果

**用户故事：** 作为对动画敏感的用户，我希望当操作系统开启"减少动态效果"时，动画被自动跳过或大幅缩短。

#### 验收标准

1. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Jiuzhou_Library SHALL 自动检测该偏好（Web 通过 prefers-reduced-motion、Android 通过 Animator duration scale、iOS 通过 UIAccessibility.isReduceMotionEnabled）
2. THE Jiuzhou_Library SHALL 提供 setMotionLevel 函数，支持设置 Motion_Level 为 full、reduced 或 none
3. WHILE Motion_Level 为 "reduced" 时，THE Jiuzhou_Library SHALL 将动画时长 clamp 到 100ms
4. WHILE Motion_Level 为 "none" 时，THE Jiuzhou_Library SHALL 将动画时长设置为 0ms 以完全跳过动画
5. WHILE Motion_Level 为 undefined 时，THE Jiuzhou_Library SHALL 跟随系统 prefers-reduced-motion 偏好
6. WHILE Reduced_Motion 生效时，THE Jiuzhou_Library SHALL 仍然调用 onAnimationEnd 回调（如果已传入）

### 需求 13：React 框架支持

**用户故事：** 作为 React 开发者，我希望在 React 项目中直接导入并使用 Jiuzhou 的所有动效组件。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 React 版本的 Motion_Component、Fade_Component、FadeIn、FadeOut、FadeGroup_Component
2. THE Jiuzhou_Library SHALL 将所有 React 组件以命名导出的方式从 React 包入口导出
3. THE Jiuzhou_Library SHALL 为所有 React 组件提供完整的 TypeScript 类型定义（Props 接口）
4. THE Jiuzhou_Library SHALL 提供 React useSpring hook，返回弹簧动画的实时状态值
5. THE Jiuzhou_Library SHALL 支持 React 组件接收并透传子元素（children）

### 需求 14：Vue 框架支持

**用户故事：** 作为 Vue 开发者，我希望在 Vue 项目中直接导入并使用 Jiuzhou 的所有动效组件。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 Vue 版本的 Motion_Component、Fade_Component、FadeIn、FadeOut、FadeGroup_Component
2. THE Jiuzhou_Library SHALL 将所有 Vue 组件以命名导出的方式从 Vue 包入口导出
3. THE Jiuzhou_Library SHALL 为所有 Vue 组件提供完整的 TypeScript 类型定义（Props 接口）
4. THE Jiuzhou_Library SHALL 提供 Vue useSpring composable，返回响应式的弹簧动画状态
5. THE Jiuzhou_Library SHALL 支持 Vue 组件接收并渲染默认插槽（slot）内容

### 需求 15：Android 原生支持

**用户故事：** 作为 Android 开发者，我希望在 Kotlin 项目中使用 Jiuzhou 的动效能力，获得与 Web 端一致的动效体验。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 Android Kotlin 模块，包含 FadeAnimator 和 MotionAnimator
2. THE MotionAnimator SHALL 支持所有 7 种 Effect 类型（fade、scale、slide、rotate、blur、flip、collapse）
3. THE Jiuzhou_Library SHALL 提供 Android 扩展函数（如 view.fadeIn()、view.fadeOut()）
4. THE Jiuzhou_Library SHALL 在 Android 上支持 MotionIntent 自动推导 timing 和 easing
5. THE Jiuzhou_Library SHALL 在 Android 上支持 Effect_Preset 预设
6. THE MotionAnimator SHALL 接受 onEnd 回调，在动画完成时调用

### 需求 16：iOS 原生支持

**用户故事：** 作为 iOS 开发者，我希望在 Swift 项目中使用 Jiuzhou 的动效能力，获得与 Web 端一致的动效体验。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 iOS Swift Package，包含 FadeAnimator 和 MotionAnimator
2. THE MotionAnimator SHALL 支持所有 7 种 Effect 类型（fade、scale、slide、rotate、blur、flip、collapse）
3. THE Jiuzhou_Library SHALL 提供 iOS UIView 扩展方法（如 view.fadeIn()、view.fadeOut()）
4. THE Jiuzhou_Library SHALL 在 iOS 上支持 MotionIntent 自动推导 timing 和 easing
5. THE Jiuzhou_Library SHALL 在 iOS 上支持 EffectPresets 预设
6. THE MotionAnimator SHALL 接受 completion 闭包，在动画完成时调用

### 需求 17：TypeScript 类型定义

**用户故事：** 作为 TypeScript 开发者，我希望获得完整的类型提示和编译时类型检查，以减少运行时错误。

#### 验收标准

1. THE Jiuzhou_Library SHALL 为所有 Effect 类型定义独立的 TypeScript 接口（FadeEffect、ScaleEffect、SlideEffect、RotateEffect、BlurEffect、FlipEffect、CollapseEffect）
2. THE Jiuzhou_Library SHALL 定义 MotionEffect 联合类型，涵盖所有 Effect 接口
3. THE Jiuzhou_Library SHALL 为 Effect_Preset 名称定义字符串字面量联合类型（EffectPresetName）
4. THE Jiuzhou_Library SHALL 为 Motion_Intent 定义字符串字面量联合类型
5. THE Jiuzhou_Library SHALL 为 Timing_Scale、Distance_Scale、Easing_Curve 定义对应的类型
6. THE Jiuzhou_Library SHALL 为 Spring_Animation 配置定义 SpringConfig 接口
7. THE Jiuzhou_Library SHALL 将所有动画属性（duration、delay、easing、intent、effect、in、className、onAnimationEnd）定义为可选属性

### 需求 18：配置解析与输入校验

**用户故事：** 作为前端开发者，我希望在传入无效属性值时获得合理的降级行为，而不是组件崩溃。

#### 验收标准

1. THE Jiuzhou_Library SHALL 提供 resolveConfig 函数，将用户传入的 Props 解析为最终的动画配置（包含 duration、delay、easing）
2. IF Duration 传入负数值，THEN THE resolveConfig 函数 SHALL 使用默认 Duration（300ms）
3. IF Delay 传入负数值，THEN THE resolveConfig 函数 SHALL 使用默认 Delay（0ms）
4. THE resolveConfig 函数 SHALL 提供 resolveEffectStyles 功能，将 Effect 数组解析为 CSS 起始样式和目标样式
5. FOR ALL 有效的 Effect 数组，解析为 CSS 样式再还原为 Effect 参数 SHALL 产生等价的结果（round-trip 属性）
