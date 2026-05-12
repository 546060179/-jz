# Fade Animation Code Generator — Figma 插件

设计师在 Figma 中选中元素，配置动效参数，一键生成 React / Android / iOS 三端代码。

## 安装与使用

### 1. 安装依赖并编译

```bash
cd figma-plugin
npm install
npm run build
```

### 2. 在 Figma 中加载插件

1. 打开 Figma Desktop
2. 菜单 → Plugins → Development → Import plugin from manifest...
3. 选择 `figma-plugin/manifest.json`

### 3. 使用

1. 在画布中选中一个 Frame / Component
2. 右键 → Plugins → Fade Animation Code Generator
3. 选择效果预设（如 scale-fade-in）
4. 选择动效意图（如 enter），Timing 会自动联动
5. 点击「生成代码」
6. 在 React / Android / iOS 三个 tab 中切换查看代码
7. 点击「复制」按钮，粘贴到项目中即可

## 功能

- 18 个效果预设，覆盖 fade / scale / slide / rotate / blur / flip / collapse
- 5 种 Motion Intent（enter / exit / focus / feedback / delight），自动推导 timing + easing
- 5 级 Timing Scale（t1~t5），支持自定义 duration 覆盖
- 自动将动效参数存入 Figma 节点的 pluginData，Kiro MCP 可读取
- 生成的代码基于 @fade-animation 组件库，复制即用
