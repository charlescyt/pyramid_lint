import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_with_stack.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap with Stack',
    'assists/flutter/wrap_with_stack/wrap_with_stack.diff',
    sourcePath: 'test/assists/flutter/wrap_with_stack/wrap_with_stack.dart',
    (result) async {
      final assist = WrapWithStack();
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Column
        ...await assist.testRun(
          result,
          const SourceRange(170, 0),
          pubspec: pubspec,
        ),

        // Text
        ...await assist.testRun(
          result,
          const SourceRange(203, 0),
          pubspec: pubspec,
        ),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
