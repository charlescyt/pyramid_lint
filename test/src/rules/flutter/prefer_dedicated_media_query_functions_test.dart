import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/prefer_dedicated_media_query_functions.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferDedicatedMediaQueryFunctionsRuleTest);
  });
}

@reflectiveTest
class PreferDedicatedMediaQueryFunctionsRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = PreferDedicatedMediaQueryFunctionsRule();

    newFile(
      join(packagesRootPath, 'flutter', 'lib', 'src', 'widgets', 'media_query.dart'),
      '''
import 'package:flutter/widgets.dart';

class MediaQueryData {
  const MediaQueryData();
  Size get size => const Size(0, 0);
}

class MediaQuery {
  static MediaQueryData of(BuildContext context) => const MediaQueryData();
  static MediaQueryData? maybeOf(BuildContext context) => const MediaQueryData();
}
''',
    );

    super.setUp();

    final file = getFile(join(packagesRootPath, 'flutter', 'lib', 'widgets.dart'));
    final content = file.readAsStringSync();
    if (!content.contains("export 'src/widgets/media_query.dart'")) {
      file.writeAsStringSync('''
$content
export 'src/widgets/media_query.dart';
''');
    }
  }

  Future<void> test_media_query_of() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f(BuildContext context) {
  final size = MediaQuery.of(context).size;
}
''',
      [lint(86, 27)],
    );
  }

  Future<void> test_media_query_maybe_of() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f(BuildContext context) {
  final size = MediaQuery.maybeOf(context)?.size;
}
''',
      [lint(86, 33)],
    );
  }

  Future<void> test_indirect_media_query_of() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final size = mediaQuery.size;
}
''',
      [lint(131, 15)],
    );
  }

  Future<void> test_indirect_media_query_maybe_of() async {
    await assertDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  final size = mediaQuery?.size;
}
''',
      [lint(136, 16)],
    );
  }

  Future<void> test_media_query_data() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/widgets.dart';

void f(MediaQueryData mediaQuery) {
  final size = mediaQuery.size;
}
''',
    );
  }
}
