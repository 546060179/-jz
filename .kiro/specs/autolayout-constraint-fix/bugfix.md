# Bugfix 需求文档

## 简介

安卓端三个组件（RewardPopupView、ContinueWatchingView、BubbleExpandView）在初始布局阶段大量使用 FrameLayout + 手动 `.layout()` 调用和绝对 margin 定位子视图。这导致布局不灵活、无法适应不同屏幕尺寸、手动计算位置容易出错、代码维护困难。

需要将容器从 FrameLayout 改为 ConstraintLayout，通过约束关系（constraints）声明式地定位子视图，移除手动 `.layout()` 调用和绝对 margin 定位。同时保留动画阶段（tickShrink、tickMorph 等）中的 `.layout()` 调用，因为这些是动画驱动的必要操作。

## Bug 分析

### 当前行为（缺陷）

1.1 WHEN RewardPopupView 的 header 区域包含多个 ImageView（礼盒、金币、星星）时 THEN 系统使用 FrameLayout + 手动 leftMargin/topMargin 绝对定位每个子视图，无法适应不同屏幕尺寸和密度

1.2 WHEN ContinueWatchingView 的 setupViews() 将子视图（coverImageView、infoContainer、playButton、closeButton）添加到 bannerContainer 时 THEN 系统未指定任何 LayoutParams，依赖 layoutBanner() 中的手动 `.layout()` 调用来定位

1.3 WHEN ContinueWatchingView 的 layoutBanner() 被调用时 THEN 系统使用手动 `.layout(left, top, right, bottom)` 调用来计算和设置每个子视图的精确像素位置

1.4 WHEN ContinueWatchingView 的 layoutWidgetButtons() 被调用时 THEN 系统使用手动 `.layout()` 调用来定位 widgetPlayButton 和 widgetCloseButton

1.5 WHEN BubbleExpandView 的 arrowView 需要定位时 THEN 系统通过 layoutArrow() 方法手动设置 leftMargin 和 topMargin 来定位箭头

1.6 WHEN BubbleExpandView 初始化时 THEN textView 和 arrowView 使用 FrameLayout 的 LayoutParams 添加，缺少 gravity 等对齐属性

### 期望行为（正确）

2.1 WHEN RewardPopupView 的 header 区域包含多个 ImageView 时 THEN 系统 SHALL 将 header 从 FrameLayout 改为 ConstraintLayout，通过约束关系定位每个子视图（礼盒、金币、星星），移除手动 leftMargin/topMargin 绝对定位

2.2 WHEN ContinueWatchingView 的 setupViews() 将子视图添加到 bannerContainer 时 THEN 系统 SHALL 将 bannerContainer 从 FrameLayout 改为 ConstraintLayout，为每个子视图（coverImageView、infoContainer、playButton、closeButton）设置约束关系，由 ConstraintLayout 完成初始布局

2.3 WHEN ContinueWatchingView 需要布局 banner 状态时 THEN 系统 SHALL 通过 ConstraintLayout 的约束关系实现子视图定位，移除 layoutBanner() 中对子视图的手动 `.layout()` 调用

2.4 WHEN ContinueWatchingView 的 widget 按钮需要定位时 THEN 系统 SHALL 通过 ConstraintLayout.LayoutParams 的约束属性定位 widgetPlayButton 和 widgetCloseButton，移除 layoutWidgetButtons() 中的手动 `.layout()` 调用

2.5 WHEN BubbleExpandView 的 arrowView 需要定位时 THEN 系统 SHALL 将容器改为 ConstraintLayout，通过约束关系实现 arrowView 的垂直居中和水平定位，移除 layoutArrow() 中的手动 margin 计算

2.6 WHEN BubbleExpandView 初始化时 THEN 系统 SHALL 通过 ConstraintLayout 约束关系实现 textView 的垂直居中和 arrowView 紧跟在 textView 右侧并垂直居中

### 不变行为（回归防护）

3.1 WHEN ContinueWatchingView 的动画阶段（tickShrink、tickMorph、tickDismiss）执行时 THEN 系统 SHALL 继续使用 `.layout()` 调用和 LayoutParams 动态修改来驱动动画，这些动画驱动的布局操作不受影响

3.2 WHEN RewardPopupView 的弹簧动画（show/dismiss）执行时 THEN 系统 SHALL 继续使用 SpringAnimation 和 animate() 驱动动画效果，动画逻辑不受影响

3.3 WHEN BubbleExpandView 的展开动画（tickExpand、tickTextFade）执行时 THEN 系统 SHALL 继续使用 Choreographer 帧回调驱动动画，动画逻辑不受影响

3.4 WHEN 各组件的视觉外观（颜色、圆角、字体、间距）渲染时 THEN 系统 SHALL 继续保持与 Figma 设计稿一致的视觉效果

3.5 WHEN 用户与各组件交互（点击按钮、关闭弹窗）时 THEN 系统 SHALL 继续正确响应用户交互事件
