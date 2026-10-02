import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 全屏网页容器（Chromium 内核）。
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.url});

  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;

  bool _loading = true;
  double _progress = 0;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    // 再次确保沉浸式全屏。
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        _controller?.reload();
      },
    );
  }

  @override
  void dispose() {
    _pullToRefreshController?.dispose();
    super.dispose();
  }

  Future<bool> _handleBack() async {
    if (_controller == null) return false;
    final canGoBack = await _controller!.canGoBack();
    if (canGoBack) {
      _controller!.goBack();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final handled = await _handleBack();
          if (!handled) {
            // 无法后退时退出应用。
            SystemNavigator.pop();
          }
        },
        child: Stack(
          children: [
            // 核心：Android System WebView（Chromium 内核）。
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                supportZoom: false,
                useHybridComposition: true,
                cacheEnabled: true,
                transparentBackground: false,
                builtInZoomControls: false,
                displayZoomControls: false,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                allowFileAccess: true,
                allowContentAccess: true,
                geolocationEnabled: true,
              ),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100.0;
                  if (progress >= 100) _loading = false;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _loading = false;
                  _loadFailed = false;
                });
              },
              onReceivedError: (controller, request, error) {
                // 只对主框架的加载失败给出错误提示，忽略子资源错误。
                if (request.isForMainFrame == true) {
                  setState(() {
                    _loadFailed = true;
                    _loading = false;
                  });
                }
              },
            ),

            // 加载进度条（不是状态栏，仅在加载时出现）。
            if (_loading && !_loadFailed)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(value: _progress),
              ),

            // 加载失败提示。
            if (_loadFailed)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('网页加载失败，请检查网络后重试'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loadFailed = false;
                          _loading = true;
                          _progress = 0;
                        });
                        _controller?.reload();
                      },
                      child: const Text('重新加载'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}