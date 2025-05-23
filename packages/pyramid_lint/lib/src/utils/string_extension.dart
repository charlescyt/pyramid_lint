extension StringExtension on String {
  /// Capitalizes the first letter of this string.
  String capitalize() => switch (length) {
    0 => this,
    1 => toUpperCase(),
    _ => '${this[0].toUpperCase()}${substring(1)}',
  };

  /// Returns `true` if this string contains only underscores.
  bool get containsOnlyUnderscores => switch (length) {
    0 => false,
    1 => this == '_',
    2 => this == '__',
    3 => this == '___',
    _ => RegExp(r'^_+$').hasMatch(this),
  };
}
