# WebWrap

将任意网页封装成独立全屏安卓应用的 Flutter 模板。
Convert any webpage into a standalone fullscreen Android app.

- **全屏沉浸式**：默认隐藏状态栏和导航栏（`immersiveSticky`）
- **Chromium 内核**：基于 `flutter_inappwebview`，使用 Android System WebView（Chromium 引擎，随 Play 商店自动更新）
- **无需本地构建环境**：源码上传 GitHub 后，通过 Actions 手动触发即可构建 APK

## 使用方式

1. 把这个仓库 fork / push 到你的 GitHub 账号
2. 打开仓库 → **Actions** → **Build APK** → **Run workflow**
3. 输入要转换的网页地址（`target_url`），点击 **Run workflow**
4. 等待构建完成（约 5~10 分钟）
5. 在 **Artifacts** 中下载 `webwrap-release-apk`，解压后安装 `app-release.apk`

> 也可以直接在 Actions 页面把 `target_url` 改成你自己的网址，随时重新构建。

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

- **应用名**：修改 `android/app/src/main/AndroidManifest.xml` 中的 `android:label`（当前为 `WebWrap`），或在 `android/app/build.gradle.kts` 的 `manifestPlaceholders["appName"]` 中修改
- **包名**：修改 `android/app/build.gradle.kts` 中的 `applicationId` 和 `namespace`，以及 `MainActivity.kt` 的包路径

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