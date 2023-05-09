import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../components/login.dart';
import '../components/status.dart';
import '../providers/user.dart';
import '../utils/platform_util.dart';
import './setting.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('深澜校园网自动认证'),
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.65,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingPage(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        body: Center(
          child: Selector<UserProvider, bool>(
            builder: (context, value, child) => value ? const Status() : Login(),
            selector: (p0, p1) => p1.isLogin,
          ),
        ),
      ),
    );
  }

  Widget layout({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return PlatformUtils.isAndroid
        ? Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          )
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
  }
}
