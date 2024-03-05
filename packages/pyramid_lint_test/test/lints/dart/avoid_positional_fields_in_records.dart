// ignore_for_file: unused_local_variable

void fn((String, String, {int a, bool b}) record) {
  // expect_lint: avoid_positional_fields_in_records
  final first = record.$1;
  // expect_lint: avoid_positional_fields_in_records
  final second = record.$2;
  final a = record.a;
  final b = record.b;
}
