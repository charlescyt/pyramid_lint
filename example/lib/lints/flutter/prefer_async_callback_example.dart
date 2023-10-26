import 'package:flutter/foundation.dart' show AsyncCallback;

typedef A = AsyncCallback;
// expect_lint: prefer_async_callback
typedef B = Future<void> Function();
// expect_lint: prefer_async_callback
typedef C = Future<void> Function()?;
typedef D = Future<void> Function(int index);
typedef E = Future<void> Function({required int index});
