import 'package:philiprehberger_debounce/debounce.dart';
import 'package:test/test.dart';

void main() {
  group('Throttler', () {
    test('executes immediately with leading edge', () {
      var called = false;
      final throttler = Throttler(interval: Duration(seconds: 1));
      throttler.call(() => called = true);
      expect(called, isTrue);
    });

    test('blocks subsequent calls within interval', () {
      var count = 0;
      final throttler = Throttler(interval: Duration(seconds: 1));
      throttler.call(() => count++);
      throttler.call(() => count++);
      throttler.call(() => count++);
      expect(count, equals(1));
    });

    test('cancel clears pending actions', () {
      final throttler = Throttler(interval: Duration(seconds: 1));
      throttler.call(() {});
      throttler.cancel();
      expect(throttler.isActive, isFalse);
    });

    test('flush fires pending trailing action immediately', () {
      var count = 0;
      final throttler = Throttler(
        interval: Duration(seconds: 1),
        leading: true,
        trailing: true,
      );
      throttler.call(() => count++); // leading fires
      throttler.call(() => count++); // queued as trailing
      expect(count, equals(1));
      throttler.flush();
      expect(count, equals(2));
      expect(throttler.isActive, isFalse);
    });

    test('flush is no-op when nothing pending', () {
      var count = 0;
      final throttler = Throttler(interval: Duration(seconds: 1));
      throttler.flush();
      expect(count, equals(0));
      throttler.call(() => count++); // leading
      throttler.flush(); // no trailing queued
      expect(count, equals(1));
    });
  });
}
