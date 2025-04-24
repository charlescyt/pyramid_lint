// ignore_for_file: unused_local_variable, avoid_empty_blocks, omit_local_variable_types

void fn(Iterable<int> numbers) {
  for (final int number in numbers) {}
  for (final number in numbers) {}
}

void fn2(String word) {
  for (final String char in word.split('')) {}
}
