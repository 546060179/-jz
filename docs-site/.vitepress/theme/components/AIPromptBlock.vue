<script setup lang="ts">
import { ref } from 'vue';
import type { ComponentCase } from '../../../data/types';

const props = defineProps<{
  case: ComponentCase;
  categoryLabel: string;
}>();

type Platform = 'react' | 'vue' | 'swift' | 'kotlin';

const AI_PLATFORM_META: Record<Platform, {
  label: string;
  pkg: string;
  codeFence: string;
  requirements: string[];
}> = {
  react: {
    label: 'React + TypeScript',
    pkg: '@fade-animation/react',
    codeFence: 'tsx',
    requirements: [
      '直接输出可运行的完整 React 组件代码',
      '使用 TypeScript + 函数组件 + hooks',
      '包含必要的 state 管理（useState 等）',
      '若涉及弹窗/退出动画，用 <Presence> 管理进入/退出生命周期',
      '保留上述推荐参数作为默认值，但允许通过 props 覆盖',
    ],
  },
  vue: {
    label: 'Vue 3 + TypeScript',
    pkg: '@fade-animation/vue',
    codeFence: 'vue',
    requirements: [
      '直接输出可运行的完整 Vue 3 单文件组件（.vue）',
      '使用 <script setup lang="ts"> 语法 + Composition API',
      '用 ref / computed 管理必要的响应式状态',
      '若涉及弹窗/退出动画，用 <Presence> 管理进入/退出生命周期',
      '保留上述推荐参数作为默认值，但允许通过 props 覆盖',
    ],
  },
  swift: {
    label: 'iOS Swift (UIKit)',
    pkg: 'FadeAnimation (Swift Package)',
    codeFence: 'swift',
    requirements: [
      '直接输出可运行的完整 Swift 代码',
      '使用 UIKit + UIView 或 UIViewController',
      '调用 MotionAnimator 或 UIView motion() / fadeIn() 等扩展',
      '使用 EffectPresets 里的预设；自定义组合时用 MotionEffect 数组',
      'FadeOptions 的 duration 单位是毫秒（Int）',
    ],
  },
  kotlin: {
    label: 'Android Kotlin (View 系统)',
    pkg: 'com.fadeanimation (Gradle artifact)',
    codeFence: 'kotlin',
    requirements: [
      '直接输出可运行的完整 Kotlin 代码',
      '使用 Android View 系统（兼容 API 21+）',
      '调用 MotionAnimator 或 View motion() / fadeIn() 等扩展',
      '使用 EffectPresets.* 里的预设；自定义组合时用 MotionEffect 数组',
      'FadeOptions 的 duration 类型是 Long（毫秒）',
    ],
  },
};

const platform = ref<Platform>('react');
const copied = ref(false);

function buildPrompt(p: Platform): string {
  const meta = AI_PLATFORM_META[p];
  const cs = props.case;
  const refCode = cs[p] || cs.react || '// no reference available';
  const lines: string[] = [];
  lines.push(`你是一名资深的${meta.label}工程师。请使用 Kinetic UI 动效组件库（${meta.pkg}，已安装）实现一个"${cs.name}"场景。`);
  lines.push('');
  lines.push('## 分类');
  lines.push(props.categoryLabel);
  lines.push('');
  lines.push('## 动效描述');
  lines.push(cs.desc || '');
  if (cs.scenario) {
    lines.push('');
    lines.push('## 使用场景');
    lines.push(cs.scenario);
  }
  lines.push('');
  lines.push('## 推荐参数');
  if (cs.effect) lines.push(`- effect: ${cs.effect}`);
  if (cs.duration) lines.push(`- duration: ${cs.duration}ms`);
  if (cs.easing) lines.push(`- easing: ${cs.easing}`);
  lines.push('');
  lines.push(`## 参考实现（${meta.label}）`);
  lines.push('```' + meta.codeFence);
  lines.push(refCode);
  lines.push('```');
  if (cs.cautions?.length) {
    lines.push('');
    lines.push('## 注意事项');
    cs.cautions.forEach((c) => lines.push(`- ${c}`));
  }
  if (cs.tips?.length) {
    lines.push('');
    lines.push('## 最佳实践');
    cs.tips.forEach((t) => lines.push(`- ${t}`));
  }
  lines.push('');
  lines.push('## 要求');
  meta.requirements.forEach((r, i) => lines.push(`${i + 1}. ${r}`));
  return lines.join('\n');
}

async function copyPrompt() {
  const prompt = buildPrompt(platform.value);
  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(prompt);
    } else {
      const ta = document.createElement('textarea');
      ta.value = prompt;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
    }
    copied.value = true;
    setTimeout(() => (copied.value = false), 1800);
  } catch (e) {
    console.error('copy failed', e);
  }
}
</script>

<template>
  <div class="ku-ai-prompt">
    <div class="ku-ai-prompt-text">
      <div class="ku-ai-prompt-title">🤖 在 AI 编辑器中使用</div>
      <div class="ku-ai-prompt-desc">
        选择目标端，一键复制完整 Prompt，粘贴到 Cursor / Copilot / v0 即可让 AI 生成对应端的业务代码
      </div>
    </div>
    <div class="ku-ai-prompt-controls">
      <select class="ku-ai-prompt-select" v-model="platform">
        <option value="react">React</option>
        <option value="vue">Vue</option>
        <option value="swift">iOS Swift</option>
        <option value="kotlin">Android Kotlin</option>
      </select>
      <button class="ku-ai-prompt-btn" :class="{ copied }" @click="copyPrompt">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="9" y="9" width="13" height="13" rx="2" />
          <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
        </svg>
        <span>{{ copied ? '已复制 ✓' : '复制 AI Prompt' }}</span>
      </button>
    </div>
  </div>
</template>
