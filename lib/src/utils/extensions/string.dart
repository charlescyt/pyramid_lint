extension StringExtension on String {
  String capitalize() => switch (length) {
    0 => this,
    1 => toUpperCase(),
    _ => '${this[0].toUpperCase()}${substring(1)}',
  };

  bool get isJustUnderscores => switch (length) {
    0 => false,
    1 => this == '_',
    2 => this == '__',
    3 => this == '___',
    _ => RegExp(r'^_+$').hasMatch(this),
  };
}
