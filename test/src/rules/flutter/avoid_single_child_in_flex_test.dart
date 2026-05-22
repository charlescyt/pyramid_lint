import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/avoid_single_child_in_flex.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidSingleChildInFlexRuleTest);
  });
}

@reflectiveTest
class AvoidSingleChildInFlexRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = AvoidSingleChildInFlexRule();
    super.setUp();
  }

  Future<void> test_single_child_column() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

final singleChild = Column(
  children: [
    Placeholder(),
  ],
);
''',
      [
        lint(60, 6, messageContainsAll: ['Column']),
      ],
    );
  }

  Future<void> test_single_child_row() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

final singleChild = Row(
  children: [
    Placeholder(),
  ],
);
''',
      [
        lint(60, 3, messageContainsAll: ['Row']),
      ],
    );
  }

  Future<void> test_multiple_children() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

final multipleChildren = Column(
  children: [
    Placeholder(),
    Placeholder(),
  ],
);
''',
    );
  }

  Future<void> test_spread_element() async {
    await assertNoDiagnostics(
      r'''
import 'package:flutter/widgets.dart';

final spread = Column(
  children: [
    ...[1, 2, 3].map((e) => Text('$e')),
  ],
);
''',
    );
  }

  Future<void> test_collection_for() async {
    await assertNoDiagnostics(
      r'''
import 'package:flutter/widgets.dart';

final collectionFor = Row(
  children: [
    for (final e in [1, 2, 3]) Text('$e'),
  ],
);
''',
    );
  }
}
