// Figma Plugin: Fade Animation Code Generator
// 主线程代码 — 与 Figma API 交互
// 效果预设映射
const EFFECT_PRESETS = {
    'fade-in': { effects: '[{ type: "fade", from: 0, to: 1 }]', description: '淡入' },
    'fade-out': { effects: '[{ type: "fade", from: 1, to: 0 }]', description: '淡出' },
    'scale-fade-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "scale", from: 0.95, to: 1 }]', description: '缩放淡入' },
    'scale-fade-out': { effects: '[{ type: "fade", from: 1, to: 0 }, { type: "scale", from: 1, to: 0.95 }]', description: '缩放淡出' },
    'slide-up-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "slide", direction: "up", distance: 16 }]', description: '上滑淡入' },
    'slide-down-out': { effects: '[{ type: "fade", from: 1, to: 0 }, { type: "slide", direction: "down", distance: 16 }]', description: '下滑淡出' },
    'blur-fade-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "blur", from: 8, to: 0 }]', description: '模糊淡入' },
    'flip-y-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "flip", axis: "y", from: 90, to: 0 }]', description: 'Y轴翻转淡入' },
    'flip-x-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "flip", axis: "x", from: 90, to: 0 }]', description: 'X轴翻转淡入' },
    'collapse-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "collapse", collapsedHeight: 0 }]', description: '折叠展开' },
    'rotate-fade-in': { effects: '[{ type: "fade", from: 0, to: 1 }, { type: "rotate", from: -10, to: 0 }]', description: '旋转淡入' },
};
// Timing tokens
const TIMING_MAP = {
    't1': { ms: 100, label: 'extra-fast (100ms)' },
    't2': { ms: 150, label: 'fast (150ms)' },
    't3': { ms: 300, label: 'normal (300ms)' },
    't4': { ms: 500, label: 'slow (500ms)' },
    't5': { ms: 700, label: 'extra-slow (700ms)' },
};
// Intent defaults
const INTENT_MAP = {
    'enter': { timing: 't3', easing: 'enter' },
    'exit': { timing: 't2', easing: 'exit' },
    'focus': { timing: 't2', easing: 'expressive' },
    'feedback': { timing: 't1', easing: 'productive' },
    'delight': { timing: 't4', easing: 'expressive' },
};
// Android preset name mapping
const ANDROID_PRESET = {
    'fade-in': 'EffectPresets.FADE_IN',
    'fade-out': 'EffectPresets.FADE_OUT',
    'scale-fade-in': 'EffectPresets.SCALE_FADE_IN',
    'scale-fade-out': 'EffectPresets.SCALE_FADE_OUT',
    'slide-up-in': 'EffectPresets.SLIDE_UP_IN',
    'slide-down-out': 'EffectPresets.SLIDE_DOWN_OUT',
    'blur-fade-in': 'EffectPresets.BLUR_FADE_IN',
    'flip-y-in': 'EffectPresets.FLIP_Y_IN',
    'flip-x-in': 'EffectPresets.FLIP_X_IN',
    'collapse-in': 'EffectPresets.COLLAPSE_IN',
    'rotate-fade-in': 'EffectPresets.ROTATE_FADE_IN',
};
// iOS preset name mapping
const IOS_PRESET = {
    'fade-in': 'EffectPresets.fadeIn',
    'fade-out': 'EffectPresets.fadeOut',
    'scale-fade-in': 'EffectPresets.scaleFadeIn',
    'scale-fade-out': 'EffectPresets.scaleFadeOut',
    'slide-up-in': 'EffectPresets.slideUpIn',
    'slide-down-out': 'EffectPresets.slideDownOut',
    'blur-fade-in': 'EffectPresets.blurFadeIn',
    'flip-y-in': 'EffectPresets.flipYIn',
    'flip-x-in': 'EffectPresets.flipXIn',
    'collapse-in': 'EffectPresets.collapseIn',
    'rotate-fade-in': 'EffectPresets.rotateFadeIn',
};
figma.showUI(__html__, { width: 420, height: 640 });
// 获取选中节点信息
function getSelectionInfo() {
    const sel = figma.currentPage.selection;
    if (sel.length === 0)
        return null;
    const node = sel[0];
    return {
        name: node.name,
        type: node.type,
        width: Math.round('width' in node ? node.width : 0),
        height: Math.round('height' in node ? node.height : 0),
    };
}
// 生成代码
function generateCode(config) {
    const { preset, intent, timing, customDuration, delay, nodeName } = config;
    const timingMs = customDuration ?? TIMING_MAP[timing]?.ms ?? 300;
    // --- React ---
    let reactProps = `in={show} effect="${preset}"`;
    if (intent)
        reactProps += ` intent="${intent}"`;
    if (customDuration)
        reactProps += ` duration={${customDuration}}`;
    else if (timing !== 't3')
        reactProps += ` timing="${timing}"`;
    if (delay > 0)
        reactProps += ` delay={${delay}}`;
    const react = `import { Motion } from '@fade-animation/react';

<Motion ${reactProps}>
  <${nodeName} />
</Motion>`;
    // --- Android ---
    const androidPreset = ANDROID_PRESET[preset] || 'EffectPresets.FADE_IN';
    let androidOptions = '';
    if (intent)
        androidOptions += `    options = FadeOptions(intent = MotionIntent.${intent.toUpperCase()}),\n`;
    if (customDuration)
        androidOptions += `    options = FadeOptions(duration = ${customDuration}L),\n`;
    if (delay > 0)
        androidOptions += `    options = FadeOptions(delay = ${delay}L),\n`;
    const android = `val animator = MotionAnimator(targetView = ${camelCase(nodeName)}View)
animator.start(
    entering = true,
    effects = ${androidPreset}${androidOptions ? ',\n' + androidOptions.trimEnd() : ''}
)`;
    // --- iOS ---
    const iosPreset = IOS_PRESET[preset] || 'EffectPresets.fadeIn';
    let iosOptions = [];
    if (intent)
        iosOptions.push(`intent: .${intent}`);
    if (customDuration)
        iosOptions.push(`duration: ${customDuration}`);
    if (delay > 0)
        iosOptions.push(`delay: ${delay}`);
    const iosOptionsStr = iosOptions.length > 0
        ? `,\n    options: FadeOptions(${iosOptions.join(', ')})`
        : '';
    const ios = `let animator = MotionAnimator(targetView: ${camelCase(nodeName)}View)
animator.start(
    entering: true,
    effects: ${iosPreset}${iosOptionsStr}
)`;
    return { react, android, ios };
}
function camelCase(str) {
    return str
        .replace(/[^a-zA-Z0-9\s]/g, '')
        .split(/\s+/)
        .map((w, i) => i === 0 ? w.toLowerCase() : w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
        .join('');
}
// 监听选择变化
figma.on('selectionchange', () => {
    const info = getSelectionInfo();
    figma.ui.postMessage({ type: 'selection-changed', data: info });
});
// 初始发送选择信息和配置数据
figma.ui.postMessage({
    type: 'init',
    data: {
        selection: getSelectionInfo(),
        presets: Object.entries(EFFECT_PRESETS).map(([key, val]) => ({ key, ...val })),
        timings: Object.entries(TIMING_MAP).map(([key, val]) => ({ key, ...val })),
        intents: Object.keys(INTENT_MAP),
    },
});
// 处理 UI 消息
figma.ui.onmessage = (msg) => {
    if (msg.type === 'generate') {
        const code = generateCode(msg.config);
        figma.ui.postMessage({ type: 'code-generated', data: code });
        // 将动效参数存入节点的 pluginData
        const sel = figma.currentPage.selection;
        if (sel.length > 0) {
            sel[0].setPluginData('motion-config', JSON.stringify(msg.config));
        }
    }
    if (msg.type === 'copy-notify') {
        figma.notify(msg.platform + ' code copied to clipboard');
    }
    if (msg.type === 'close') {
        figma.closePlugin();
    }
};
