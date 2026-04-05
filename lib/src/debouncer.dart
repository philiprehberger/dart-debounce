import 'dart:async';

/// Delays execution of a callback until a pause in calls.
///
/// Only the last call within the [delay] window is executed.
/// When [immediate] is true, the first call executes immediately and
/// subsequent calls within the delay window are ignored.
///
/// ```dart
/// final debouncer = Debouncer(delay: Duration(milliseconds: 300));
/// debouncer.call(() => print('search'));
/// ```
class Debouncer {
  /// The delay before the callback is executed.
  final Duration delay;

  /// Whether to execute on the leading edge instead of the trailing edge.
  final bool immediate;

  Timer? _timer;
  bool _hasCalledImmediate = false;

  /// Create a debouncer with the given [delay].
  ///
  /// If [immediate] is true, the action fires on the first call and
  /// subsequent calls within the [delay] window are ignored.
  Debouncer({required this.delay, this.immediate = false});

  /// Whether a debounced call is pending.
  bool get isActive => _timer?.isActive ?? false;

  /// Schedule [action] to run after [delay].
  ///
  /// If called again before [delay] elapses, the previous call is cancelled
  /// and the timer resets.
  ///
  /// In immediate mode, [action] fires on the first call and subsequent
  /// calls within the delay window are ignored. After the delay elapses,
  /// the next call will fire immediately again.
  void call(void Function() action) {
    if (immediate) {
      if (!_hasCalledImmediate) {
        _hasCalledImmediate = true;
        action();
      }
      _timer?.cancel();
      _timer = Timer(delay, () {
        _hasCalledImmediate = false;
      });
    } else {
      _timer?.cancel();
      _timer = Timer(delay, action);
    }
  }

  /// Cancel any pending debounced call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _hasCalledImmediate = false;
  }
}
