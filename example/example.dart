import 'package:philiprehberger_debounce/debounce.dart';

void main() async {
  // Debouncer
  final debouncer = Debouncer(delay: Duration(milliseconds: 300));
  debouncer.call(() => print('Only this one runs'));
  debouncer.call(() => print('Only this one runs'));
  debouncer.call(() => print('Debounced!'));

  // Wait for debounce to fire
  await Future<void>.delayed(Duration(milliseconds: 500));

  // Throttler
  final throttler = Throttler(interval: Duration(seconds: 1));
  throttler.call(() => print('Throttled call 1'));
  throttler.call(() => print('Throttled call 2 - skipped'));

  // Stream debounce
  final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  await stream.throttle(Duration(milliseconds: 100)).forEach(print);
}
