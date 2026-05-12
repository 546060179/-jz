# Design Tokens

Kinetic UI 的 tokens 体系分为 4 个维度：

## 1. Timing Scales — 时长刻度

| Token | 别名 | 值 | 场景 |
|---|---|---|---|
| `t1` | `extra-fast` | 100ms | 微交互、按钮按压 |
| `t2` | `fast` | 150ms | 小组件动画、tooltip |
| `t3` | `normal` | 300ms | 标准过渡、卡片 |
| `t4` | `slow` | 500ms | 大面积过渡、页面切换 |
| `t5` | `extra-slow` | 700ms | 复杂编排 |

```tsx
<Motion timing="t3" />           // 推荐
<Motion timing="normal" />        // 也可以
<Motion duration={300} />         // 直接写值优先级最高
```

## 2. Distance Scales — 位移距离

| Token | 别名 | 值 |
|---|---|---|
| `d1` | `micro` | 4px |
| `d2` | `small` | 8px |
| `d3` | `medium` | 16px |
| `d4` | `large` | 32px |
| `d5` | `full` | 64px |

```tsx
<Motion effect={[{type:'slide', distance: 16}]} />
```

## 3. Easing Curves — 缓动曲线

| Token | CSS | 适合场景 |
|---|---|---|
| `productive` | `cubic-bezier(0.2, 0, 0.38, 0.9)` | 退出、关闭、收起 |
| `expressive` | `cubic-bezier(0.4, 0.14, 0.3, 1)` | 进入、展开、强调 |
| `enter` | `cubic-bezier(0, 0, 0.3, 1)` | 元素进入（ease-out 风格） |
| `exit` | `cubic-bezier(0.4, 0, 1, 1)` | 元素离开（ease-in 风格） |
| `linear` | `linear` | 循环动画、进度条 |

## 4. Motion Intent — 动画意图

| Intent | 默认 timing | 默认 easing | 场景 |
|---|---|---|---|
| `enter` | t3 (300ms) | enter | 进入视图 |
| `exit` | t2 (150ms) | exit | 离开视图 |
| `focus` | t2 (150ms) | expressive | 吸引注意力 |
| `feedback` | t1 (100ms) | productive | 操作反馈 |
| `delight` | t4 (500ms) | expressive | 品牌个性 |

**推荐写法**：能用 intent 就用 intent，它会自动选好 timing 和 easing：

```tsx
<Motion effect="fade-in" intent="enter" />    // ✅ 语义化
<Motion effect="fade-in" duration={300} easing="enter" />  // 等价但啰嗦
```

## 优先级

`duration > timing > preset > intent > 默认值`
`easing > intent > 默认值`

手动指定的值永远覆盖 token / intent 推导。
