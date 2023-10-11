import 'package:flutter/foundation.dart' show AsyncCallback;

typedef A = AsyncCallback;
// expect_lint: prefer_async_callback
typedef B = Future<void> Function();
typedef C = Future<void> Function(int index);
typedef D = Future<void> Function({required int index});
