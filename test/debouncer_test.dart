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
}
