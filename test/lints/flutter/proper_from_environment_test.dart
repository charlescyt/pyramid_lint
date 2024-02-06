// ignore_for_file: do_not_use_environment, prefer_const_constructors

// expect_lint: proper_from_environment
final boolean = bool.fromEnvironment('bool');

// expect_lint: proper_from_environment
final integer = int.fromEnvironment('int');

// expect_lint: proper_from_environment
final string = String.fromEnvironment('String');
