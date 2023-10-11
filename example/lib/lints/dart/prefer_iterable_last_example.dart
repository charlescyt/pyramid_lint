const numbers = [1, 2, 3];

// expect_lint: prefer_iterable_last
final a = numbers[numbers.length - 1];

// expect_lint: prefer_iterable_last
final b = numbers.elementAt(numbers.length - 1);
