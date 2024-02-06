import 'package:flutter/foundation.dart' show AsyncCallback;

typedef A = AsyncCallback;
// expect_lint: prefer_async_callback
typedef B = Future<void> Function();
typedef B2 = Future<int> Function();
// ignore: strict_raw_type
typedef B3 = Future Function();
// expect_lint: prefer_async_callback
typedef C = Future<void> Function()?;
typedef D = Future<void> Function(int index);
typedef E = Future<void> Function({required int index});

Future<T?> thenOrNull<T>(Future<T> Function() cb) async {
  try {
    return await cb();
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return null;
  }
}
