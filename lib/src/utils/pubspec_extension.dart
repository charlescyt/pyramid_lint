import 'package:pubspec_parse/pubspec_parse.dart';

extension PubspecExtension on Pubspec {
  bool get isFlutterProject => dependencies.containsKey('flutter');
}
