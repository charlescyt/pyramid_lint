import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_with_value_listenable_builder.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap with ValueListenableBuilder',
    'assists/flutter/wrap_with_value_listenable_builder/wrap_with_value_listenable_builder.diff',
    sourcePath:
        'test/assists/flutter/wrap_with_value_listenable_builder/wrap_with_value_listenable_builder.dart',
    (result) async {
      final assist = WrapWithValueListenableBuilder();
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Column
        ...await assist.testRun(
          result,
          const SourceRange(404, 0),
          pubspec: pubspec,
        ),

        // Text
        ...await assist.testRun(
          result,
          const SourceRange(437, 0),
          pubspec: pubspec,
        ),

        // const Text('Lint'),
        //        ^^
        ...await assist.testRun(
          result,
          const SourceRange(615, 0),
          pubspec: pubspec,
        ),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
