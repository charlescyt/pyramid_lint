import 'package:custom_lint_builder/custom_lint_builder.dart';

/// This is the entry point of Pyramid Linter.
PluginBase createPlugin() => _PyramidLinter();

class _PyramidLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // Dart lints
    // Flutter lints
  ];

  @override
  List<Assist> getAssists() => [
    // Dart assists
    // Flutter assists
  ];
}
