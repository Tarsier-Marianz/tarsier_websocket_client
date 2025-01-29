class DebugUtils {
  static final bool isDebug = _detectDebugMode();

  static bool _detectDebugMode() {
    bool debugMode = false;
    assert(() {
      debugMode = true;
      return true;
    }());
    return debugMode;
  }
}
