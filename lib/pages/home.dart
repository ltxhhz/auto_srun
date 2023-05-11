import 'dart:math';

import 'package:about/about.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/login.dart';
import '../components/status.dart';
import '../config.dart';
import '../providers/user.dart';
import '../utils/utils.dart';
import './setting.dart';

bool _checked = false;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // if (!_checked) {
    //   _checkUpdate();
    // }
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('深澜校园网自动认证'),
        ),
        drawer: Drawer(
          width: min(ScreenUtil.defaultSize.width.w * 0.65, 350),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Selector<UserProvider, Tuple2<String, int?>>(
                builder: (context, value, child) => UserAccountsDrawerHeader(accountName: Text(value.item1.isEmpty ? 'user' : value.item1), accountEmail: Text('余额 ${value.item2 ?? '未知'}')),
                selector: (p0, p1) => Tuple2(p1.username, p1.result?.wallerBalance),
              ),
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('设置'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const SettingPage(),
              //       ),
              //     );
              //   },
              // ),
              AboutPageListTile(
                icon: const Icon(Icons.info),
                values: {
                  'version': Config.packageInfo.version,
                  'year': DateTime.now().year.toString(),
                },
                applicationIcon: const SizedBox(
                  width: 100,
                  height: 100,
                  child: FlutterLogo(),
                ),
                // applicationLegalese: 'Copyright © David PHAM-VAN, {{ year }}',
                applicationDescription: const Text('本项目是一个基于 Flutter 开发的自动进行深澜网络认证的软件。可以帮助学生、教师等用户快速、方便地完成深澜认证，无需手动输入账号和密码。'),
                aboutBoxChildren: [
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('开源地址'),
                    subtitle: const Text('GitHub'),
                    onTap: () {
                      launchUrlString(
                        'https://github.com/ltxhhz/auto_srun',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('开源地址'),
                    subtitle: const Text('Gitee'),
                    onTap: () {
                      launchUrlString(
                        'https://gitee.com/ltxhhz/auto_srun',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  const MarkdownPageListTile(
                    icon: Icon(Icons.list),
                    title: Text('Changelog'),
                    filename: 'lib/assets/CHANGELOG.md',
                  ),
                  const LicensesPageListTile(
                    icon: Icon(Icons.favorite),
                    title: Text('开源许可'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('检查更新'),
                    onTap: () {
                      Utils.showToast('还没做，请到项目地址检查更新吧', true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            final widget = Selector<UserProvider, bool>(
              builder: (context, value, child) => value ? const Status() : const Login(),
              selector: (p0, p1) => p1.isLogin,
            );
            return Center(
              child: SizedBox(
                width: orientation == Orientation.landscape ? 150.w : null,
                child: widget,
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkUpdate() {
    //todo
    // Dio().get('path')
  }
}
