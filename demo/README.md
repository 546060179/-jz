# Kinetic UI 双端 Demo

在 iOS 和 Android 真机上体验所有 22 种预设动效。

## 动效清单

| 分类 | 效果 | 说明 |
|------|------|------|
| 过渡 | fade-in / fade-out | 基础淡入淡出 |
| 过渡 | scale-fade-in / out | 缩放 + 淡入 |
| 过渡 | blur-fade-in / out | 模糊 + 淡入 |
| 滑动 | slide-up-in | 从下方滑入 |
| 滑动 | slide-down-out | 向下滑出 |
| 滑动 | slide-left-in | 从左侧滑入 |
| 滑动 | slide-right-in | 从右侧滑入 |
| 旋转 | rotate-fade-in / out | 旋转 + 淡入 |
| 翻转 | flip-x-in / out | 绕 X 轴 3D 翻转 |
| 翻转 | flip-y-in / out | 绕 Y 轴 3D 翻转 |
| 折叠 | collapse-in / out | 高度折叠展开 |
| 弹性 | bounce-in | 过冲回弹缩放进入 |
| 缩放 | zoom-in / zoom-slide-in | 缩放 / 缩放上滑进入 |
| 旋转 | spin-in | 旋转半圈进入 |

---

## iOS Demo

### 环境要求
- Xcode 15+
- iOS 15+ 设备或模拟器

### 运行方式

```bash
cd demo/ios
open Package.swift
```

Xcode 打开后：
1. 选择 target `KineticUIDemo`
2. 选择 iOS Simulator 或连接的真机
3. ⌘R 运行

> 📝 Demo 内嵌了轻量版动画引擎（DemoAnimator），不依赖外部库，可直接编译。

---

## Android Demo

### 环境要求
- Android Studio Hedgehog (2023.1.1)+
- Android SDK 34
- JDK 17
- 真机 API 24+ 或模拟器

### 运行方式

```bash
cd demo/android
# 用 Android Studio 打开此目录
```

或命令行构建：

```bash
cd demo/android
./gradlew :app:assembleDebug
adb install app/build/outputs/apk/debug/app-debug.apk
```

> 📝 Android Demo 通过 `sourceSets` 直接编译 `packages/android/src/main/kotlin` 源码，
> 无需单独构建库模块，确保源码同步更新即可看到最新效果。

---

## 结构

```
demo/
├── README.md
├── ios/
│   ├── Package.swift
│   └── Sources/
│       ├── AppDelegate.swift
│       ├── MotionGalleryViewController.swift
│       └── FadeAnimation/
│           ├── MotionEffect.swift      (效果定义 + 预设)
│           └── DemoAnimator.swift       (轻量动画引擎)
└── android/
    ├── settings.gradle.kts
    ├── build.gradle.kts
    └── app/
        └── src/main/
            ├── AndroidManifest.xml
            ├── kotlin/com/kineticui/demo/
            │   ├── MotionGalleryActivity.kt
            │   ├── EffectDetailActivity.kt
            │   ├── EffectCatalog.kt
            │   └── EffectDemoItem.kt
            └── res/
                ├── layout/
                ├── drawable/
                └── values/
```
