const numbers = [1, 2, 3];

// expect_lint: prefer_iterable_first
final a = numbers[0];

// expect_lint: prefer_iterable_first
final b = numbers.elementAt(0);
