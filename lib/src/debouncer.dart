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
  void Function()? _pendingAction;
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
      _pendingAction = null;
      _timer = Timer(delay, () {
        _hasCalledImmediate = false;
      });
    } else {
      _timer?.cancel();
      _pendingAction = action;
      _timer = Timer(delay, () {
        _pendingAction = null;
        action();
      });
    }
  }

  /// Immediately execute the pending action (if any) and cancel the timer.
  ///
  /// In trailing mode, if a call is pending the action fires right away
  /// and the timer is cancelled. In immediate mode, the action has already
  /// fired so this simply resets state.
  ///
  /// Useful for cleanup or dispose scenarios where you want to ensure the
  /// last scheduled action runs before tearing down.
  void flush() {
    final action = _pendingAction;
    cancel();
    if (action != null) {
      action();
    }
  }

  /// Cancel any pending debounced call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
    _hasCalledImmediate = false;
  }
}
