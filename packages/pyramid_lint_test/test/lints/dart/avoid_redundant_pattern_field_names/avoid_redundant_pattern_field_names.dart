// ignore_for_file: avoid_empty_blocks, unused_local_variable

void fn(Map<String, int> map) {
  // expect_lint: avoid_redundant_pattern_field_names
  for (final MapEntry(key: key, value: value) in map.entries) {}
}
