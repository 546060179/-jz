<script setup lang="ts">
import { computed } from 'vue';
import casesJson from '../../../data/cases.json';
import type { ComponentCase } from '../../data/types';
import PreviewCard from './PreviewCard.vue';
import VisualEditor from './VisualEditor.vue';
import AIPromptBlock from './AIPromptBlock.vue';

interface CategoryShape {
  id: string;
  label: string;
  count: number;
  cases: ComponentCase[];
}

const props = defineProps<{
  categoryId: string;
  caseId: string;
}>();

const categories = casesJson as CategoryShape[];

const category = computed(() => categories.find((c) => c.id === props.categoryId));
const componentCase = computed<ComponentCase | undefined>(() =>
  category.value?.cases.find((c) => c.id === props.caseId),
);

const platforms = computed(() => {
  if (!componentCase.value) return [];
  const cs = componentCase.value;
  return (
    [
      { key: 'react', label: 'React', code: cs.react, lang: 'tsx' },
      { key: 'vue', label: 'Vue', code: cs.vue, lang: 'vue' },
      { key: 'swift', label: 'iOS Swift', code: cs.swift, lang: 'swift' },
      { key: 'kotlin', label: 'Android Kotlin', code: cs.kotlin, lang: 'kotlin' },
    ] as const
  ).filter((p) => !!p.code);
});
</script>

<template>
  <div v-if="!componentCase" class="ku-missing">动效不存在：{{ caseId }}</div>
  <div v-else class="ku-demo">
    <h1>{{ componentCase.name }}</h1>
    <p class="ku-demo-desc">{{ componentCase.desc }}</p>

    <div class="ku-import-line">
      <code>import {{ '{ Motion }' }} from '@fade-animation/react';</code>
    </div>

    <!-- 何时使用 -->
    <section v-if="componentCase.scenario" id="when-to-use">
      <h2>何时使用</h2>
      <p>{{ componentCase.scenario }}</p>
    </section>

    <!-- 代码演示 -->
    <section id="demo">
      <h2>代码演示</h2>
      <div class="ku-demo-box">
        <div class="ku-demo-preview">
          <PreviewCard :case-id="componentCase.id" />
        </div>
        <div class="ku-demo-meta">
          <span class="ku-demo-title">基础用法</span>
        </div>
        <div class="ku-demo-hint">{{ componentCase.desc }}</div>
      </div>

      <div v-for="p in platforms" :key="p.key" class="ku-code-block">
        <div class="ku-code-label">{{ p.label }}</div>
        <pre class="ku-code-body"><code>{{ p.code }}</code></pre>
      </div>
    </section>

    <!-- 可视化编辑器 -->
    <section id="editor">
      <h2>可视化编辑器 <span class="ku-section-hint">实时调整参数预览动效</span></h2>
      <VisualEditor :case="componentCase" />
    </section>

    <!-- API -->
    <section v-if="componentCase.effect || componentCase.duration || componentCase.easing" id="api">
      <h2>API</h2>
      <table class="ku-api-tbl">
        <thead>
          <tr>
            <th>参数</th>
            <th>说明</th>
            <th>类型</th>
            <th>默认值</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="componentCase.effect">
            <td>effect</td><td>动效类型</td>
            <td><code>string | MotionEffect[]</code></td>
            <td><code>{{ componentCase.effect }}</code></td>
          </tr>
          <tr v-if="componentCase.duration">
            <td>duration</td><td>动画时长 (ms)</td>
            <td><code>number</code></td>
            <td><code>{{ componentCase.duration }}</code></td>
          </tr>
          <tr v-if="componentCase.easing">
            <td>easing</td><td>缓动函数</td>
            <td><code>string</code></td>
            <td><code>{{ componentCase.easing }}</code></td>
          </tr>
          <tr>
            <td>in</td><td>控制进入/退出</td>
            <td><code>boolean</code></td>
            <td><code>false</code></td>
          </tr>
          <tr>
            <td>intent</td><td>动画意图</td>
            <td><code>enter | exit | feedback</code></td>
            <td><code>enter</code></td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- 注意事项 -->
    <section v-if="componentCase.cautions?.length" id="cautions">
      <h2>注意事项</h2>
      <div class="ku-warn">
        <ul>
          <li v-for="(c, i) in componentCase.cautions" :key="i">{{ c }}</li>
        </ul>
      </div>
    </section>

    <!-- 最佳实践 -->
    <section v-if="componentCase.tips?.length" id="tips">
      <h2>最佳实践</h2>
      <div class="ku-tip">
        <ul>
          <li v-for="(t, i) in componentCase.tips" :key="i">{{ t }}</li>
        </ul>
      </div>
    </section>

    <!-- AI Prompt CTA -->
    <AIPromptBlock :case="componentCase" :category-label="category?.label || ''" />
  </div>
</template>

<style scoped>
.ku-demo h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 12px;
}
.ku-demo-desc {
  color: var(--ku-t2);
  margin-bottom: 20px;
}
.ku-import-line {
  margin-bottom: 24px;
  padding: 12px 16px;
  background: var(--ku-bg3);
  border: 1px solid var(--ku-bd);
  border-radius: 6px;
  font-family: var(--ku-mono);
  font-size: 13px;
  color: var(--ku-t2);
}
.ku-demo-box {
  border: 1px solid var(--ku-bd);
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 16px;
}
.ku-demo-preview {
  padding: 40px;
  background: var(--ku-bg3);
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 160px;
}
.ku-demo-meta {
  padding: 12px 16px;
  border-top: 1px solid var(--ku-bd);
}
.ku-demo-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--ku-t1);
}
.ku-demo-hint {
  font-size: 13px;
  color: var(--ku-t2);
  padding: 0 16px 12px;
  line-height: 1.7;
}
.ku-code-block {
  margin-bottom: 16px;
}
.ku-code-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--ku-t1);
  padding: 12px 0 6px;
  border-top: 1px solid var(--ku-bd);
}
.ku-code-body {
  padding: 14px 16px;
  font-family: var(--ku-mono);
  font-size: 12px;
  line-height: 1.7;
  background: var(--ku-bg3);
  border: 1px solid var(--ku-bd);
  border-radius: 8px;
  overflow-x: auto;
  margin: 0;
  white-space: pre;
}
.ku-code-body code {
  background: none;
  padding: 0;
  color: var(--ku-t2);
  font-family: inherit;
}
.ku-api-tbl {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
  margin: 8px 0;
}
.ku-api-tbl th, .ku-api-tbl td {
  padding: 8px 10px;
  border-bottom: 1px solid var(--ku-bd);
  text-align: left;
}
.ku-api-tbl th {
  background: rgba(255, 255, 255, 0.02);
  font-weight: 600;
  color: var(--ku-t2);
}
.ku-api-tbl td:first-child {
  color: var(--ku-t1);
  font-weight: 500;
}
.ku-warn, .ku-tip {
  margin: 8px 0 16px;
  padding: 12px 16px;
  border-radius: 4px;
  line-height: 1.6;
  font-size: 13px;
}
.ku-warn {
  background: rgba(250, 204, 21, 0.06);
  border: 1px solid rgba(250, 204, 21, 0.12);
  color: #fbbf24;
}
.ku-tip {
  background: rgba(46, 91, 255, 0.06);
  border: 1px solid rgba(46, 91, 255, 0.12);
  color: var(--ku-ch);
}
.ku-warn ul, .ku-tip ul {
  margin: 0;
  padding-left: 16px;
}
.ku-section-hint {
  font-size: 12px;
  color: var(--ku-t3);
  font-weight: 400;
  margin-left: 8px;
}
.ku-missing {
  padding: 32px;
  text-align: center;
  color: var(--ku-t3);
}
</style>
