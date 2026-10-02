/// 全局配置。
///
/// 构建时通过 `--dart-define=APP_URL=...` 注入目标网址；
/// 如果未注入（为空），应用会在首次启动时让用户输入网址。
class AppConfig {
  const AppConfig._();

  /// 构建时注入的目标网页地址。
  static const String appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: '',
  );

  /// 是否需要显示网址输入页。
  static bool get needsUrlInput => appUrl.isEmpty;
}