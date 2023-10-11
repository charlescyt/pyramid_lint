import 'package:flutter/foundation.dart' show ValueChanged;

typedef A = ValueChanged<int>;
// expect_lint: prefer_value_changed
typedef B = void Function(int index);
typedef C = void Function({required int index});
