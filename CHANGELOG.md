# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-04-03

### Fixed
- Primary barrel file now matches package name for pub.dev validation

## [0.1.0] - 2026-04-03

### Added
- `Debouncer` class with configurable delay and cancellation
- `Throttler` class with leading and trailing edge options
- `Stream.debounce()` extension for debouncing stream events
- `Stream.throttle()` extension for throttling stream events
- `isActive` state tracking on both Debouncer and Throttler
- Zero external dependencies
