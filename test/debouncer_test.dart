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
  });
}
