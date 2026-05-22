extension StringExtension on String {
  String capitalize() => switch (length) {
    0 => this,
    1 => toUpperCase(),
    _ => '${this[0].toUpperCase()}${substring(1)}',
  };
}
