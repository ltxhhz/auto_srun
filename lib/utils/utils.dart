import 'package:bot_toast/bot_toast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import './log_output.dart';

class Utils {
  static late final SharedPreferences storage;

  static Future init() async {
    storage = await SharedPreferences.getInstance();
  }

  static Logger? _logger;
  static Logger? _logger1;

  static Logger get logger {
    return Config.showLog
        ? _logger1 ??= Logger(
            printer: PrettyPrinter(),
            filter: ProductionFilter(),
            output: CustomLogOutput(),
          )
        : _logger ??= Logger(
            printer: PrettyPrinter(),
            filter: Config.isDebugMode ? ProductionFilter() : null,
          );
  }

  static Function() showToast(String msg, [bool longToast = false]) {
    return BotToast.showText(text: msg, duration: Duration(seconds: longToast ? 4 : 2));
  }
}
