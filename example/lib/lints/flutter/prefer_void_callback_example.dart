// ignore_for_file: prefer_value_changed

import 'package:flutter/foundation.dart';

typedef A = VoidCallback;
// expect_lint: prefer_void_callback
typedef B = void Function();
typedef C = void Function(int index);
typedef D = void Function({required int index});
