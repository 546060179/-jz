# Kinetic UI — Android Demo（自包含）

在别的电脑上运行本 demo，查看 22 种预设动效 + 5 个预置业务组件在 Android 上的表现。

## 前置条件
- 安装 **Android Studio**（自带 Android SDK；首次运行需联网下载 Gradle 8.5 与依赖）
- 一台 Android 真机（开启 USB 调试）或一个 AVD 模拟器

## 方式一：Android Studio（推荐）
1. 解压后，Android Studio 选择 **Open**，打开 `android` 目录（含 `settings.gradle.kts` 的那一层）
2. 等待 Gradle Sync 完成（Android Studio 会自动生成指向本机 SDK 的 `local.properties`）
3. 连接真机或启动模拟器，点 **Run ▶**

## 方式二：命令行
```bash
cd android
# 若未设置 ANDROID_HOME，先创建 local.properties 指向本机 SDK：
echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties   # macOS 示例
./gradlew installDebug        # 安装到已连接的设备/模拟器
```

## 说明
- **自包含**：动效库源码已内置于 `app/src/main/kotlin/com/fadeanimation/`，无需依赖仓库其它目录。
- 主页 `MotionGalleryActivity` 列出全部预设，点击任意项进入详情页，点「播放」触发进入动画、结束后自动反向播放退出动画。
- `Bounce In` 使用 `EasingCurves.BOUNCE` 过冲缓动；`Spin In` 使用 `EasingCurves.EXPRESSIVE`。
- 「预置业务组件 Components」分区展示 5 个自定义 View 组件：Bubble Expand（气泡展开）、Continue Watching（最近播放浮层 5 阶段序列）、Toast、Notification Banner、Spotlight Overlay（聚光灯引导），进入详情页自动播放，可点「播放」重播。与 iOS/Web 端同款参数。
- Blur Fade In 已更新为"由糊变清"（初始 0.6 透明度 + 14px 模糊），与纯淡入区分。
- 应用 id：`com.kineticui.demo`，minSdk 24，targetSdk/compileSdk 34。
