import 'package:auto_srun/utils/platform_util.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import './pages/home.dart';
import './utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Utils.init();
  if (PlatformUtils.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: '深澜认证',
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '深澜认证',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      builder: BotToastInit(), //1.调用BotToastInit
      navigatorObservers: [
        BotToastNavigatorObserver()
      ], //2.注册路由观察者
      home: const HomePage(),
    );
  }
}
