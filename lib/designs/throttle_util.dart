class TapThrottler {
  static final Map<String, DateTime> _lastTapTimes = {};

  static bool canTap(String key) {
    final now = DateTime.now();
    final lastTapTime = _lastTapTimes[key];

    if (lastTapTime == null ||
        now.difference(lastTapTime).inMilliseconds > 500) {
      _lastTapTimes[key] = now;
      return true;
    }
    return false;
  }
}
