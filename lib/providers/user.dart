import 'package:flutter/material.dart';

import '../config.dart';
import '../srun/result.dart';
import '../srun/srun.dart';
import '../utils/utils.dart';

class UserProvider extends ChangeNotifier {
  String _url = '';
  String get url => _url;

  bool _isLogin = false;
  bool get isLogin => _isLogin;

  set isLogin(bool e) {
    _isLogin = e;
    notifyListeners();
  }

  late SRun srun;
  String ip = '';
  String _loginStatus = '';
  String get loginStatus => _loginStatus;

  set loginStatus(String e) {
    _loginStatus = e;
    notifyListeners();
  }

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
    Utils.storage.setBool('autoLogin', e);
    notifyListeners();
  }

  set autoLogin0(bool e) {
    _autoLogin = e;
  }

  Map<String, Object> _portal = {};

  Map<String, Object> get portal => _portal;
  set portal(Map<String, Object> e) {
    _portal = e;
    notifyListeners();
  }

  set portal0(Map<String, Object> e) {
    _portal = e;
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
