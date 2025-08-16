import 'package:pub_semver/pub_semver.dart';

extension VersionConstraintExtension on VersionConstraint {
  bool meetMinimumRequiredVersion(Version minimumRequiredDartSdkVersion) {
    return switch (this) {
      final Version version => version >= minimumRequiredDartSdkVersion,
      final VersionRange range when range.isAny || range.isEmpty => false,
      final VersionRange range => range.min != null && range.min! >= minimumRequiredDartSdkVersion,
      _ => false,
    };
  }
}
