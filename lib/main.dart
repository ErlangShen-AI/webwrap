import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 全局沉浸式全屏：隐藏状态栏和导航栏。
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const WebWrapApp());
}

class WebWrapApp extends StatelessWidget {
  const WebWrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebWrap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}