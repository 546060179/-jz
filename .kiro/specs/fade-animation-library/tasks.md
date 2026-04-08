# 实现计划：Fade Animation Library

## 概述

基于 monorepo 结构，按 core → react → vue 的顺序逐层实现。先搭建项目结构和核心类型定义，再实现 `@fade-animation/core` 的配置解析逻辑，然后分别实现 React 和 Vue 的组件封装，最后完成集成联调。使用 TypeScript 编写，Vitest + fast-check 进行属性测试，@testing-library/react 和 @vue/test-utils 进行组件测试。

## Tasks

- [x] 1. 搭建 monorepo 项目结构和核心类型定义
  - [x] 1.1 初始化 pnpm workspace 和三个包目录（packages/core、packages/react、packages/vue）
    - 创建根目录 `pnpm-workspace.yaml`、根 `package.json`、根 `tsconfig.json`
    - 创建 `packages/core/package.json`（name: @fade-animation/core）和 `packages/core/tsconfig.json`
    - 创建 `packages/react/package.json`（name: @fade-animation/react，依赖 @fade-animation/core）和 `packages/react/tsconfig.json`
    - 创建 `packages/vue/package.json`（name: @fade-animation/vue，依赖 @fade-animation/core）和 `packages/vue/tsconfig.json`
    - 配置 Vitest 作为测试框架（根 vitest.config.ts 或各包独立配置）
    - _Requirements: 4.1, 4.2, 5.1, 5.2_

  - [x] 1.2 定义核心 TypeScript 类型和常量
    - 在 `packages/core/src/types.ts` 中定义 `PresetSpeed`、`FadeProps`、`ResolvedFadeConfig` 类型
    - 在 `packages/core/src/constants.ts` 中定义 `PRESET_SPEEDS` 映射和 `DEFAULTS` 常量
    - 创建 `packages/core/src/index.ts` 入口文件导出所有公共 API
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 3.1, 3.2, 3.3_

- [ ] 2. 实现 @fade-animation/core 配置解析逻辑
  - [x] 2.1 实现 `resolveConfig` 函数
    - 在 `packages/core/src/resolveConfig.ts` 中实现配置解析
    - 处理输入校验：负数 duration 回退 300ms，负数 delay 回退 0ms
    - 处理预设速度解析：将 preset 映射为对应毫秒值
    - 处理优先级：自定义 duration 优先于 preset
    - 处理无效 preset 回退 normal（300ms）
    - _Requirements: 1.2-1.7, 2.2-2.7, 3.1-3.4, 9.1, 9.2, 9.3_

  - [x] 2.2 实现 `getReducedMotionPreference` 函数
    - 在 `packages/core/src/reducedMotion.ts` 中实现 reduced-motion 检测
    - 使用 `window.matchMedia('(prefers-reduced-motion: reduce)')` 检测用户偏好
    - SSR 环境下（无 window 对象）返回 false
    - 在 `resolveConfig` 中集成：reduced-motion 启用时将 duration 和 delay 置为 0
    - _Requirements: 7.1, 7.2, 7.4_

  - [ ]* 2.3 编写 resolveConfig 属性测试 — Property 1: 自定义值覆盖默认值
    - **Property 1: 自定义值覆盖默认值**
    - 生成随机非负 duration/delay 和随机 easing 字符串，验证 resolveConfig 输出与输入一致
    - **Validates: Requirements 1.5, 1.6, 1.7, 2.5, 2.6, 2.7**

  - [ ]* 2.4 编写 resolveConfig 属性测试 — Property 2: 自定义 Duration 优先于预设速度
    - **Property 2: 自定义 Duration 优先于预设速度**
    - 生成随机 preset 和随机非负 duration，验证自定义 duration 优先
    - **Validates: Requirements 3.4**

  - [ ]* 2.5 编写 resolveConfig 属性测试 — Property 3: 负数 Duration/Delay 回退默认值
    - **Property 3: 负数 Duration/Delay 回退默认值**
    - 生成随机负数 duration/delay，验证回退到默认值
    - **Validates: Requirements 9.1, 9.2**

  - [ ]* 2.6 编写 resolveConfig 属性测试 — Property 4: 无效预设速度回退默认值
    - **Property 4: 无效预设速度回退默认值**
    - 生成不属于 fast/normal/slow 的随机字符串，验证回退到 300ms
    - **Validates: Requirements 9.3**

  - [ ]* 2.7 编写 resolveConfig 属性测试 — Property 5: Reduced-motion 下 Duration 和 Delay 归零
    - **Property 5: Reduced-motion 下 Duration 和 Delay 归零**
    - 生成任意配置组合，mock reduced-motion 为 true，验证 duration 和 delay 为 0
    - **Validates: Requirements 7.1, 7.2**

- [x] 3. 检查点 - 确保 core 包测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [ ] 4. 实现 @fade-animation/react 组件
  - [x] 4.1 实现 React Fade 组件
    - 在 `packages/react/src/Fade.tsx` 中实现统一 Fade 组件
    - 使用 `useEffect` 监听 `in` 属性变化触发 opacity 过渡
    - 通过 inline style 设置 CSS transition 属性（opacity）
    - 监听 `transitionend` 事件触发 `onAnimationEnd` 回调
    - 使用 `useRef` 确保回调仅触发一次
    - 设置安全网 setTimeout（duration + delay + 50ms）防止 transitionend 未触发
    - 组件卸载时清理事件监听器和定时器
    - 支持 `className` 透传到根 `<div>` 元素
    - 调用 `@fade-animation/core` 的 `resolveConfig` 解析配置
    - _Requirements: 1.1, 2.1, 4.4, 6.1, 6.2, 6.3, 6.4, 7.3_

  - [x] 4.2 实现 React FadeIn/FadeOut 便捷别名并导出
    - 在 `packages/react/src/FadeIn.tsx` 中实现 FadeIn（等价于 `<Fade in={true}>`）
    - 在 `packages/react/src/FadeOut.tsx` 中实现 FadeOut（等价于 `<Fade in={false}>`）
    - 在 `packages/react/src/index.ts` 中以命名导出方式导出 Fade、FadeIn、FadeOut 及类型定义
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ]* 4.3 编写 React 组件属性测试 — Property 8: `in` 属性决定不透明度方向
    - **Property 8: `in` 属性决定不透明度方向**
    - 生成随机 boolean 值作为 `in` 属性，渲染 Fade 组件，验证 opacity 方向正确
    - **Validates: Requirements 1.1, 2.1**

  - [ ]* 4.4 编写 React 组件属性测试 — Property 10: 子元素内容透传
    - **Property 10: 子元素内容透传**
    - 生成随机子元素文本，渲染组件后验证文本出现在 DOM 中
    - **Validates: Requirements 4.4**

  - [ ]* 4.5 编写 React 组件属性测试 — Property 11: className 透传到根元素
    - **Property 11: className 透传到根元素**
    - 生成随机 className 字符串，渲染 Fade 组件后验证根元素的 class 包含该字符串
    - **Validates: Requirements 10.1**

  - [ ]* 4.6 编写 React 组件属性测试 — Property 12: FadeIn/FadeOut 与 Fade 的等价性
    - **Property 12: FadeIn/FadeOut 与 Fade 的等价性**
    - 生成随机 props 组合，分别渲染 FadeIn 和 `<Fade in={true}>`，验证 DOM 输出等价；FadeOut 同理
    - **Validates: Requirements 4.1**

  - [ ]* 4.7 编写 React 组件单元测试
    - 测试回调仅触发一次（Property 7，Requirements 6.4）
    - 测试 reduced-motion 下回调仍被调用（Property 6，Requirements 7.3）
    - 测试运行时切换 `in` 属性触发新动画（Property 9）
    - 测试无回调时组件正常运行（Requirements 6.3）
    - 测试 Fade 默认 in=true（淡入行为）
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 7.3, 7.4_

- [x] 5. 检查点 - 确保 React 包测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [ ] 6. 实现 @fade-animation/vue 组件
  - [x] 6.1 实现 Vue Fade 组件
    - 在 `packages/vue/src/Fade.vue` 中实现统一 Fade 组件（使用 `<script setup lang="ts">`）
    - 使用 `watch` 监听 `in` 属性变化触发 opacity 过渡
    - 通过 inline style 设置 CSS transition 属性
    - 监听 `transitionend` 事件触发 `onAnimationEnd` 回调
    - 设置安全网 setTimeout 防止 transitionend 未触发
    - 组件卸载时（`onUnmounted`）清理事件监听器和定时器
    - 支持 `className` 绑定到根元素的 `class` 属性
    - 使用默认插槽渲染子内容
    - 调用 `@fade-animation/core` 的 `resolveConfig` 解析配置
    - _Requirements: 2.1, 1.1, 5.4, 6.1, 6.2, 6.3, 6.4, 7.3_

  - [x] 6.2 实现 Vue FadeIn/FadeOut 便捷别名并导出
    - 在 `packages/vue/src/FadeIn.vue` 中实现 FadeIn（等价于 `<Fade :in="true">`）
    - 在 `packages/vue/src/FadeOut.vue` 中实现 FadeOut（等价于 `<Fade :in="false">`）
    - 在 `packages/vue/src/index.ts` 中以命名导出方式导出 Fade、FadeIn、FadeOut 及类型定义
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ]* 6.3 编写 Vue 组件属性测试 — Property 8: `in` 属性决定不透明度方向
    - **Property 8: `in` 属性决定不透明度方向（Vue）**
    - 生成随机 boolean 值作为 `in` 属性，渲染 Vue Fade 组件，验证 opacity 方向正确
    - **Validates: Requirements 1.1, 2.1**

  - [ ]* 6.4 编写 Vue 组件属性测试 — Property 10: 插槽内容透传
    - **Property 10: 插槽内容透传（Vue）**
    - 生成随机子元素文本，渲染组件后验证文本出现在 DOM 中
    - **Validates: Requirements 5.4**

  - [ ]* 6.5 编写 Vue 组件属性测试 — Property 11: className 透传到根元素
    - **Property 11: className 透传到根元素（Vue）**
    - 生成随机 className 字符串，渲染 Vue Fade 组件后验证根元素的 class 包含该字符串
    - **Validates: Requirements 10.1**

  - [ ]* 6.6 编写 Vue 组件属性测试 — Property 12: FadeIn/FadeOut 与 Fade 的等价性
    - **Property 12: FadeIn/FadeOut 与 Fade 的等价性（Vue）**
    - 生成随机 props 组合，分别渲染 FadeIn 和 `<Fade :in="true">`，验证 DOM 输出等价；FadeOut 同理
    - **Validates: Requirements 5.1**

  - [ ]* 6.7 编写 Vue 组件单元测试
    - 测试回调仅触发一次（Property 7，Requirements 6.4）
    - 测试 reduced-motion 下回调仍被调用（Property 6，Requirements 7.3）
    - 测试运行时切换 `in` 属性触发新动画（Property 9）
    - 测试无回调时组件正常运行（Requirements 6.3）
    - 测试 Fade 默认 in=true（淡入行为）
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 7.3, 7.4_

- [x] 7. 最终检查点 - 确保所有包测试通过
  - 确保所有测试通过，如有问题请询问用户。

## Notes

- 标记 `*` 的任务为可选任务，可跳过以加速 MVP 交付
- 每个任务均引用了对应的需求编号，确保可追溯性
- 检查点任务确保增量验证
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
