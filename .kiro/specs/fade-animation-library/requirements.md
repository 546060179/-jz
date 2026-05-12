# 需求文档

## 简介

Fade Animation Library 是一个跨框架、跨平台的动效设计系统。提供系统化的 Motion Design Tokens（时间刻度、距离刻度、缓动曲线、动效意图）、7 种动效效果（fade、scale、slide、rotate、blur、flip、collapse）、编排工具（stagger、sequence）、弹簧物理动画，以及无障碍支持。覆盖 React、Vue、Android (Kotlin)、iOS (Swift) 四个平台，并提供 Figma 插件和 CSS Token 输出能力。

## 术语表

- **Animation_Library**: 动效组件库的整体系统
- **Core_Engine**: 框架无关的核心逻辑模块（`@fade-animation/core`），包含配置解析、效果样式计算、设计令牌、编排工具等
- **Fade_Component**: 统一的淡入淡出组件，通过 `in` 属性控制动画方向
- **FadeIn_Component**: 淡入动画组件，等价于 `<Fade in={true}>`
- **FadeOut_Component**: 淡出动画组件，等价于 `<Fade in={false}>`
- **Motion_Component**: 通用动效组件，支持 7 种效果及其组合
- **FadeGroup_Component**: 编排组件，支持多子元素交错动画
- **Config_Resolver**: 配置解析器，将用户传入的 props 解析为最终动画参数
- **Effect_Resolver**: 效果样式解析器，将 MotionEffect 数组转换为 CSS 起始/目标样式
- **Duration**: 动画持续时长，单位为毫秒（ms）
- **Delay**: 动画开始前的延迟时间，单位为毫秒（ms）
- **Easing**: 缓动函数，控制动画的速度曲线
- **Preset_Speed**: 向后兼容的预设速度方案，包含 fast（150ms）、normal（300ms）、slow（600ms）
- **Timing_Scale**: 时间刻度令牌（t1-t5），对应 100ms 到 700ms
- **Timing_Alias**: 时间刻度的语义别名（extra-fast、fast、normal、slow、extra-slow）
- **Distance_Scale**: 距离刻度令牌（d1-d5），对应 4px 到 64px
- **Easing_Curve**: 命名缓动曲线（productive、expressive、enter、exit、linear）
- **Motion_Intent**: 动效意图（enter、exit、focus、feedback、delight），自动推导 timing 和 easing
- **Motion_Level**: 动效级别（full、reduced、none），控制全局动画行为
- **Reduced_Motion**: 用户在操作系统中设置的"减少动态效果"偏好
- **MotionEffect**: 单一效果描述对象，包含 type 和效果参数
- **Effect_Preset**: 预定义的效果组合（如 scale-fade-in、flip-y-out 等）
- **Spring_Engine**: 弹簧物理动画引擎，基于阻尼弹簧模型
- **Sequence_Planner**: 序列动画规划器，计算多步骤动画的累计延迟和总时长
- **Stagger_Calculator**: 交错延迟计算器，支持 forward、reverse、center 三种方向
- **Dynamic_Duration_Calculator**: 动态时长计算器，根据元素尺寸和移动距离推算合理时长
- **CSS_Token_Generator**: CSS Custom Properties 生成器，输出设计令牌为 CSS 变量
- **onAnimationEnd_Callback**: 动画结束时触发的回调函数
- **className**: 可选的 CSS 类名字符串，透传到组件根 DOM 元素上
- **FadeAnimator_Native**: 原生平台（Android/iOS）的淡入淡出动画控制器
- **MotionAnimator_Native**: 原生平台的通用动效控制器，支持多种效果组合

## 需求
