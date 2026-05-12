# 动画意图 (Intent)

动画意图是 Kinetic UI 对"这个动画想表达什么"的语义化标签。它直接映射到一组推荐的 timing + easing。

## 五种意图

### enter — 进入

元素出现在视图中。强调"减速到位"。

```tsx
<Motion effect="scale-fade-in" intent="enter" />
// 等价于 duration=300ms, easing=cubic-bezier(0, 0, 0.3, 1)
```

### exit — 退出

元素离开视图。强调"快速带走"。

```tsx
<Motion effect="scale-fade-out" intent="exit" />
// 等价于 duration=150ms, easing=cubic-bezier(0.4, 0, 1, 1)
```

### focus — 强调

吸引用户注意，比如脉冲、轻微抖动。

```tsx
<Motion effect={[{type:'scale', from:1, to:1.05}]} intent="focus" />
```

### feedback — 反馈

直接回应用户的点击、拖拽，必须很快。

```tsx
<Motion in={pressed} effect={[{type:'scale', to:0.95}]} intent="feedback" />
// 100ms, productive 曲线
```

### delight — 愉悦

品牌个性动画，比如 VIP 卡片翻转、成功打勾。

```tsx
<Motion effect={[{type:'scale', from:0, to:1}]} intent="delight" />
// 500ms, expressive 曲线（带弹性）
```

## 为什么要用 intent

写 `intent="enter"` 比写 `duration={300} easing="cubic-bezier(0, 0, 0.3, 1)"` 多了两层好处：

1. **语义清晰**：代码里能一眼看出这是个进入动画
2. **全局统一**：如果设计规范调整（比如把所有 enter 从 300ms 改成 250ms），只需要改一个常量，不用改几十个组件
