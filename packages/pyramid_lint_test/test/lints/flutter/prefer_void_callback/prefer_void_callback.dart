import 'package:flutter/foundation.dart' show VoidCallback;

typedef A = VoidCallback;
// expect_lint: prefer_void_callback
typedef B = void Function();
// expect_lint: prefer_void_callback
typedef C = void Function()?;
typedef D = void Function(int index);
typedef E = void Function({required int index});
