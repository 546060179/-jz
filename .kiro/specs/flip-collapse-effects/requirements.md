# 需求文档

## 简介

在现有 Fade Animation Library 的 effects 体系（已支持 fade、scale、slide、rotate、blur）基础上，新增 Flip（3D 翻转）和 Collapse（折叠展开）两种动效类型。两种效果需融入现有的 MotionEffect 联合类型、EFFECT_PRESETS 预设体系，并在 React、Vue、Android (Kotlin)、iOS (Swift) 四个平台上实现，保持与现有效果一致的 API 风格和质量标准。

## 术语表

- **Animation_Library**: Fade Animation Library 动效组件库的整体系统
- **Motion_Component**: 通用动效组件（React 的 `<Motion>`、Vue 的 `<Motion>`），用于应用效果组合；通过传入 entering=true/false 来获取对应方向的样式
- **MotionAnimator**: 原生平台（Android/iOS）的通用动效执行器
- **MotionEffect**: 效果联合类型，描述单一动效参数（如 FadeEffect、ScaleEffect 等）
- **EFFECT_PRESETS**: 效果预设字典，将预设名称映射到 MotionEffect 数组
- **FlipEffect**: 3D 翻转效果参数类型，包含翻转轴、角度范围和透视距离
- **CollapseEffect**: 折叠展开效果参数类型，包含折叠后的目标高度（collapsedHeight）
- **Flip_Axis**: 翻转轴方向，"x" 表示绕 X 轴翻转（垂直翻转），"y" 表示绕 Y 轴翻转（水平翻转）
- **Perspective**: CSS perspective 透视距离，控制 3D 翻转的纵深感，单位为像素（px）
- **Expanded_State**: 折叠组件的展开/折叠布尔状态，true 为展开，false 为折叠
- **Content_Height**: 子内容的实际渲染高度，由系统自动测量（Web 端通过 scrollHeight 获取）
- **collapsedHeight**: 折叠后的最终高度（即折叠动画的目标高度），默认为 0；Web 端类型为 `number`（不支持 "auto"）；原生端（Android/iOS）支持 "auto" 特殊值，通过测量当前实际高度来设置折叠目标
- **entering**: 布尔参数，传入 resolveEffectStyles 和 MotionAnimator.start，true 表示展开/进入动画，false 表示折叠/退出动画；Collapse 的展开/折叠方向由此参数决定
- **Duration**: 动画持续时长，单位为毫秒（ms）
- **Delay**: 动画开始前的延迟时间，单位为毫秒（ms）
- **Easing**: 缓动函数，控制动画的速度曲线
- **Preset_Speed**: 预设速度方案，包含 fast（150ms）、normal（300ms）、slow（600ms）三种
- **Reduced_Motion**: 用户在操作系统中设置的"减少动态效果"偏好
- **onAnimationEnd_Callback**: 动画结束时触发的回调函数

## 需求

### 需求 1：FlipEffect 类型定义

**用户故事：** 作为开发者，我希望在 effects 体系中有一个强类型的 FlipEffect 定义，以便在 TypeScript/Kotlin/Swift 中获得完整的类型提示。

#### 验收标准

1. THE Animation_Library SHALL 在 MotionEffect 联合类型中新增 FlipEffect 类型，其 type 字段值为 "flip"
2. THE FlipEffect SHALL 包含可选的 axis 属性，类型为 "x" | "y"，默认值为 "y"
3. THE FlipEffect SHALL 包含可选的 from 属性（起始角度，单位 deg），默认值为 0
4. THE FlipEffect SHALL 包含可选的 to 属性（目标角度，单位 deg），默认值为 180
5. THE FlipEffect SHALL 包含可选的 perspective 属性（透视距离，单位 px），默认值为 800
6. THE Animation_Library SHALL 在 Android 端的 MotionEffect 密封类中新增 Flip 子类，包含 axis、from、to、perspective 属性
7. THE Animation_Library SHALL 在 iOS 端的 MotionEffect 枚举中新增 flip case，包含 axis、from、to、perspective 参数

### 需求 2：CollapseEffect 类型定义

**用户故事：** 作为开发者，我希望在 effects 体系中有一个强类型的 CollapseEffect 定义，以便描述折叠展开动画的参数。

#### 验收标准

1. THE Animation_Library SHALL 在 MotionEffect 联合类型中新增 CollapseEffect 类型，其 type 字段值为 "collapse"
2. THE Web 端（TypeScript）CollapseEffect 的 collapsedHeight 属性类型 SHALL 为 `number`（不包含 "auto"），默认值为 0
3. WHEN collapsedHeight 为数值时，THE Animation_Library SHALL 将该数值作为折叠动画的目标高度（即折叠完成后元素的高度）
4. THE Animation_Library SHALL 在 Android 端的 MotionEffect 密封类中新增 Collapse 子类，包含 collapsedHeight 属性（类型为 CollapseHeight，支持 Fixed 和 Auto）
5. THE Animation_Library SHALL 在 iOS 端的 MotionEffect 枚举中新增 collapse case，包含 collapsedHeight 参数（类型为 CollapseHeight，支持 .fixed 和 .auto）
6. THE "auto" 特殊值 SHALL 仅用于原生平台（Android/iOS），通过测量当前高度来设置折叠目标；Web 端不支持 "auto"

### 需求 3：Flip 效果的 CSS 样式解析（Web 端）

**用户故事：** 作为 Web 前端开发者，我希望 Flip 效果能被正确解析为 CSS transform 属性，以便通过 CSS transition 实现 3D 翻转动画。

#### 验收标准

1. WHEN FlipEffect 的 axis 为 "y" 时，THE resolveEffectStyles SHALL 生成 CSS transform 包含 perspective() 和 rotateY() 函数
2. WHEN FlipEffect 的 axis 为 "x" 时，THE resolveEffectStyles SHALL 生成 CSS transform 包含 perspective() 和 rotateX() 函数
3. THE resolveEffectStyles SHALL 根据 entering 参数决定 FlipEffect 的角度方向：entering=true 时从 from 到 to，entering=false 时从 to 到 from；from/to 为绝对角度，非增量
4. THE resolveEffectStyles SHALL 将 FlipEffect 的 perspective 值映射为 CSS perspective() 函数的参数
5. THE resolveEffectStyles SHALL 将 "transform" 加入 transitionProperties 列表
6. WHEN FlipEffect 与其他 transform 类效果（scale、slide、rotate）组合时，THE resolveEffectStyles SHALL 将所有 transform 函数按效果数组中的出现顺序依次拼接到同一个 transform 属性中
7. THE Animation_Library SHALL 在文档中说明 CSS transform 从右向左应用（最后一个函数最先应用），开发者应注意效果数组的顺序会影响最终视觉效果

### 需求 4：Collapse 效果的 CSS 样式解析（Web 端）

**用户故事：** 作为 Web 前端开发者，我希望 Collapse 效果能被正确解析为 CSS max-height 和 overflow 属性，以便实现折叠展开动画。

#### 验收标准

1. WHEN 进入动画（entering 为 true）时，THE resolveEffectStyles SHALL 生成起始状态 max-height 为 collapsedHeight 值加 "px"
2. WHEN 进入动画（entering 为 true）时，THE resolveEffectStyles SHALL 生成目标状态 max-height 为由 Motion_Component 测量的 Content_Height（scrollHeight）加 "px"
3. WHEN 退出动画（entering 为 false）时，THE resolveEffectStyles SHALL 生成起始状态 max-height 为当前 Content_Height（scrollHeight）加 "px"
4. WHEN 退出动画（entering 为 false）时，THE resolveEffectStyles SHALL 生成目标状态 max-height 为 collapsedHeight 值加 "px"
5. THE resolveEffectStyles SHALL 在起始状态和目标状态中均设置 overflow 为 "hidden"
6. THE resolveEffectStyles SHALL 将 "max-height" 加入 transitionProperties 列表
7. THE resolveEffectStyles SHALL 不使用 "9999px" 等硬编码大值作为 max-height，而是依赖 Motion_Component 传入的实际测量高度

### 需求 5：Flip 效果预设

**用户故事：** 作为开发者，我希望通过预设名称快速使用常见的翻转动画组合，而不必手动构造效果数组。

#### 验收标准

1. THE EFFECT_PRESETS SHALL 包含 "flip-x-in" 预设，效果为绕 X 轴从 90deg 翻转到 0deg 并淡入
2. THE EFFECT_PRESETS SHALL 包含 "flip-x-out" 预设，效果为绕 X 轴从 0deg 翻转到 90deg 并淡出
3. THE EFFECT_PRESETS SHALL 包含 "flip-y-in" 预设，效果为绕 Y 轴从 90deg 翻转到 0deg 并淡入
4. THE EFFECT_PRESETS SHALL 包含 "flip-y-out" 预设，效果为绕 Y 轴从 0deg 翻转到 90deg 并淡出
5. THE Animation_Library SHALL 在 Android 端的 EffectPresets 中新增对应的 FLIP_X_IN、FLIP_X_OUT、FLIP_Y_IN、FLIP_Y_OUT 预设
6. THE Animation_Library SHALL 在 iOS 端的 EffectPresets 中新增对应的 flipXIn、flipXOut、flipYIn、flipYOut 预设

### 需求 6：Collapse 效果预设

**用户故事：** 作为开发者，我希望通过预设名称快速使用常见的折叠展开动画组合。

#### 验收标准

1. THE EFFECT_PRESETS SHALL 包含 "collapse-in" 预设，效果为从 collapsedHeight 0 展开并淡入
2. THE EFFECT_PRESETS SHALL 包含 "collapse-out" 预设，效果为折叠到 collapsedHeight 0 并淡出
3. THE Animation_Library SHALL 在 Android 端的 EffectPresets 中新增对应的 COLLAPSE_IN、COLLAPSE_OUT 预设
4. THE Animation_Library SHALL 在 iOS 端的 EffectPresets 中新增对应的 collapseIn、collapseOut 预设

### 需求 7：Flip 效果的 Android 实现

**用户故事：** 作为 Android 开发者，我希望 MotionAnimator 能正确执行 Flip 效果的 3D 翻转动画。

#### 验收标准

1. WHEN MotionAnimator 接收到 Flip 类型的 MotionEffect 时，THE MotionAnimator SHALL 使用 ObjectAnimator 对目标 View 执行旋转动画
2. WHEN Flip 的 axis 为 "y" 时，THE MotionAnimator SHALL 通过 camera.rotateY 或 View.rotationY 属性实现水平翻转
3. WHEN Flip 的 axis 为 "x" 时，THE MotionAnimator SHALL 通过 camera.rotateX 或 View.rotationX 属性实现垂直翻转
4. THE MotionAnimator SHALL 将 Flip 的 perspective 值应用为 Camera 的 z 轴距离或等效透视设置
5. THE MotionAnimator SHALL 将 Flip 的 from 和 to 值作为旋转动画的起始和目标角度

### 需求 8：Flip 效果的 iOS 实现

**用户故事：** 作为 iOS 开发者，我希望 MotionAnimator 能正确执行 Flip 效果的 3D 翻转动画。

#### 验收标准

1. WHEN MotionAnimator 接收到 flip 类型的 MotionEffect 时，THE MotionAnimator SHALL 使用 CATransform3D 或 UIView.transition 执行翻转动画
2. WHEN flip 的 axis 为 "y" 时，THE MotionAnimator SHALL 通过 CATransform3DRotate 绕 Y 轴旋转实现水平翻转
3. WHEN flip 的 axis 为 "x" 时，THE MotionAnimator SHALL 通过 CATransform3DRotate 绕 X 轴旋转实现垂直翻转
4. THE MotionAnimator SHALL 将 flip 的 perspective 值应用到 CATransform3D 的 m34 属性（值为 -1/perspective）
5. THE MotionAnimator SHALL 将 flip 的 from 和 to 值转换为弧度并作为旋转动画的起始和目标角度

### 需求 9：Collapse 效果的 Android 实现

**用户故事：** 作为 Android 开发者，我希望 MotionAnimator 能正确执行 Collapse 效果的折叠展开动画。

#### 验收标准

1. WHEN MotionAnimator 接收到 Collapse 类型的 MotionEffect 且 entering 为 true 时，THE MotionAnimator SHALL 使用 ValueAnimator 驱动目标 View 的 ViewGroup.LayoutParams.height 从 collapsedHeight 过渡到 Content_Height
2. WHEN MotionAnimator 接收到 Collapse 类型的 MotionEffect 且 entering 为 false 时，THE MotionAnimator SHALL 使用 ValueAnimator 驱动目标 View 的 ViewGroup.LayoutParams.height 从 Content_Height 过渡到 collapsedHeight
3. THE MotionAnimator SHALL 在动画开始前记录目标 View 的原始 LayoutParams（处理 WRAP_CONTENT 和 MATCH_PARENT 的情况）
4. WHEN 展开动画完成后，THE MotionAnimator SHALL 将目标 View 的 LayoutParams.height 恢复为 WRAP_CONTENT（允许内容自由伸缩）
5. WHEN 折叠动画完成后，THE MotionAnimator SHALL 将目标 View 的 LayoutParams.height 设置为 collapsedHeight 的固定值
6. WHILE 折叠或展开动画进行中，THE MotionAnimator SHALL 将目标 View 的 clipChildren 或 clipToPadding 设置为 true 以裁剪溢出内容
7. THE MotionAnimator SHALL 在动画开始前自动测量目标 View 子内容的实际高度作为 Content_Height
8. WHEN collapsedHeight 为 "auto" 时，THE MotionAnimator SHALL 使用目标 View 当前的实际测量高度作为折叠目标高度

### 需求 10：Collapse 效果的 iOS 实现

**用户故事：** 作为 iOS 开发者，我希望 MotionAnimator 能正确执行 Collapse 效果的折叠展开动画。

#### 验收标准

1. WHEN MotionAnimator 接收到 collapse 类型的 MotionEffect 且 entering 为 true 时，THE MotionAnimator SHALL 使用 UIView.animate 将目标 View 的高度约束从 collapsedHeight 过渡到 Content_Height
2. WHEN MotionAnimator 接收到 collapse 类型的 MotionEffect 且 entering 为 false 时，THE MotionAnimator SHALL 使用 UIView.animate 将目标 View 的高度约束从 Content_Height 过渡到 collapsedHeight
3. IF 目标 View 没有现成的高度约束，THEN THE MotionAnimator SHALL 动态创建一个高度约束（NSLayoutConstraint）并添加到目标 View 上
4. IF 目标 View 已有高度约束，THEN THE MotionAnimator SHALL 直接修改该约束的 constant 值
5. WHEN 动画结束后，THE MotionAnimator SHALL 根据配置决定是否移除动态创建的高度约束（展开完成后移除约束以允许内容自由伸缩，折叠完成后保留约束以维持折叠状态）
6. IF 动态创建的高度约束与 View 上已有的其他约束产生冲突，THEN THE MotionAnimator SHALL 将动态创建的约束优先级设置为 UILayoutPriority.required - 1（999）以避免约束冲突
7. WHILE 折叠或展开动画进行中，THE MotionAnimator SHALL 将目标 View 的 clipsToBounds 设置为 true
8. THE MotionAnimator SHALL 在动画开始前自动测量目标 View 子内容的实际高度（通过 systemLayoutSizeFitting 或 sizeToFit）作为 Content_Height
9. WHEN collapsedHeight 为 "auto" 时，THE MotionAnimator SHALL 使用目标 View 当前的实际高度作为折叠目标高度

### 需求 11：Collapse 组件的 Web 端内容高度自动测量

**用户故事：** 作为 Web 前端开发者，我希望 Collapse 效果能自动测量子内容的实际高度，而不需要我手动指定目标高度。

#### 验收标准

1. WHEN Motion_Component 渲染包含 CollapseEffect 的效果时，THE Motion_Component SHALL 在动画开始前通过 DOM API（scrollHeight）测量子内容的实际高度作为 Content_Height
2. WHEN 展开动画触发时（entering 为 true），THE Motion_Component SHALL 将 max-height 从 collapsedHeight 过渡到测量的 Content_Height（scrollHeight + "px"）
3. WHEN 展开动画完成后，THE Motion_Component SHALL 将 max-height 设置为 "none" 以允许内容自由伸缩
4. WHEN 折叠动画触发前（entering 为 false），THE Motion_Component SHALL 先将 max-height 从 "none" 设置为当前 Content_Height（scrollHeight + "px"），然后过渡到 collapsedHeight + "px"
5. THE Motion_Component SHALL 使用 ResizeObserver 监听子内容高度变化
6. WHEN expanded=false 且内容高度变化时，THE Motion_Component SHALL 重新测量新的 scrollHeight 并更新内部记录的 contentHeight，但不改变当前的 max-height（仍为 collapsedHeight）
7. WHEN 下次展开时，THE Motion_Component SHALL 使用最新的 contentHeight 作为目标高度

### 需求 12：效果冲突检测与警告

**用户故事：** 作为开发者，我希望在错误地组合了互斥效果时能收到明确的警告，以便及时修正配置。

#### 验收标准

1. WHEN FlipEffect 和 RotateEffect 同时出现在同一个效果数组中时，THE Animation_Library SHALL 在运行时通过 console.warn 输出警告信息，说明 FlipEffect 和 RotateEffect 不能同时使用
2. WHEN FlipEffect 和 RotateEffect 同时出现在同一个效果数组中时，THE Animation_Library SHALL 优先执行 FlipEffect，忽略 RotateEffect
3. THE Animation_Library SHALL 在 Web 端（resolveEffectStyles）、Android 端（MotionAnimator）和 iOS 端（MotionAnimator）均实现 FlipEffect 与 RotateEffect 的冲突检测逻辑
4. THE Animation_Library SHALL 在冲突警告信息中包含具体的冲突效果名称，格式为："[Animation_Library] FlipEffect and RotateEffect cannot be used together. RotateEffect will be ignored."
5. THE Animation_Library SHALL 在预设展开后进行冲突检测（即先将预设名称解析为效果数组，再检测冲突）

### 需求 13：Flip 和 Collapse 效果与现有效果的组合

**用户故事：** 作为开发者，我希望 Flip 和 Collapse 效果能与现有的 fade 效果组合使用，实现更丰富的动画效果。

#### 验收标准

1. WHEN FlipEffect 与 FadeEffect 同时出现在效果数组中时，THE Animation_Library SHALL 同时执行翻转和透明度过渡动画
2. WHEN CollapseEffect 与 FadeEffect 同时出现在效果数组中时，THE Animation_Library SHALL 同时执行折叠/展开和透明度过渡动画
3. THE Animation_Library SHALL 支持在四个平台（React、Vue、Android、iOS）上执行 Flip 与 fade 的组合效果
4. THE Animation_Library SHALL 支持在四个平台（React、Vue、Android、iOS）上执行 Collapse 与 fade 的组合效果
5. WHEN FlipEffect 与 RotateEffect 同时出现在效果数组中时，THE Animation_Library SHALL 按照需求 12 的冲突规则处理（FlipEffect 优先，RotateEffect 被忽略）

### 需求 14：自定义 Duration、Delay、Easing

**用户故事：** 作为开发者，我希望为 Flip 和 Collapse 效果自定义动画时长、延迟和缓动函数。

#### 验收标准

1. WHEN Duration 属性被传入时，THE Animation_Library SHALL 将 Flip 或 Collapse 效果的动画时长设置为传入值
2. WHEN Delay 属性被传入时，THE Animation_Library SHALL 将 Flip 或 Collapse 效果的动画延迟设置为传入值
3. WHEN Easing 属性被传入时，THE Animation_Library SHALL 将 Flip 或 Collapse 效果的缓动函数设置为传入值
4. WHEN Preset_Speed 被传入时，THE Animation_Library SHALL 根据预设速度方案（fast/normal/slow）设置 Flip 或 Collapse 效果的 Duration
5. THE Animation_Library SHALL 对 Flip 和 Collapse 效果使用与现有效果相同的默认 Duration（300ms）、Delay（0ms）和 Easing（"ease"）

### 需求 15：无障碍访问 - 减少动态效果

**用户故事：** 作为对动画敏感的用户，我希望当操作系统开启"减少动态效果"时，Flip 和 Collapse 动画被自动跳过或大幅缩短。

#### 验收标准

1. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 将 Flip 效果的 Duration 设置为 0ms 以跳过动画，直接显示目标状态
2. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 将 Collapse 效果的 Duration 设置为 0ms 以跳过动画，直接显示展开或折叠状态
3. WHILE 用户操作系统启用了 Reduced_Motion 偏好时，THE Animation_Library SHALL 仍然调用 onAnimationEnd_Callback（如果已传入）
4. THE Animation_Library SHALL 在 Web 端通过 prefers-reduced-motion 媒体查询检测用户偏好
5. THE Animation_Library SHALL 在 Android 端通过 Settings.Global.ANIMATOR_DURATION_SCALE 检测用户偏好
6. THE Animation_Library SHALL 在 iOS 端通过 UIAccessibility.isReduceMotionEnabled 检测用户偏好

### 需求 16：动画结束回调

**用户故事：** 作为开发者，我希望在 Flip 或 Collapse 动画播放结束后执行自定义逻辑。

#### 验收标准

1. WHEN Flip 动画过渡完成时，THE Animation_Library SHALL 调用 onAnimationEnd_Callback（如果已传入）
2. WHEN Collapse 动画过渡完成时，THE Animation_Library SHALL 调用 onAnimationEnd_Callback（如果已传入）
3. THE Animation_Library SHALL 确保 onAnimationEnd_Callback 在每次动画完成时仅被调用一次
4. WHEN 动画被 Reduced_Motion 跳过时，THE Animation_Library SHALL 仍然调用 onAnimationEnd_Callback

### 需求 17：Flip 效果的背面可见性控制

**用户故事：** 作为开发者，我希望控制 3D 翻转时元素背面的可见性，以实现卡片正反面切换效果。

#### 验收标准

1. THE FlipEffect SHALL 包含可选的 backfaceVisibility 属性，类型为 "visible" | "hidden"，默认值为 "hidden"
2. WHEN backfaceVisibility 为 "hidden" 时，THE resolveEffectStyles SHALL 在样式中设置 backface-visibility: hidden
3. THE Android MotionAnimator SHALL 通过 Camera 的 setVisibility 或等效方式控制背面可见性
4. THE iOS MotionAnimator SHALL 通过 CALayer 的 isDoubleSided 属性控制背面可见性

### 需求 18：嵌套 Collapse 动画的行为定义

**用户故事：** 作为开发者，我希望在嵌套使用 Collapse 组件时，内外层的折叠展开行为有明确的定义。

#### 验收标准

1. WHEN 外层 Collapse 执行折叠动画时，THE Animation_Library SHALL 同时折叠内层 Collapse（保持内层的 expanded 状态逻辑不变）
2. WHEN 外层 Collapse 执行展开动画时，THE Animation_Library SHALL 同时展开内层 Collapse（根据内层各自的 expanded 状态）
3. THE Animation_Library SHALL 确保嵌套 Collapse 的动画时长与最外层同步，避免出现高度跳变
4. THE Animation_Library MAY 提供 independentNestedCollapse 配置项，允许开发者选择内层是否独立控制

### 需求 19：Flip 效果的状态化语义

**用户故事：** 作为开发者，我希望通过简单的布尔值控制翻转状态，而不必每次手动指定角度。

#### 验收标准

1. THE FlipEffect SHALL 支持使用 flipped 布尔属性替代 from/to 角度对
2. WHEN flipped 为 true 时，THE Animation_Library SHALL 自动将角度从 0 过渡到 180
3. WHEN flipped 为 false 时，THE Animation_Library SHALL 自动将角度从 180 过渡到 0
4. WHEN from/to 和 flipped 同时存在时，THE Animation_Library SHALL 优先使用 from/to 值

### 需求 20：Collapse 组件的初始渲染行为

**用户故事：** 作为开发者，我希望 Collapse 组件在首次渲染时能正确显示初始状态，而不是播放一次动画。

#### 验收标准

1. WHEN Motion_Component 首次渲染且包含 CollapseEffect 且 expanded 为 false 时，THE Motion_Component SHALL 直接设置 max-height 为 collapsedHeight，不播放动画
2. WHEN Motion_Component 首次渲染且包含 CollapseEffect 且 expanded 为 true 时，THE Motion_Component SHALL 直接设置 max-height 为 none，不播放动画
3. THE Animation_Library SHALL 支持 initialExpand 配置项，允许开发者覆盖默认行为（即首次渲染时播放展开动画）
4. THE React 端 SHALL 通过 useRef 标记首次渲染来跳过初始动画
5. THE Vue 端 SHALL 通过 onMounted 标记首次渲染来跳过初始动画
6. THE 原生端（Android/iOS）SHALL 通过构造函数参数或初始化方法控制首次渲染行为

### 需求 21：Easing 函数的跨平台映射

**用户故事：** 作为跨平台开发者，我希望使用统一的缓动函数名称，在各平台上获得一致的动画效果。

#### 验收标准

1. THE Animation_Library SHALL 提供一套统一的 Easing 枚举类型（linear、ease、easeIn、easeOut、easeInOut、spring）
2. THE Web 端 SHALL 将统一 Easing 映射为对应的 CSS transition-timing-function 值
3. THE Android 端 SHALL 将统一 Easing 映射为对应的 TimeInterpolator 实现
4. THE iOS 端 SHALL 将统一 Easing 映射为对应的 CAMediaTimingFunction 或 UIView.AnimationOptions
5. THE Animation_Library MAY 支持自定义 cubic-bezier 参数，并在各平台解析为对应的缓动实现
6. THE spring easing SHALL 为可选实现，各平台使用近似方案：Web 端使用 cubic-bezier(0.4, 0.14, 0.3, 1)，Android 端使用 OvershootInterpolator，iOS 端使用 UISpringTimingParameters 或 .curveEaseOut + damping
7. THE Animation_Library MAY 提供参数化 spring 配置（stiffness, damping）供高级用户使用

### 需求 22：性能与内存约束

**用户故事：** 作为开发者，我希望 Flip 和 Collapse 动画在各平台上流畅运行，不会导致性能问题或内存泄漏。

#### 验收标准

1. WHEN 应用 Flip 效果时，THE Animation_Library SHALL 确保动画在 60fps 下流畅运行，单次动画掉帧率不超过 5%
2. WHEN 应用 Collapse 效果时，THE Animation_Library SHALL 避免在动画每一帧中触发完整的布局重计算
3. THE Animation_Library SHALL 在动画结束后及时释放不再使用的动画资源（如 ObjectAnimator、CADisplayLink 等）
4. THE Animation_Library SHALL 在组件卸载时取消所有进行中的动画，避免内存泄漏

### 需求 23：测试覆盖要求

**用户故事：** 作为开发者，我希望 Flip 和 Collapse 效果有充分的测试覆盖，确保各平台行为一致。

#### 验收标准

1. THE Animation_Library SHALL 为 FlipEffect 和 CollapseEffect 的类型定义提供单元测试，覆盖所有可选属性的默认值
2. THE Animation_Library SHALL 为 resolveEffectStyles 提供快照测试，覆盖所有 FlipEffect 和 CollapseEffect 的参数组合
3. THE Animation_Library SHALL 为 EFFECT_PRESETS 中的新增预设提供验证测试
4. THE Animation_Library SHALL 在 React 和 Vue 端提供组件集成测试，验证 Flip/Collapse 动画的完整生命周期
5. THE Animation_Library SHALL 在 Android 和 iOS 端提供 UI 测试，验证动画的视觉效果和行为

### 需求 24：效果样式解析的往返一致性

**用户故事：** 作为开发者，我希望效果参数经过解析后能准确还原为预期的 CSS 样式，确保解析逻辑的正确性。

#### 验收标准

1. FOR ALL 有效的 FlipEffect 参数组合，THE resolveEffectStyles SHALL 生成的 from 和 to 样式中包含正确的旋转角度和透视值
2. FOR ALL 有效的 CollapseEffect 参数组合，THE resolveEffectStyles SHALL 生成的 from 和 to 样式中包含正确的 max-height 和 overflow 值
3. WHEN 相同的 FlipEffect 参数被多次传入 resolveEffectStyles 时，THE resolveEffectStyles SHALL 每次返回相同的结果（幂等性）
4. WHEN 相同的 CollapseEffect 参数被多次传入 resolveEffectStyles 时，THE resolveEffectStyles SHALL 每次返回相同的结果（幂等性）
