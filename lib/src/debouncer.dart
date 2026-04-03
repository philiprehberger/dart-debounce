import 'dart:async';

/// Delays execution of a callback until a pause in calls.
///
/// Only the last call within the [delay] window is executed.
///
/// ```dart
/// final debouncer = Debouncer(delay: Duration(milliseconds: 300));
/// debouncer.call(() => print('search'));
/// ```
class Debouncer {
  /// The delay before the callback is executed.
  final Duration delay;

  Timer? _timer;

  /// Create a debouncer with the given [delay].
  Debouncer({required this.delay});

  /// Whether a debounced call is pending.
  bool get isActive => _timer?.isActive ?? false;

  /// Schedule [action] to run after [delay].
  ///
  /// If called again before [delay] elapses, the previous call is cancelled
  /// and the timer resets.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending debounced call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
