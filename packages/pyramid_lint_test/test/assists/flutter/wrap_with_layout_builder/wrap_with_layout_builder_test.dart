import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_with_layout_builder.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap with LayoutBuilder',
    'assists/flutter/wrap_with_layout_builder/wrap_with_layout_builder.diff',
    sourcePath:
        'test/assists/flutter/wrap_with_layout_builder/wrap_with_layout_builder.dart',
    (result) async {
      final assist = WrapWithLayoutBuilder();
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Container
        ...await assist.testRun(
          result,
          const SourceRange(166, 0),
          pubspec: pubspec,
        ),
      ];

      expect(changes, hasLength(1));

      return changes;
    },
  );
}
