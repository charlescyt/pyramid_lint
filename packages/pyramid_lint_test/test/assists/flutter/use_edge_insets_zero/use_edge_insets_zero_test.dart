// ignore_for_file: max_lines_for_function

import 'package:analyzer/source/source_range.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pyramid_lint/src/assists/flutter/use_edge_insets_zero.dart';
import 'package:test/test.dart';

import '../../../golden.dart';

void main() {
  testGolden(
    'Use EdgeInsets.zero',
    'assists/flutter/use_edge_insets_zero/use_edge_insets_zero.diff',
    sourcePath: 'test/assists/flutter/use_edge_insets_zero/use_edge_insets_zero.dart',
    (result) async {
      final assist = UseEdgeInsetsZero();
      final pubspec = Pubspec('test', dependencies: {'flutter': SdkDependency('flutter')});

      final changes = [
        // EdgeInsets.all(0)
        //             ^^
        ...await assist.testRun(result, const SourceRange(147, 0), pubspec: pubspec),

        // EdgeInsets.fromLTRB(0, 0, 0, 0)
        //    ^^
        ...await assist.testRun(result, const SourceRange(177, 0), pubspec: pubspec),

        // EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0)
        //          ^^
        ...await assist.testRun(result, const SourceRange(236, 0), pubspec: pubspec),

        // EdgeInsets.symmetric(vertical: 0, horizontal: 0)
        // ^^
        ...await assist.testRun(result, const SourceRange(302, 0), pubspec: pubspec),
      ];

      expect(changes, hasLength(4));

      return changes;
    },
  );
}
