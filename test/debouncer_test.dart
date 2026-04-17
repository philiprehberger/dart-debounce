import 'package:philiprehberger_debounce/debounce.dart';
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    test('calls action after delay', () async {
      var called = false;
      final debouncer = Debouncer(delay: Duration(milliseconds: 50));
      debouncer.call(() => called = true);
      expect(called, isFalse);
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(called, isTrue);
    });

    test('only executes last call within delay window', () async {
      var value = 0;
      final debouncer = Debouncer(delay: Duration(milliseconds: 50));
      debouncer.call(() => value = 1);
      debouncer.call(() => value = 2);
      debouncer.call(() => value = 3);
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(value, equals(3));
    });

    test('cancel prevents execution', () async {
      var called = false;
      final debouncer = Debouncer(delay: Duration(milliseconds: 50));
      debouncer.call(() => called = true);
      debouncer.cancel();
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(called, isFalse);
    });

    test('isActive returns true when pending', () {
      final debouncer = Debouncer(delay: Duration(milliseconds: 50));
      expect(debouncer.isActive, isFalse);
      debouncer.call(() {});
      expect(debouncer.isActive, isTrue);
      debouncer.cancel();
      expect(debouncer.isActive, isFalse);
    });

    test('immediate mode calls action on first call', () {
      final debouncer =
          Debouncer(delay: Duration(milliseconds: 100), immediate: true);
      var called = false;
      debouncer.call(() => called = true);
      expect(called, isTrue);
    });

    test('immediate mode ignores subsequent calls within delay', () async {
      final debouncer =
          Debouncer(delay: Duration(milliseconds: 50), immediate: true);
      var callCount = 0;
      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);
      expect(callCount, 1);
      await Future<void>.delayed(Duration(milliseconds: 80));
    });

    test('immediate mode fires again after delay resets', () async {
      final debouncer =
          Debouncer(delay: Duration(milliseconds: 50), immediate: true);
      var callCount = 0;
      debouncer.call(() => callCount++);
      expect(callCount, 1);
      await Future<void>.delayed(Duration(milliseconds: 80));
      debouncer.call(() => callCount++);
      expect(callCount, 2);
    });
  });

  group('Debouncer.flush', () {
    test('executes pending action immediately', () {
      var value = 0;
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      debouncer.call(() => value = 42);
      expect(value, equals(0));
      debouncer.flush();
      expect(value, equals(42));
    });

    test('does nothing when no action is pending', () {
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      debouncer.flush(); // should not throw
    });

    test('cancels timer after flush', () {
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      debouncer.call(() {});
      debouncer.flush();
      expect(debouncer.isActive, isFalse);
    });

    test('does not double-execute after flush', () async {
      var count = 0;
      final debouncer = Debouncer(delay: Duration(milliseconds: 50));
      debouncer.call(() => count++);
      debouncer.flush();
      expect(count, equals(1));
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(count, equals(1));
    });
  });

  group('Debouncer.maxWait', () {
    test('fires after maxWait even with continuous calls', () async {
      var fired = false;
      final debouncer = Debouncer(
        delay: Duration(milliseconds: 200),
        maxWait: Duration(milliseconds: 100),
      );

      debouncer.call(() => fired = true);
      await Future<void>.delayed(Duration(milliseconds: 50));
      debouncer.call(() => fired = true);
      expect(fired, isFalse);

      await Future<void>.delayed(Duration(milliseconds: 80));
      expect(fired, isTrue);
    });

    test('normal debounce fires before maxWait if no new calls', () async {
      var fired = false;
      final debouncer = Debouncer(
        delay: Duration(milliseconds: 50),
        maxWait: Duration(milliseconds: 200),
      );

      debouncer.call(() => fired = true);
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(fired, isTrue);
    });

    test('cancel clears maxWait timer', () async {
      var fired = false;
      final debouncer = Debouncer(
        delay: Duration(milliseconds: 200),
        maxWait: Duration(milliseconds: 100),
      );

      debouncer.call(() => fired = true);
      debouncer.cancel();
      await Future<void>.delayed(Duration(milliseconds: 150));
      expect(fired, isFalse);
    });

    test('maxWait resets after firing', () async {
      var count = 0;
      final debouncer = Debouncer(
        delay: Duration(milliseconds: 200),
        maxWait: Duration(milliseconds: 100),
      );

      debouncer.call(() => count++);
      await Future<void>.delayed(Duration(milliseconds: 130));
      expect(count, equals(1));

      debouncer.call(() => count++);
      await Future<void>.delayed(Duration(milliseconds: 130));
      expect(count, equals(2));
    });
  });
}
