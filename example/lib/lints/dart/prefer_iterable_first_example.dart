// ignore_for_file: unused_local_variable

const numbers = [1, 2, 3];

// expect_lint: prefer_iterable_first
final a = numbers[0];

// expect_lint: prefer_iterable_first
final b = numbers.elementAt(0);

final listOfLists = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
];

void fn() {
  // expect_lint: prefer_iterable_first
  final value = listOfLists[0][1];
}
