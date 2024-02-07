import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_with_expanded.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap with Expanded',
    'assists/flutter/wrap_with_expanded/wrap_with_expanded.diff',
    sourcePath:
        'test/assists/flutter/wrap_with_expanded/wrap_with_expanded.dart',
    (result) async {
      final assist = WrapWithExpanded();
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Row
        ...await assist.testRun(
          result,
          const SourceRange(168, 0),
          pubspec: pubspec,
        ),

        // Text
        ...await assist.testRun(
          result,
          const SourceRange(200, 0),
          pubspec: pubspec,
        ),

        // Spacer
        ...await assist.testRun(
          result,
          const SourceRange(226, 0),
          pubspec: pubspec,
        ),
      ];

      expect(changes, hasLength(1));

      return changes;
    },
  );
}
