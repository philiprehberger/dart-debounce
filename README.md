# philiprehberger_debounce

[![Tests](https://github.com/philiprehberger/dart-debounce/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/dart-debounce/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_debounce.svg)](https://pub.dev/packages/philiprehberger_debounce)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/dart-debounce)](https://github.com/philiprehberger/dart-debounce/commits/main)

Debounce and throttle utilities with Stream transformers and cancellation

## Requirements

- Dart >= 3.6

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_debounce: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:philiprehberger_debounce/debounce.dart';

final debouncer = Debouncer(delay: Duration(milliseconds: 300));
debouncer.call(() => print('Search executed'));
debouncer.call(() => print('Only this one runs'));
```

### Throttler

```dart
final throttler = Throttler(interval: Duration(seconds: 1));
throttler.call(() => print('Scroll handler'));
throttler.call(() => print('Skipped - too soon'));
```

### Stream Transformers

```dart
// Debounce a stream
textFieldStream
    .debounce(Duration(milliseconds: 300))
    .listen((query) => search(query));

// Throttle a stream
scrollStream
    .throttle(Duration(milliseconds: 100))
    .listen((offset) => updateUI(offset));
```

## API

| Method | Description |
|--------|-------------|
| `Debouncer(delay:)` | Create a debouncer with the given delay |
| `Debouncer.call(action)` | Schedule action after delay, resetting on repeated calls |
| `Debouncer.cancel()` | Cancel any pending debounced call |
| `Debouncer.isActive` | Whether a debounced call is pending |
| `Throttler(interval:, leading:, trailing:)` | Create a throttler with interval and edge options |
| `Throttler.call(action)` | Execute action respecting the throttle interval |
| `Throttler.cancel()` | Cancel any pending throttled call |
| `Throttler.isActive` | Whether the throttler is in its cooldown period |
| `Stream.debounce(delay)` | Emit only the last value after a pause of delay |
| `Stream.throttle(interval)` | Emit at most one value per interval |

## Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/dart-debounce)

🐛 [Report issues](https://github.com/philiprehberger/dart-debounce/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/dart-debounce/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
