import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';
import './utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Utils.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '自动登录',
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
