extension StringExtensions on String {
  /// Capitalizes the first letter of this string.
  String capitalize() => switch (length) {
        0 => this,
        1 => toUpperCase(),
        _ => '${this[0].toUpperCase()}${substring(1)}',
      };
}
