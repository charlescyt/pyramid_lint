import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:pyramid_lint/src/rules/flutter/specify_icon_button_tooltip.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SpecifyIconButtonTooltipRuleTest);
  });
}

@reflectiveTest
class SpecifyIconButtonTooltipRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = SpecifyIconButtonTooltipRule();

    // Temporary workaround since analyzer_testing doesn't stub IconButton yet.
    newFile(
      join(packagesRootPath, 'flutter', 'lib', 'src', 'material', 'icon_button.dart'),
      '''
import 'package:flutter/widgets.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String? tooltip;
  final Widget icon;
  final void Function() onPressed;
}
''',
    );

    super.setUp();

    final file = getFile(join(packagesRootPath, 'flutter', 'lib', 'material.dart'));
    final content = file.readAsStringSync();
    file.writeAsStringSync('''
$content\n
export 'src/material/icon_button.dart';
''');
  }

  Future<void> test_icon_button_without_tooltip() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

final a = IconButton(
  icon: Placeholder(),
  onPressed: () {},
);
''',
      [
        lint(51, 10),
      ],
    );
  }

  Future<void> test_icon_button_with_tooltip() async {
    await assertNoDiagnostics(
      '''
import 'package:flutter/material.dart';

final c = IconButton(
  tooltip: '',
  icon: Placeholder(),
  onPressed: () {},
);
''',
    );
  }
}
