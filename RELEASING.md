# 发布指南（Releasing）

三端（Web / Android / iOS）版本号统一，当前 **0.3.0**。发布是**高影响、不可逆**操作，务必按下列步骤在确认凭证后手动执行。

## 0. 发布前检查清单

```bash
# 全端测试必须绿
npx vitest run                                   # Web（根目录，jsdom）
cd packages/android && ./gradlew clean test      # Android（需 unset JAVA_HOME）
cd packages/ios && xcodebuild -scheme FadeAnimation -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' test   # iOS
```

- [ ] 三端测试全绿、CI 三端 job success
- [ ] `CHANGELOG.md` 已更新本版本条目
- [ ] 三端版本号一致（见下）
- [ ] `contract/motion-contract.json` 未变更或三端契约测试已同步

## 1. 版本号位置（改版本时全部同步）

| 端 | 文件 | 字段 |
|----|------|------|
| core | `packages/core/package.json` | `version` |
| react | `packages/react/package.json` | `version` |
| vue | `packages/vue/package.json` | `version` |
| Android | `packages/android/build.gradle.kts` | `version = "…"` |
| iOS | Git tag（SwiftPM 用 tag 作版本，`Package.swift` 无版本字段） | `vX.Y.Z` |

## 2. Web —— npm 发布（@fade-animation/*）

包为 pnpm workspace，`@fade-animation/react|vue` 依赖 `@fade-animation/core: workspace:*`。
发布时 pnpm 会自动把 `workspace:*` 替换为已发布的真实版本，因此**必须先发 core**。

```bash
# 构建
pnpm -r --filter "./packages/core" --filter "./packages/react" --filter "./packages/vue" build

# 登录（需 npm 账号 + 对 @fade-animation scope 的发布权限）
npm whoami || npm login

# 按依赖顺序发布（--access public 因为是 scoped 包）
cd packages/core  && npm publish --access public
cd ../react       && npm publish --access public
cd ../vue         && npm publish --access public
```

> 若使用 pnpm：`pnpm publish --access public --no-git-checks`（同样先 core）。

## 3. Android —— Maven 发布

`build.gradle.kts` 已配 `maven-publish`，坐标 `com.fadeanimation:fade-animation-android:0.3.0`。

```bash
cd packages/android
unset JAVA_HOME

# 本地验证（发到 ~/.m2 或 build/maven-repo）
./gradlew publishToMavenLocal
./gradlew publishMavenPublicationToLocalDirRepository   # → build/maven-repo

# 发到 Maven Central / 私有仓库：需先在 build.gradle.kts 的 publishing.repositories
# 增加带凭证的远程仓库（sonatype/nexus），并配置签名(signing 插件)后：
# ./gradlew publish
```

> 发 Maven Central 还需：GROUP 的 namespace 验证、GPG 签名、sources+javadoc jar（已启用 `withSourcesJar()`）。

## 4. iOS —— SwiftPM（Git tag 即发布）

SwiftPM 通过 Git tag 分发，无需上传制品：

```bash
git tag v0.3.0
git push origin v0.3.0
```

消费方：`.package(url: "https://github.com/<org>/fade-animation-ios", from: "0.3.0")`。
（当前为 monorepo；若要独立分发 iOS，需将 `packages/ios` 拆到独立仓库或用 subtree。）

## 5. 打统一 tag & GitHub Release

```bash
git tag v0.3.0        # 若上一步未打
git push origin v0.3.0
# 在 GitHub 用 CHANGELOG 的本版本段落创建 Release
```

## 回滚

- npm：`npm deprecate <pkg>@0.3.0 "…"`（不能删已发布版本，只能废弃 / 发补丁版）。
- Maven Central：已发布版本不可删除，只能发新版本。
- SwiftPM：删除 tag `git push origin :refs/tags/v0.3.0`（消费方若已锁定则不受影响）。

因此**发布前务必确认无误**——已发布版本基本不可逆。
