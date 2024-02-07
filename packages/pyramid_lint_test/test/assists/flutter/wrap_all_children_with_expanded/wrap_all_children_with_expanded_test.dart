import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/wrap_all_children_with_expanded.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Wrap all children with Expanded',
    'assists/flutter/wrap_all_children_with_expanded/wrap_all_children_with_expanded.diff',
    sourcePath:
        'test/assists/flutter/wrap_all_children_with_expanded/wrap_all_children_with_expanded.dart',
    (result) async {
      final assist = WrapAllChildrenWithExpanded();
      final pubspec = Pubspec(
        'test',
        dependencies: {'flutter': SdkDependency('flutter')},
      );

      final changes = [
        // Column
        ...await assist.testRun(
          result,
          const SourceRange(169, 0),
          pubspec: pubspec,
        ),

        // Row
        ...await assist.testRun(
          result,
          const SourceRange(202, 0),
          pubspec: pubspec,
        ),
      ];

      expect(changes, hasLength(2));

      return changes;
    },
  );
}
