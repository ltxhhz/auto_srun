import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../utils/utils.dart';
import '../providers/user.dart';
import '../config.dart';
import '../srun/srun.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>();
    final urlController = TextEditingController();
    final url = Utils.storage.getString('url') ?? '';
    user.url0 = urlController.text = url;
    if (url.isNotEmpty) {
      try {
        Config.portal = Map.from(jsonDecode(Utils.storage.getString('portal')!));
      } catch (e) {
        Utils.logger.e(e);
      }
    }
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    user.loadAccount();
    usernameController.text = user.username;
    passwordController.text = user.password;
    user.autoLogin0 = Utils.storage.getBool('autoLogin') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (user.autoLogin && user.username.isNotEmpty && user.password.isNotEmpty) {
        login(user, url);
      }
    });
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Selector<UserProvider, String>(
            builder: (context, value, child) => TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: '登录网址',
                hintText: '连接wifi时自动弹出的页面的地址',
                suffixIcon: GestureDetector(
                  onTap: () {
                    user.url = '';
                    urlController.clear();
                  },
                  child: Offstage(
                    offstage: value.isEmpty,
                    child: const Icon(Icons.cancel),
                  ),
                ),
              ),
              onChanged: (value) {
                user.url = value;
              },
            ),
            selector: (p0, p1) => p1.url,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Selector<UserProvider, bool>(
              builder: (context, value, child) => ElevatedButton(
                onPressed: value
                    ? () {
                        final hide = BotToast.showLoading();
                        final dio = Dio(BaseOptions(
                          connectTimeout: const Duration(seconds: 3),
                          sendTimeout: const Duration(seconds: 3),
                          receiveTimeout: const Duration(seconds: 3),
                        ));
                        dio.get(user.url).then((value) {
                          hide();
                          final str = RegExp(r'portal\s*=(.+);').firstMatch(value.data)?.group(1);
                          if (str == null) {
                            Utils.showToast('获取失败');
                          } else {
                            try {
                              final json = Map<String, Object>.from(jsonDecode(str));
                              Utils.logger.i(json);
                              user.portal = json;
                              Utils.showToast('获取成功');
                              Utils.storage.setString('portal', str).then((value) {
                                Utils.logger.i('保存 portal $value');
                              });
                              Utils.storage.setString('url', user.url);
                            } catch (e) {
                              Utils.showToast('获取失败');
                            }
                          }
                          Utils.logger.i(str);
                        }).catchError((err) {
                          hide();
                          Utils.logger.i(err);
                          Utils.showToast('获取失败 ${err?.message}');
                        });
                      }
                    : null,
                child: Selector<UserProvider, bool>(
                  builder: (context, value, child) => Text(value ? '获取配置' : '重新获取'),
                  selector: (p0, p1) => p1.portal.isEmpty,
                ),
              ),
              selector: (p0, p1) => p1.url.isNotEmpty,
            ),
          ),
          const Divider(),
          Selector<UserProvider, String>(
            builder: (context, value, child) => TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: '用户名',
                suffixIcon: GestureDetector(
                  onTap: () {
                    user.username = '';
                    usernameController.clear();
                  },
                  child: Offstage(
                    offstage: value.isEmpty,
                    child: const Icon(Icons.cancel),
                  ),
                ),
              ),
              onChanged: (value) {
                user.username = value;
              },
            ),
            selector: (p0, p1) => p1.username,
          ),
          Selector<UserProvider, String>(
            builder: (context, value, child) => TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                suffixIcon: GestureDetector(
                  onTap: () {
                    user.password = '';
                    passwordController.clear();
                  },
                  child: Offstage(
                    offstage: value.isEmpty,
                    child: const Icon(Icons.cancel),
                  ),
                ),
              ),
              obscureText: true,
              onChanged: (value) {
                user.password = value;
              },
            ),
            selector: (p0, p1) => p1.password,
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Selector<UserProvider, Tuple3<String, String, bool>>(
                builder: (context, value, child) => ElevatedButton(
                  onPressed: value.item1.isNotEmpty && value.item2.isNotEmpty && value.item3
                      ? () {
                          login(user, url);
                        }
                      : null,
                  child: const Text('登录'),
                ),
                selector: (p0, p1) => Tuple3(p1.username, p1.password, p1.portal.isNotEmpty),
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('自动登录'),
              Selector<UserProvider, bool>(
                builder: (context, value, child) => Checkbox(
                  value: value,
                  onChanged: (v) {
                    user.autoLogin = v!;
                  },
                ),
                selector: (p0, p1) => p1.autoLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }

  login(UserProvider user, String url) {
    final hide = BotToast.showLoading();
    final uri = Uri.parse(url);
    user.srun = SRun(user.username, user.password, ac_id: uri.queryParameters['ac_id'] ?? '4')
      ..login().then((value) {
        hide();
        if (value.isSuccess) {
          user.isLogin = true;
          user.result = value;
          user.saveAccount();
        } else {
          Utils.showToast(value.message);
        }
      });
  }
}
