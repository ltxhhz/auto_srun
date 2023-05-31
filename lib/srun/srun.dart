import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

import '../utils/utils.dart';
import './x_encode.dart';
import './base64.dart' as base;
import './result.dart';

class SRun {
  late Map<String, dynamic> portal;
  String username;
  String password;
  String n;
  String type;
  String ac_id;
  String enc;
  late String getChallengeApi;
  late String srunPortalApi;

  String ip = '';
  String token = '';
  String i = '';
  String hmd5 = '';
  String chkSum = '';

  late Dio _dio;
  SRun(
    this.username,
    this.password, {
    this.n = '200',
    this.type = '1',
    this.ac_id = '4',
    this.enc = 'srun_bx1',
    Map<String, dynamic>? portal,
  }) {
    portal = portal ??
        {
          "AuthIP": "192.168.118.51",
          "AuthIP6": "2001:250:1802:f010::118:51",
          "ServiceIP": "http://portal.xjnu.edu.cn:8900",
          "DoubleStackPC": true,
          "DoubleStackMobile": true,
          "AuthMode": false,
          "CloseLogout": false,
          "MacAuth": false,
          "RedirectUrl": true,
          "OtherPCStack": "IPV4",
          "OtherMobileStack": "IPV4",
          "MsgApi": "new"
        };
    getChallengeApi = '/cgi-bin/get_challenge';
    srunPortalApi = '/cgi-bin/srun_portal';
    _dio = Dio(BaseOptions(
      baseUrl: 'http://${portal['AuthIP']}',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ));
  }

  String _errInfo = '';

  Future<Result> login() async {
    ip = await _getIP();
    assert(ip.isNotEmpty && ip != 'error', '获取ip失败，${_errInfo.isEmpty ? '请检查网络' : _errInfo}');
    token = await _getToken();
    assert(token.isNotEmpty && ip != 'error', '获取token失败，${_errInfo.isEmpty ? '请检查网络' : _errInfo}');
    i = '{SRBX1}${base.encode(xEncode(_getInfo(), token))}';
    _complex();
    final res = await _send();
    assert(res.isNotEmpty && ip != 'error', '获取token失败，${_errInfo.isEmpty ? '请检查网络' : _errInfo}');
    Utils.logger.i(res);
    return Result(res);
  }

  Future<Result?> logout() async {
    final cb = 'JQuery114514_${DateTime.now().millisecondsSinceEpoch}';
    return _dio.get(srunPortalApi, queryParameters: {
      'action': 'logout',
      'callback': cb,
      'username': username,
      'ip': ip,
      'ac_id': ac_id,
      '_': DateTime.now().millisecondsSinceEpoch,
    }).then((value) {
      Utils.logger.i(value.data);
      return Result(_getResultMap(value.data, cb));
    }, onError: (err) {
      Utils.logger.e(err);
    });
  }

  Future<String> _getIP() {
    return _dio.get<String>('/').then((value) {
      if (value.data == null) {
        return '';
      } else {
        return RegExp('id="user_ip" value="(.*?)"').firstMatch(value.data!)?.group(1) ?? '';
      }
    }, onError: (err) {
      Utils.logger.e(err);
      _errInfo = err?.message ?? '';
      return 'error';
    });
  }

  Future<String> _getToken() {
    final challengeParams = {
      'callback': 'JQuery114514_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'ip': ip,
      '_': DateTime.now().millisecondsSinceEpoch,
    };
    return _dio
        .get<String>(
      getChallengeApi,
      queryParameters: challengeParams,
    )
        .then((value) {
      if (value.data == null) {
        return '';
      } else {
        return RegExp('"challenge":"(.*?)"').firstMatch(value.data!)?.group(1) ?? '';
      }
    }, onError: (err) {
      Utils.logger.e(err);
      _errInfo = err?.message ?? '';
      return 'error';
    });
  }

  void _complex() {
    final hmac = Hmac(md5, utf8.encode(password));
    hmd5 = hmac.convert(utf8.encode(token)).toString();
    chkSum = sha1.convert(utf8.encode(_getChkSum())).toString();
  }

  String _getChkSum() {
    String str = token + username;
    str += token + hmd5;
    str += token + ac_id;
    str += token + ip;
    str += token + n;
    str += token + type;
    str += token + i;
    return str;
  }

  Future<Map<String, dynamic>> _send() {
    final params = {
      'callback': 'jQuery114514_${DateTime.now().millisecondsSinceEpoch}',
      'action': 'login',
      'username': username,
      'password': '{MD5}$hmd5',
      'ac_id': ac_id,
      'ip': ip,
      'chksum': chkSum,
      'info': i,
      'n': n,
      'type': type,
      'os': 'Windows 10',
      'name': 'Windows',
      'double_stack': '1',
      '_': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    return _dio.get(srunPortalApi, queryParameters: params).then((value) {
      return _getResultMap(value.data, params['callback'] as String);
    }, onError: (err) {
      Utils.logger.e(err);
      _errInfo = err?.message ?? '';
      return {};
    });
  }

  Map<String, dynamic> _getResultMap(String str, String cb) {
    return Map.from(jsonDecode(RegExp('^$cb\\((.+)\\)\$').firstMatch(str)!.group(1)!));
  }

  String _getInfo() {
    return jsonEncode({
      'username': username,
      'password': password,
      'ip': ip,
      'acid': ac_id,
      'enc_ver': enc,
    });
  }
}
