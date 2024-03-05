// ignore_for_file: unused_local_variable, prefer_library_prefixes

// expect_lint: avoid_duplicate_imports
import 'dart:math' as math show max;
// expect_lint: avoid_duplicate_imports
import 'dart:math';

void example() {
  final a = math.max(1, 10);
  final b = min(1, 10);
}
