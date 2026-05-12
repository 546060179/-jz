<script setup lang="ts">
import { computed, ref, watch, nextTick, onMounted } from 'vue';
import { EDITABLE_KIND, type EditableKind, type ComponentCase } from '../../../data/types';
import {
  EASING_CURVES,
  EASING_OPTIONS,
  INTENT_DEFAULTS,
  INTENT_OPTIONS,
  PREVIEW_TEMPLATE,
} from '../animHelpers';
import PreviewCard from './PreviewCard.vue';

const props = defineProps<{ case: ComponentCase }>();

const kind: EditableKind = EDITABLE_KIND[props.case.id] || 'custom';
const editable = computed(() => kind === 'motion');

// Default values seeded from the case definition
const defaultDuration = props.case.duration || 300;
const defaultEasing = EASING_OPTIONS.includes(props.case.easing as any)
  ? props.case.easing
  : 'enter';

const duration = ref(defaultDuration);
const easing = ref(defaultEasing);
const intent = ref('');
const tab = ref<'react' | 'vue' | 'swift' | 'kotlin'>('react');

const previewRef = ref<HTMLElement | null>(null);

function resolvedParams() {
  if (intent.value && INTENT_DEFAULTS[intent.value]) {
    const d = INTENT_DEFAULTS[intent.value];
    return { dur: d.duration, easingName: d.easing };
  }
  return { dur: duration.value, easingName: easing.value };
}

function replay() {
  if (!editable.value) return;
  const host = previewRef.value;
  if (!host) return;
  const el = host.querySelector<HTMLElement>('.cp-el');
  if (!el) return;
  const { dur, easingName } = resolvedParams();
  const curve = EASING_CURVES[easingName] || 'ease';
  const effect = (props.case.effect || 'fade-in') as keyof typeof PREVIEW_TEMPLATE;
  const template = PREVIEW_TEMPLATE[effect] || PREVIEW_TEMPLATE['scale-fade-in'];
  template(el, dur, curve);
}

/** Replay on param change */
watch([duration, easing, intent], () => {
  nextTick(replay);
});

onMounted(() => {
  nextTick(replay);
});

// ------------------------------------------------------------
// Code generation for the four platforms
// ------------------------------------------------------------
function effectName(): string {
  const e = props.case.effect || 'fade-in';
  // Filter out human-readable compound names (contain space or '+')
  return e.indexOf(' ') < 0 && e.indexOf('+') < 0 ? e : 'fade-in';
}

const SWIFT_PRESETS: Record<string, string> = {
  'fade-in': 'fadeIn', 'scale-fade-in': 'scaleFadeIn', 'slide-up-in': 'slideUpIn',
  'slide-down-out': 'slideDownOut', 'slide-left-in': 'slideLeftIn', 'slide-right-in': 'slideRightIn',
  'flip-x-in': 'flipXIn', 'flip-y-in': 'flipYIn', 'collapse-in': 'collapseIn',
};
const KOTLIN_PRESETS: Record<string, string> = {
  'fade-in': 'FADE_IN', 'scale-fade-in': 'SCALE_FADE_IN', 'slide-up-in': 'SLIDE_UP_IN',
  'slide-down-out': 'SLIDE_DOWN_OUT', 'slide-left-in': 'SLIDE_LEFT_IN', 'slide-right-in': 'SLIDE_RIGHT_IN',
  'flip-x-in': 'FLIP_X_IN', 'flip-y-in': 'FLIP_Y_IN', 'collapse-in': 'COLLAPSE_IN',
};
const IOS_CURVE_MAP: Record<string, string> = {
  enter: '.easeOut', exit: '.easeIn', productive: '.easeOut',
  expressive: '.easeInOut', linear: '.linear',
};
const ANDROID_INTERP_MAP: Record<string, string> = {
  enter: 'DecelerateInterpolator()',
  exit: 'AccelerateInterpolator()',
  productive: 'DecelerateInterpolator()',
  expressive: 'AccelerateDecelerateInterpolator()',
  linear: 'LinearInterpolator()',
};

function generatedCode(): string {
  // Non-motion kinds: return the case's hand-written code as-is.
  if (!editable.value) {
    const fallback = props.case[tab.value];
    return fallback || '// 该端暂无示例';
  }

  const effect = effectName();
  const useIntent = !!intent.value;

  if (tab.value === 'react') {
    const lines = ['import { Motion } from "@fade-animation/react";', '', '<Motion'];
    lines.push('  in={show}');
    lines.push(`  effect="${effect}"`);
    if (useIntent) lines.push(`  intent="${intent.value}"`);
    else {
      lines.push(`  duration={${duration.value}}`);
      lines.push(`  easing="${easing.value}"`);
    }
    lines.push('>');
    lines.push('  <YourContent />');
    lines.push('</Motion>');
    return lines.join('\n');
  }

  if (tab.value === 'vue') {
    const lines = [
      '<script setup>',
      'import { Motion } from "@fade-animation/vue";',
      '<\/script>',
      '',
      '<template>',
      '  <Motion',
      '    :in="show"',
      `    effect="${effect}"`,
    ];
    if (useIntent) lines.push(`    intent="${intent.value}"`);
    else {
      lines.push(`    :duration="${duration.value}"`);
      lines.push(`    easing="${easing.value}"`);
    }
    lines.push('  >');
    lines.push('    <YourContent />');
    lines.push('  </Motion>');
    lines.push('</template>');
    return lines.join('\n');
  }

  if (tab.value === 'swift') {
    const preset = SWIFT_PRESETS[effect] || 'fadeIn';
    const opts: string[] = [];
    if (useIntent) opts.push(`intent: .${intent.value}`);
    else {
      opts.push(`duration: ${duration.value}`);
      opts.push(`curve: ${IOS_CURVE_MAP[easing.value] || '.easeInOut'}`);
    }
    return [
      'import FadeAnimation',
      '',
      'view.motion(',
      '  entering: true,',
      `  effects: EffectPresets.${preset},`,
      `  options: FadeOptions(${opts.join(', ')})`,
      ')',
    ].join('\n');
  }

  // kotlin
  const preset = KOTLIN_PRESETS[effect] || 'FADE_IN';
  const opts: string[] = [];
  if (useIntent) opts.push(`intent = MotionIntent.${intent.value.toUpperCase()}`);
  else {
    opts.push(`duration = ${duration.value}L`);
    opts.push(`interpolator = ${ANDROID_INTERP_MAP[easing.value] || 'AccelerateDecelerateInterpolator()'}`);
  }
  return [
    'import com.fadeanimation.*',
    '',
    'MotionAnimator(',
    '  view,',
    `  FadeOptions(${opts.join(', ')})`,
    `).start(entering = true, effects = EffectPresets.${preset})`,
  ].join('\n');
}

const hintByKind: Record<EditableKind, string> = {
  motion: '',
  loop: '💡 这是循环动画（CSS @keyframes / CABasicAnimation / ObjectAnimator 驱动），不通过 <Motion> 的 duration/easing props 调节。下方代码为推荐实现。',
  native: '💡 这是平台原生动画，参数写死在平台代码中。下方代码为推荐实现。',
  gesture: '💡 手势类动效的时长/速度由用户操作决定，不通过 Motion props 调节。下方代码为参考实现。',
  custom: '💡 这是项目级自建组件或多步编排，参数内嵌在组件内部。下方代码展示如何接入该组件。',
};

const hint = computed(() => hintByKind[kind]);
</script>

<template>
  <div class="ku-editor">
    <!-- Left panel -->
    <div class="ku-editor-panel">
      <div class="ku-editor-row">
        <label>
          duration
          <span class="v">{{ duration }}ms</span>
        </label>
        <input
          type="range"
          min="50"
          max="1500"
          step="10"
          v-model.number="duration"
          :disabled="!editable"
        />
      </div>

      <div class="ku-editor-row">
        <label>easing</label>
        <select v-model="easing" :disabled="!editable">
          <option v-for="e in EASING_OPTIONS" :key="e" :value="e">{{ e }}</option>
        </select>
      </div>

      <div class="ku-editor-row">
        <label>
          intent
          <span class="v" style="color: var(--ku-t3); font-size: 10px">(覆盖 easing+duration)</span>
        </label>
        <select v-model="intent" :disabled="!editable">
          <option value="">（不设置）</option>
          <option v-for="i in INTENT_OPTIONS" :key="i" :value="i">{{ i }}</option>
        </select>
      </div>

      <div style="margin-top: auto">
        <button class="ku-editor-reset" @click="replay">▶ 重新播放</button>
      </div>
    </div>

    <!-- Right: preview -->
    <div class="ku-editor-preview" ref="previewRef" @click="replay">
      <PreviewCard :case-id="props.case.id" />
    </div>

    <!-- Hint for non-editable kinds -->
    <div v-if="hint" class="ku-editor-hint">{{ hint }}</div>

    <!-- Code block -->
    <div class="ku-editor-code-wrap">
      <div class="ku-editor-tabs">
        <button
          v-for="p in (['react', 'vue', 'swift', 'kotlin'] as const)"
          :key="p"
          class="ku-editor-tab"
          :class="{ on: tab === p }"
          @click="tab = p"
        >
          {{ p === 'react' ? 'React' : p === 'vue' ? 'Vue' : p === 'swift' ? 'iOS Swift' : 'Android Kotlin' }}
        </button>
      </div>
      <pre class="ku-editor-code">{{ generatedCode() }}</pre>
    </div>
  </div>
</template>
