import 'package:flutter/foundation.dart' show ValueChanged;

typedef A = ValueChanged<int>;
// expect_lint: prefer_value_changed
typedef B = void Function(int index);
// expect_lint: prefer_value_changed
typedef C = void Function(int index)?;
typedef D = void Function({required int index});
