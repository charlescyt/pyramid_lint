import 'package:pub_semver/pub_semver.dart';
import 'package:pyramid_lint/src/utils/version_constraint_extension.dart';
import 'package:test/test.dart';

void main() {
  group('VersionConstraintExtension', () {
    test(
        'meetMinimumRequiredVersion should return true if the version meets the minimum required version',
        () {
      final minVersion = Version.parse('3.0.0');

      var version = VersionConstraint.parse('>=3.3.0 <4.0.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isTrue);

      version = VersionConstraint.parse('^3.3.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isTrue);

      version = VersionConstraint.parse('>=3.3.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isTrue);
    });

    test(
        'meetMinimumRequiredVersion should return false if the version does not meet the minimum required version',
        () {
      final minVersion = Version.parse('3.0.0');

      var version = VersionConstraint.parse('>=2.10.0 <4.0.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isFalse);

      version = VersionConstraint.parse('^2.0.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isFalse);

      version = VersionConstraint.parse('<4.0.0');
      expect(version.meetMinimumRequiredVersion(minVersion), isFalse);

      version = VersionConstraint.any;
      expect(version.meetMinimumRequiredVersion(minVersion), isFalse);

      version = VersionConstraint.empty;
      expect(version.meetMinimumRequiredVersion(minVersion), isFalse);
    });
  });
}
