import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

extension PubspecExtension on Pubspec {
  bool get isFlutterProject => dependencies.containsKey('flutter');

  VersionConstraint? get dartSdkVersion => environment['sdk'];
}
