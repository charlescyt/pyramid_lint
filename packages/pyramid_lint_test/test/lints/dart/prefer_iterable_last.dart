// ignore_for_file: unused_local_variable

const numbers = [1, 2, 3];

// expect_lint: prefer_iterable_last
final a = numbers[numbers.length - 1];

// expect_lint: prefer_iterable_last
final b = numbers.elementAt(numbers.length - 1);

final listOfLists = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
];

void fn() {
  // expect_lint: prefer_iterable_last
  final value = listOfLists[listOfLists.length - 1][1];
}
