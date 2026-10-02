# WebWrap

将任意网页封装成独立全屏安卓应用的 Flutter 模板。
Convert any webpage into a standalone fullscreen Android app.

- **全屏沉浸式**：默认隐藏状态栏和导航栏（`immersiveSticky`）
- **Chromium 内核**：基于 `flutter_inappwebview`，使用 Android System WebView（Chromium 引擎，随 Play 商店自动更新）
- **无需本地构建环境**：源码上传 GitHub 后，通过 Actions 手动触发即可构建 APK

## 使用方式

1. 把这个仓库 fork / push 到你的 GitHub 账号
2. 打开仓库 → **Actions** → **Build APK** → **Run workflow**
3. 输入要转换的网页地址（`target_url`）和**应用包名**（`package_name`），点击 **Run workflow**
4. 等待构建完成（第一次约 3~5 分钟，之后约 1~2 分钟，详见下方「构建加速」）
5. 在 **Artifacts** 中下载 `webwrap-release-apk`，解压后安装 `app-release.apk`

> 也可以直接在 Actions 页面修改 `target_url` 和 `package_name`，随时重新构建。

### 包名规则

`package_name` 即安卓的 `applicationId`（应用唯一标识），必须满足：

- 至少两段，用 `.` 分隔，例如 `com.example.app`
- 每段以字母开头，只能包含字母、数字和下划线（不能包含 `-` 或其他符号）
- 合法示例：`com.example.app`、`io.github.myapp`
- 非法示例：`123abc`、`com.example-app`、`com.example.app-v2`

> 输入非法包名时，工作流会在**构建开始前直接中止**并提示错误，不会浪费构建时间。

### 固定签名

项目内置了**固定的发布签名**（`overlay/android/app/upload-keystore.p12`，PKCS12，构建时自动复制到 `android/app/` 并配置到 release 签名）。

- 每次构建使用同一个签名密钥，因此 **APK 可以覆盖安装升级**（签名一致），不会出现「已安装应用签名不一致」的问题
- 默认签名密钥信息（别名 `webwrap`，密码 `webwrap123`）已随仓库提交，方便直接使用

> ⚠️ **安全提醒**：该密钥是公开在仓库里的，仅适合个人/测试用途。如果要发布到应用商店，请**替换为你自己的签名密钥**（用 `keytool -genkeypair` 生成 PKCS12 文件并替换 `overlay/android/app/upload-keystore.p12`，同时更新工作流中对应的密码/别名）。

## 构建加速

项目内置了多层 GitHub Actions 缓存，**同一仓库的第二次及以后构建会显著加快**：

| 缓存项 | 工具 | 说明 |
|--------|------|------|
| Flutter SDK 缓存 | `subosito/flutter-action` | 缓存 Flutter 3.24.3 SDK 本体 |
| Pub 依赖缓存 | `subosito/flutter-action` | 缓存 `~/.pub-cache`，`flutter pub get` 秒级完成 |
| Gradle 发行版缓存 | `actions/cache` | 缓存 Gradle 8.3 发行版，免去重复下载 |
| Gradle 依赖缓存 | `actions/cache` | 缓存 `~/.gradle/caches`（AGP / Kotlin / AndroidX 等） |
| Gradle 构建缓存 | `org.gradle.caching=true` | 复用上次构建产物，只重编变化部分 |
| Gradle 并行构建 | `org.gradle.parallel=true` | 多模块并行编译 |

- **第一次触发（冷缓存）**：约 3~5 分钟，需要下载 Flutter SDK、Gradle 发行版和全部依赖
- **之后触发（热缓存）**：通常 1~2 分钟内完成

> 缓存由 GitHub Actions 自动管理（默认保留 7 天，命中后自动续期）。
> 如需手动清除缓存：仓库 → **Settings** → **Actions** → **Caches** → 删除对应缓存项，下一次构建即恢复冷缓存。

## 特性

| 功能 | 实现 |
|------|------|
| 全屏无状态栏 | `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` + 全屏主题 |
| Chromium 内核 | Android System WebView（随系统更新） |
| JavaScript / DOM / 媒体 | 默认开启，支持视频内联播放、地理位置、混合内容 |
| 返回键 | 优先返回上一页，无法返回时退出应用 |
| 下拉刷新 | 支持 |
| 加载失败重试 | 主框架加载失败时显示重试按钮 |
| 支持 HTTP | `usesCleartextTraffic="true"` |

构建时通过 `--dart-define=APP_URL=...` 注入网址；如果为空，应用首次启动会让用户输入网址并记住（`shared_preferences`）。

## 修改应用名称 / 包名

- **应用名**：修改 `android/app/src/main/AndroidManifest.xml` 中的 `android:label`（当前为 `WebWrap`）
- **包名**：直接在 GitHub Actions 的 `package_name` 输入框中填写，构建时会自动写入 `android/app/build.gradle` 的 `applicationId`
- **签名**：默认使用仓库内置的 `overlay/android/app/upload-keystore.p12`，如需更换见上方「固定签名」

## 本地运行（可选）

需要已安装 Flutter SDK（本项目在 CI 中构建，本地无需安装）：

```bash
flutter pub get
flutter build apk --release --dart-define=APP_URL=https://example.com
```

## 为什么选 flutter_inappwebview

- `flutter_inappwebview` 是 Flutter 生态中最完整的 WebView 方案，功能远超官方 `webview_flutter`
- Android 上它使用 **Android System WebView**——与 Chrome 同源的 Chromium 内核，由 Play 商店自动更新，兼容性和性能是安卓平台实际可用的最佳方案
- 支持混合内容、媒体播放、DOM 存储、下拉刷新、文件上传等完整能力

## License

MIT