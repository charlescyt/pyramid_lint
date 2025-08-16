// ignore_for_file: max_lines_for_function

import 'package:analyzer/source/source_range.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_with_listenable_builder.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap with ListenableBuilder',
    'assists/flutter/wrap_with_listenable_builder/wrap_with_listenable_builder.diff',
    sourcePath: 'test/assists/flutter/wrap_with_listenable_builder/wrap_with_listenable_builder.dart',
    (result) async {
      final assist = WrapWithListenableBuilder();
      final pubspec = Pubspec(
        'test',
        environment: {'sdk': VersionConstraint.parse('>=3.0.0 <4.0.0')},
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Column
        ...await assist.testRun(result, const SourceRange(555, 0), pubspec: pubspec),

        // TextFormField
        ...await assist.testRun(result, const SourceRange(657, 0), pubspec: pubspec),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
