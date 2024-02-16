// ignore_for_file: unused_local_variable

void fn((String, String, {int a, bool b}) record) {
  // expect_lint: avoid_record_positional_field_getters
  final first = record.$1;
  // expect_lint: avoid_record_positional_field_getters
  final second = record.$2;
  final a = record.a;
  final b = record.b;
}
