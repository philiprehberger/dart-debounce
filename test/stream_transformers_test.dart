import 'dart:async';

import 'package:philiprehberger_debounce/debounce.dart';
import 'package:test/test.dart';

void main() {
  group('Stream.debounce', () {
    test('emits last value after pause', () async {
      final controller = StreamController<int>();
      final results = <int>[];

      controller.stream
          .debounce(Duration(milliseconds: 50))
          .listen(results.add);

      controller.add(1);
      controller.add(2);
      controller.add(3);

      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(results, equals([3]));

      await controller.close();
    });
  });

  group('Stream.throttle', () {
    test('limits emission rate', () async {
      final controller = StreamController<int>();
      final results = <int>[];

      controller.stream
          .throttle(Duration(milliseconds: 100))
          .listen(results.add);

      controller.add(1);
      controller.add(2);
      controller.add(3);

      await Future<void>.delayed(Duration(milliseconds: 50));
      // Only first should pass through immediately
      expect(results, equals([1]));

      await controller.close();
    });
  });

  group('Stream.throttleLatest', () {
    test('emits leading immediately and trailing latest', () async {
      final controller = StreamController<int>();
      final results = <int>[];

      controller.stream
          .throttleLatest(Duration(milliseconds: 100))
          .listen(results.add);

      controller.add(1);
      controller.add(2);
      controller.add(3);

      await Future<void>.delayed(Duration(milliseconds: 200));
      expect(results, equals([1, 3]));

      await controller.close();
    });

    test('emits pending latest on done', () async {
      final controller = StreamController<int>();
      final results = <int>[];

      controller.stream
          .throttleLatest(Duration(milliseconds: 200))
          .listen(results.add);

      controller.add(1);
      controller.add(2);
      await controller.close();

      await Future<void>.delayed(Duration(milliseconds: 50));
      expect(results, equals([1, 2]));
    });

    test('handles empty stream cleanly', () async {
      final controller = StreamController<int>();
      final results = <int>[];

      final sub = controller.stream
          .throttleLatest(Duration(milliseconds: 50))
          .listen(results.add);

      await controller.close();
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(results, isEmpty);
      await sub.cancel();
    });
  });
}
