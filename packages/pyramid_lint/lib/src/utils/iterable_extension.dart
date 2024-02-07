extension IterableExtension<T> on Iterable<T> {
  Iterable<T> get duplicates {
    return removeAll(toSet());
  }

  Iterable<T> removeAll(Iterable<T> items) {
    final list = toList();
    for (final item in items) {
      list.remove(item);
    }
    return list;
  }
}
