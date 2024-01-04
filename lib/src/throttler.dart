import 'dart:async';

/// Limits how often a callback can execute.
///
/// - [leading]: Execute immediately on the first call (default: `true`)
/// - [trailing]: Execute after the interval if calls were made (default: `false`)
///
/// ```dart
/// final throttler = Throttler(interval: Duration(seconds: 1));
/// throttler.call(() => print('scroll'));
/// ```
class Throttler {
  /// The minimum interval between executions.
  final Duration interval;

  /// Whether to execute on the leading edge.
  final bool leading;

  /// Whether to execute on the trailing edge.
  final bool trailing;

  Timer? _timer;
  bool _hasPending = false;
  void Function()? _pendingAction;
  DateTime? _lastExecution;

  /// Create a throttler with the given [interval].
  Throttler({
    required this.interval,
    this.leading = true,
    this.trailing = false,
  });

  /// Whether the throttler is currently in its cooldown period.
  bool get isActive => _timer?.isActive ?? false;

  /// Execute [action] respecting the throttle interval.
  void call(void Function() action) {
    final now = DateTime.now();

    if (_lastExecution == null || now.difference(_lastExecution!) >= interval) {
      if (leading) {
        action();
        _lastExecution = now;
        _startCooldown(action);
      } else {
        _pendingAction = action;
        _hasPending = true;
        _startCooldown(action);
      }
    } else {
      _pendingAction = action;
      _hasPending = true;
    }
  }

  void _startCooldown(void Function() action) {
    if (_timer?.isActive ?? false) return;
    _timer = Timer(interval, () {
      if (trailing && _hasPending && _pendingAction != null) {
        _pendingAction!();
        _lastExecution = DateTime.now();
      }
      _hasPending = false;
      _pendingAction = null;
    });
  }

  /// Cancel any pending throttled call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _hasPending = false;
    _pendingAction = null;
  }
}
