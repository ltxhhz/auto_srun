import '../utils/utils.dart';
import './translate.dart';

class Result {
  bool isSuccess = false;
  String message = '';

  //登录和登出
  String msgCode = '';
  String username = '';
  String accessToken = '';
  String clientIp = '';
  String onlineIp = '';
  String srunVersion = '';
  String sysVersion = '';
  int wallerBalance = 0;

  //信息
  // int addTime = 0;
  // int allBytes = 0;
  // int bytesIn = 0;
  // int bytesOut = 0;
  // int checkoutDate = 0;
  // int keepaliveTime = 0;
  // int remainSeconds = 0;
  // int sumBytes = 0;
  // int sumSeconds = 0;
  // int userBalance = 0;
  // int userCharge = 0;
  // String userMac = '';

  Result(Map<String, dynamic> obj) {
    isSuccess = obj['error'] == 'ok';
    msgCode = _toPascal(obj[isSuccess ? 'suc_msg' : 'error_msg']) ?? obj['res'];
    if (isSuccess) {
      username = obj['username'];
      clientIp = obj['client_ip'];
      onlineIp = obj['online_ip'];
      wallerBalance = obj['wallet_balance'];
      accessToken = obj['access_token'];
      sysVersion = obj['sysver'];
    }
    srunVersion = obj['srun_ver'];
    message = translate[msgCode] ?? msgCode;
    Utils.logger.i(message);
  }

  String? _toPascal(String? str) {
    if (str == null) {
      return null;
    }
    return str.replaceAllMapped(RegExp(r'(?<=^|\_)(\w)'), (match) => match.group(0)!.toUpperCase()).replaceAll('_', '');
  }
}
