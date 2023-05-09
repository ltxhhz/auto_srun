import 'package:logger/logger.dart';

import '../config.dart';

class CustomLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    Config.logs.addAll(event.lines);
    for (var line in event.lines) {
      print(line);
    }
  }
}
