# 需求文档

## 简介

Fade Animation Library 是一个轻量级的淡入淡出动效组件库，同时支持 React 和 Vue 框架。该库提供 FadeIn（淡入）和 FadeOut（淡出）两个核心组件，支持自定义动画属性（时长、延迟、缓动函数）、预设速度方案，以及无障碍访问（prefers-reduced-motion）。所有组件均使用 TypeScript 编写，提供完整的类型定义。

## 术语表

- **Animation_Library**: 淡入淡出动效组件库的整体系统
- **FadeIn_Component**: 淡入动画组件，将子元素从透明渐变为可见
- **FadeOut_Component**: 淡出动画组件，将子元素从可见渐变为透明
- **Duration**: 动画持续时长，单位为毫秒（ms）
- **Delay**: 动画开始前的延迟时间，单位为毫秒（ms）
- **Easing**: 缓动函数，控制动画的速度曲线（如 ease、linear、ease-in-out 等 CSS 缓动值）
- **Preset_Speed**: 预设速度方案，包含 fast（150ms）、normal（300ms）、slow（600ms）三种
- **onAnimationEnd_Callback**: 动画结束时触发的回调函数
- **Reduced_Motion**: 用户在操作系统中设置的"减少动态效果"偏好（prefers-reduced-motion）

## 需求

### 需求 1：FadeIn 淡入动画组件

**用户故事：** 作为前端开发者，我希望使用 FadeIn 组件包裹子元素，使其以淡入效果出现在页面上。

#### 验收标准

1. WHEN FadeIn_Component 挂载到 DOM 时，THE FadeIn_Component SHALL 将子元素的不透明度从 0 过渡到 1
2. THE FadeIn_Component SHALL 默认使用 normal Preset_Speed（300ms）作为 Duration
3. THE FadeIn_Component SHALL 默认使用 0ms 作为 Delay
4. THE FadeIn_Component SHALL 默认使用 "ease" 作为 Easing
5. WHEN Duration 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Duration 值覆盖默认值
6. WHEN Delay 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Delay 值覆盖默认值
7. WHEN Easing 属性被传入时，THE FadeIn_Component SHALL 使用传入的 Easing 值覆盖默认值

### 需求 2：FadeOut 淡出动画组件

**用户故事：** 作为前端开发者，我希望使用 FadeOut 组件包裹子元素，使其以淡出效果从页面上消失。

#### 验收标准

1. WHEN FadeOut_Component 挂载到 DOM 时，THE FadeOut_Component SHALL 将子元素的不透明度从 1 过渡到 0
2. THE FadeOut_Component SHALL 默认使用 normal Preset_Speed（300ms）作为 Duration
3. THE FadeOut_Component SHALL 默认使用 0ms 作为 Delay
4. THE FadeOut_Component SHALL 默认使用 "ease" 作为 Easing
5. WHEN Duration 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Duration 值覆盖默认值
6. WHEN Delay 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Delay 值覆盖默认值
7. WHEN Easing 属性被传入时，THE FadeOut_Component SHALL 使用传入的 Easing 值覆盖默认值

### 需求 3：预设速度方案

**用户故事：** 作为前端开发者，我希望通过预设速度名称快速设置动画时长，而不必每次手动指定毫秒值。

#### 验收标准

1. WHEN "fast" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 150ms
2. WHEN "normal" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 300ms
3. WHEN "slow" Preset_Speed 被传入时，THE Animation_Library SHALL 将 Duration 设置为 600ms
4. WHEN Preset_Speed 和自定义 Duration 同时被传入时，THE Animation_Library SHALL 优先使用自定义 Duration 值

### 需求 4：React 框架支持

**用户故事：** 作为 React 开发者，我希望在 React 项目中直接导入并使用 FadeIn 和 FadeOut 组件。

#### 验收标准

1. THE Animation_Library SHALL 提供 React 版本的 FadeIn_Component 和 FadeOut_Component
2. THE Animation_Library SHALL 将 React 组件以命名导出的方式从 React 包入口导出
3. THE Animation_Library SHALL 为 React 组件提供完整的 TypeScript 类型定义（Props 接口）
4. THE Animation_Library SHALL 支持 React 组件接收并透传子元素（children）

### 需求 5：Vue 框架支持

**用户故事：** 作为 Vue 开发者，我希望在 Vue 项目中直接导入并使用 FadeIn 和 FadeOut 组件。

#### 验收标准

1. THE Animation_Library SHALL 提供 Vue 版本的 FadeIn_Component 和 FadeOut_Component
2. THE Animation_Library SHALL 将 Vue 组件以命名导出的方式从 Vue 包入口导出
3. THE Animation_Library SHALL 为 Vue 组件提供完整的 TypeScript 类型定义（Props 接口）
4. THE Animation_Library SHALL 支持 Vue 组件接收并渲染默认插槽（slot）内容

### 需求 6：动画结束回调

**用户故事：** 作为前端开发者，我希望在动画播放结束后执行自定义逻辑（如移除元素、触发下一步操作）。

#### 验收标准

1. WHEN 动画过渡完成时，THE FadeIn_Component SHALL 调用 onAnimationEnd_Callback（如果已传入）
2. WHEN 动画过渡完成时，THE FadeOut_Component SHALL 调用 onAnimationEnd_Callback（如果已传入）
3. WHEN onAnimationEnd_Callback 未被传入时，THE Animation_Library SHALL 正常完成动画而不触发任何回调
4. THE Animation_Library SHALL 确保 onAnimationEnd_Callback 在每次动画完成时仅被调用一次

### 需求 7：无障碍访问 - 减少动态效果

**用户故事：** 作为对动画敏感的用户，我希望当操作系统开启"减少动态效果"时，动画被自动跳过或大幅缩短，以避免不适。

#### 验收标准

1. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 将 Duration 设置为 0ms 以跳过动画
2. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 将 Delay 设置为 0ms
3. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 仍然调用 onAnimationEnd_Callback（如果已传入）
4. WHEN Reduced_Motion 偏好在运行时发生变化时，THE Animation_Library SHALL 在下一次动画触发时应用新的偏好设置

### 需求 8：TypeScript 类型定义

**用户故事：** 作为 TypeScript 开发者，我希望获得完整的类型提示和编译时类型检查，以减少运行时错误。

#### 验收标准

1. THE Animation_Library SHALL 为 Duration 属性定义 number 类型（单位：毫秒）
2. THE Animation_Library SHALL 为 Delay 属性定义 number 类型（单位：毫秒）
3. THE Animation_Library SHALL 为 Easing 属性定义 string 类型（接受有效的 CSS 缓动值）
4. THE Animation_Library SHALL 为 Preset_Speed 属性定义联合类型 "fast" | "normal" | "slow"
5. THE Animation_Library SHALL 为 onAnimationEnd_Callback 属性定义 () => void 类型
6. THE Animation_Library SHALL 将所有动画属性（Duration、Delay、Easing、Preset_Speed、onAnimationEnd_Callback）定义为可选属性

### 需求 9：输入校验

**用户故事：** 作为前端开发者，我希望在传入无效属性值时获得合理的降级行为，而不是组件崩溃。

#### 验收标准

1. IF Duration 传入负数值，THEN THE Animation_Library SHALL 使用默认 Duration（300ms）
2. IF Delay 传入负数值，THEN THE Animation_Library SHALL 使用默认 Delay（0ms）
3. IF Preset_Speed 传入不在 "fast" | "normal" | "slow" 范围内的值，THEN THE Animation_Library SHALL 使用 normal Preset_Speed（300ms）
