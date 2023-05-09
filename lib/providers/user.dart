import 'package:flutter/material.dart';

import '../config.dart';
import '../srun/result.dart';
import '../srun/srun.dart';
import '../utils/utils.dart';

class UserProvider extends ChangeNotifier {
  String _url = '';
  String get url => _url;

  bool isLogin = false;
  late SRun srun;
  String ip = '';

  Result? _result;
  Result? get result => _result;

  set result(Result? e) {
    _result = e;
    ip = e!.clientIp;
    notifyListeners();
  }

  set url(String s) {
    _url = s;
    notifyListeners();
  }

  set url0(String s) {
    _url = s;
  }

  String _username = '';
  String get username => _username;
  set username(String s) {
    _username = s;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String s) {
    _password = s;
    notifyListeners();
  }

  bool _autoLogin = false;
  bool get autoLogin => _autoLogin;

  set autoLogin(bool e) {
    _autoLogin = e;
    notifyListeners();
  }

  set autoLogin0(bool e) {
    _autoLogin = e;
  }

  Map<String, Object> get portal => Config.portal;
  set portal(Map<String, Object> e) {
    Config.portal = e;
    notifyListeners();
  }

  Future saveAccount() async {
    await Utils.storage.setString('username', _username);
    await Utils.storage.setString('password', _password);
  }

  loadAccount() {
    _username = Utils.storage.getString('username') ?? '';
    _password = Utils.storage.getString('password') ?? '';
  }
}
