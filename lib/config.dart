import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Config {
  static bool isDebugMode = kDebugMode;
  static bool showLog = false;
  static List<String> logs = [];
  static late final PackageInfo packageInfo;
}
