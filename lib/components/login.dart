import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../utils/utils.dart';
import '../providers/user.dart';
import '../srun/srun.dart';

StreamSubscription<ConnectivityResult>? _subscription;
bool _isLogged = false;

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
        user.portal0 = Map.from(jsonDecode(Utils.storage.getString('portal')!));
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (user.autoLogin && user.username.isNotEmpty && user.password.isNotEmpty) {
        final connectivityResult = await (Connectivity().checkConnectivity());
        if (!_isLogged && connectivityResult != ConnectivityResult.none && connectivityResult != ConnectivityResult.mobile) {
          login(user, url).then((value) {
            if (value) {
              _isLogged = true;
            }
          });
        } else {
          user.loginStatus = '请切换为需要认证的网络';
          _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
            Utils.logger.i('状态改变 ${result.name}');
            if (result != ConnectivityResult.none && result != ConnectivityResult.mobile) {
              user.loginStatus = '';
              if (!_isLogged) {
                login(user, url).then((value) {
                  if (value) {
                    _isLogged = true;
                  }
                });
              }
            }
          });
        }
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
                      ? () async {
                          final connectivityResult = await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.none && connectivityResult != ConnectivityResult.mobile) {
                            login(user, url);
                          } else {
                            Utils.showToast('请切换为需要认证的网络');
                          }
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
          Selector<UserProvider, String>(
            builder: (context, value, child) => value.isEmpty ? const SizedBox() : Text(value),
            selector: (p0, p1) => p1.loginStatus,
          )
        ],
      ),
    );
  }

  Future<bool> login(UserProvider user, String url) {
    final hide = BotToast.showLoading();
    final uri = Uri.parse(url);
    final com = Completer<bool>();
    user.loginStatus = '登录中...';
    user.srun = SRun(user.username, user.password, ac_id: uri.queryParameters['ac_id'] ?? '4')
      ..login().then((value) {
        hide();
        if (value.isSuccess) {
          user.isLogin = true;
          user.result = value;
          user.saveAccount();
          user.loginStatus = '';
          _subscription?.cancel();
          user.loginStatus = '';
          com.complete(true);
        } else {
          user.loginStatus = '登录失败';
          Utils.showToast(value.message);
          com.complete(false);
        }
      }, onError: (err) {
        hide();
        user.loginStatus = err?.message ?? 'error';
        com.complete(false);
      });
    return com.future;
  }
}
