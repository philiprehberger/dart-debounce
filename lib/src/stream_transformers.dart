import 'dart:async';

/// Stream extension methods for debounce and throttle.
extension DebounceThrottleStream<T> on Stream<T> {
  /// Debounce this stream, emitting only the last value after a pause of [delay].
  ///
  /// ```dart
  /// stream.debounce(Duration(milliseconds: 300)).listen(print);
  /// ```
  Stream<T> debounce(Duration delay) {
    Timer? timer;
    // ignore: close_sinks
    final controller = isBroadcast
        ? StreamController<T>.broadcast()
        : StreamController<T>();

    late StreamSubscription<T> subscription;
    T? lastValue;
    var hasValue = false;

    subscription = listen(
      (event) {
        lastValue = event;
        hasValue = true;
        timer?.cancel();
        timer = Timer(delay, () {
          if (hasValue) {
            controller.add(lastValue as T);
            hasValue = false;
          }
        });
      },
      onError: controller.addError,
      onDone: () {
        timer?.cancel();
        if (hasValue) {
          controller.add(lastValue as T);
        }
        controller.close();
      },
    );

    controller.onCancel = () {
      timer?.cancel();
      subscription.cancel();
    };

    return controller.stream;
  }

  /// Throttle this stream, emitting at most one value per [interval].
  ///
  /// ```dart
  /// stream.throttle(Duration(seconds: 1)).listen(print);
  /// ```
  Stream<T> throttle(Duration interval) {
    // ignore: close_sinks
    final controller = isBroadcast
        ? StreamController<T>.broadcast()
        : StreamController<T>();

    late StreamSubscription<T> subscription;
    DateTime? lastEmit;

    subscription = listen(
      (event) {
        final now = DateTime.now();
        if (lastEmit == null || now.difference(lastEmit!) >= interval) {
          controller.add(event);
          lastEmit = now;
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  /// Emit at most one value per [interval], always including the latest
  /// value when the window ends.
  ///
  /// Like [throttle] this rate-limits emissions, but it also guarantees
  /// the most recent value is emitted on the trailing edge so the
  /// consumer never misses the final state. Useful for slider drags,
  /// scroll positions, or cursor coordinates where the last value
  /// matters most.
  ///
  /// ```dart
  /// sliderStream
  ///     .throttleLatest(Duration(milliseconds: 100))
  ///     .listen(saveValue);
  /// ```
  Stream<T> throttleLatest(Duration interval) {
    Timer? timer;
    // ignore: close_sinks
    final controller = isBroadcast
        ? StreamController<T>.broadcast()
        : StreamController<T>();

    late StreamSubscription<T> subscription;
    T? latest;
    var hasLatest = false;
    var inCooldown = false;

    void emitLatest() {
      if (hasLatest) {
        controller.add(latest as T);
        hasLatest = false;
      }
    }

    subscription = listen(
      (event) {
        if (!inCooldown) {
          controller.add(event);
          inCooldown = true;
          timer = Timer(interval, () {
            inCooldown = false;
            emitLatest();
          });
        } else {
          latest = event;
          hasLatest = true;
        }
      },
      onError: controller.addError,
      onDone: () {
        timer?.cancel();
        emitLatest();
        controller.close();
      },
    );

    controller.onCancel = () {
      timer?.cancel();
      subscription.cancel();
    };

    return controller.stream;
  }
}
