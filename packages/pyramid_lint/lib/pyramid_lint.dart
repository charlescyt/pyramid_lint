import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/dart/convert_to_for_in_iterable_indexed_loop.dart';
import 'src/assists/dart/invert_boolean_expression.dart';
import 'src/assists/dart/swap_then_else_expression.dart';
import 'src/assists/flutter/use_edge_insets_zero.dart';
import 'src/assists/flutter/wrap_all_children_with_expanded.dart';
import 'src/assists/flutter/wrap_with_layout_builder.dart';
import 'src/assists/flutter/wrap_with_listenable_builder.dart';
import 'src/assists/flutter/wrap_with_stack.dart';
import 'src/lints/dart/always_put_doc_comments_before_annotations.dart';
import 'src/lints/dart/avoid_empty_blocks.dart';
import 'src/lints/dart/avoid_inverted_boolean_expressions.dart';
import 'src/lints/dart/avoid_unused_parameters.dart';
import 'src/lints/dart/class_members_ordering.dart';
import 'src/lints/dart/prefer_const_constructor_declarations.dart';
import 'src/lints/dart/prefer_immediate_return.dart';
import 'src/lints/dart/prefer_underscore_for_unused_callback_parameters.dart';
import 'src/lints/dart/unnecessary_nullable_return_type.dart';
import 'src/lints/flutter/avoid_public_members_in_states.dart';
import 'src/lints/flutter/dispose_controllers.dart';
import 'src/lints/flutter/prefer_dedicated_media_query_functions.dart';
import 'src/lints/flutter/proper_super_dispose.dart';
import 'src/lints/flutter/proper_super_init_state.dart';

/// This is the entry point of Pyramid Linter.
PluginBase createPlugin() => _PyramidLinter();

class _PyramidLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // Dart lints
    AlwaysPutDocCommentsBeforeAnnotations.fromConfigs(configs),
    AvoidEmptyBlocks.fromConfigs(configs),
    AvoidInvertedBooleanExpressions.fromConfigs(configs),
    AvoidUnusedParameters.fromConfigs(configs),
    ClassMembersOrdering.fromConfigs(configs),
    PreferConstConstructorDeclarations.fromConfigs(configs),
    PreferImmediateReturn.fromConfigs(configs),
    PreferUnderscoreForUnusedCallbackParameters.fromConfigs(configs),
    UnnecessaryNullableReturnType.fromConfigs(configs),
    // Flutter lints
    AvoidPublicMembersInStates.fromConfigs(configs),
    DisposeControllers.fromConfigs(configs),
    PreferDedicatedMediaQueryFunctions.fromConfigs(configs),
    ProperSuperDispose.fromConfigs(configs),
    ProperSuperInitState.fromConfigs(configs),
  ];

  @override
  List<Assist> getAssists() => [
    // Dart assists
    ConvertToForInIterableIndexedLoop(),
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
