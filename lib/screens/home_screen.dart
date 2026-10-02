import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'url_input_screen.dart';
import 'webview_screen.dart';

/// 入口路由：决定直接打开网页，还是先让用户输入网址。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _prefsKey = 'target_url';

  String? _targetUrl;

  @override
  void initState() {
    super.initState();
    _resolveTarget();
  }

  Future<void> _resolveTarget() async {
    // 1. 构建时已注入网址 → 直接使用。
    if (AppConfig.appUrl.isNotEmpty) {
      _setTarget(AppConfig.appUrl);
      return;
    }

    // 2. 否则读取上次保存的网址。
    final prefs = await SharedPreferences.getInstance();
    _setTarget(prefs.getString(_prefsKey) ?? '');
  }

  void _setTarget(String url) {
    if (!mounted) return;
    setState(() => _targetUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    // 正在读取配置时显示纯白启动页。
    if (_targetUrl == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 有网址 → 直接进入全屏网页。
    if (_targetUrl!.isNotEmpty) {
      return WebViewScreen(url: _targetUrl!);
    }

    // 没有网址 → 显示输入页。
    return UrlInputScreen(
      onSubmitted: (url) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString(_prefsKey, url);
        });
        _setTarget(url);
      },
    );
  }
}