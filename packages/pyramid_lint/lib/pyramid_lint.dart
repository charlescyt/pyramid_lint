import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/dart/invert_boolean_expression.dart';
import 'src/assists/dart/swap_then_else_expression.dart';
import 'src/assists/flutter/use_edge_insets_zero.dart';
import 'src/assists/flutter/wrap_all_children_with_expanded.dart';
import 'src/assists/flutter/wrap_with_layout_builder.dart';
import 'src/assists/flutter/wrap_with_listenable_builder.dart';
import 'src/assists/flutter/wrap_with_stack.dart';

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
    InvertBooleanExpression(),
    SwapThenElseExpression(),
    // Flutter assists
    UseEdgeInsetsZero(),
    WrapAllChildrenWithExpanded(),
    WrapWithLayoutBuilder(),
    WrapWithListenableBuilder(),
    WrapWithStack(),
  ];
}
