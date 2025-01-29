import 'package:tarsier_websocket_client/src/utils/debug_utils.dart';

/// Terminal color codes for styled log outputs.
/// These ANSI escape codes enable text formatting in the console.
final green = '\x1B[32m';
final red = '\x1B[31m';
final blue = '\x1B[34m';
final navyBlue = '\x1B[36m';
final yellow = '\x1B[33m';
final reset = '\x1B[0m';

final greenBg = '\x1B[48;5;10m';
final redBg = '\x1B[48;5;9m';
final blueBg = '\x1B[48;5;12m';
final lightBlueBg = '\x1B[48;5;117m';
final yellowBg = '\x1B[48;5;11m';

String formatInBrackets(String text, [int width = 34]) {
  int padding =
      (width - text.length) ~/ 2; // Calculate spaces needed on both sides
  String paddedText = text.padLeft(text.length + padding).padRight(width);
  return "[$paddedText]"; // Enclose in brackets
}

void printDebug(Object? object) {
  if (DebugUtils.isDebug) {
    print(object);
  }
}

printError(String tag, String message, [String character = '🚨']) {
  printDebug(
      '$red${"[$character ERROR  ]${formatInBrackets(tag)}: $message"}$reset');
}

printInfo(String tag, String message, [String character = '💡']) {
  printDebug(
      '$blue${"[$character INFO   ]${formatInBrackets(tag)}: $message"}$reset');
}

printWarning(String tag, String message, [String character = '⚡']) {
  printDebug(
      '$yellow${"[$character WARNING]${formatInBrackets(tag)}: $message"}$reset');
}

printSuccess(String tag, String message, [String character = '✅']) {
  printDebug(
      '$green${"[$character SUCCESS]${formatInBrackets(tag)}: $message"}$reset');
}

printVerbose(String tag, String message, [String character = '💎']) {
  printDebug(
      '$reset${"[$character VERBOSE]${formatInBrackets(tag)}: $message"}$reset');
}

enum DebugType { error, info, warning, success, verbose }

printLog(
    {required String tag,
    required dynamic message,
    DebugType type = DebugType.info}) {
  switch (type) {
    case DebugType.verbose:
      {
        printVerbose(tag, message);
        break;
      }
    case DebugType.info:
      {
        printInfo(tag, message);
        break;
      }
    case DebugType.error:
      {
        printError(tag, message);
        break;
      }
    case DebugType.warning:
      {
        printWarning(tag, message);
        break;
      }
    case DebugType.success:
      {
        printSuccess(tag, message);
        break;
      }
  }
}
