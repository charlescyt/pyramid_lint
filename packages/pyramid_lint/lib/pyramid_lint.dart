import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/dart/invert_boolean_expression.dart';
import 'src/assists/dart/swap_then_else_expression.dart';
import 'src/assists/flutter/use_edge_insets_zero.dart';
import 'src/assists/flutter/wrap_all_children_with_expanded.dart';
import 'src/assists/flutter/wrap_with_expanded.dart';
import 'src/assists/flutter/wrap_with_layout_builder.dart';
import 'src/assists/flutter/wrap_with_listenable_builder.dart';
import 'src/assists/flutter/wrap_with_stack.dart';
import 'src/assists/flutter/wrap_with_value_listenable_builder.dart';
import 'src/lints/dart/always_put_doc_comments_before_annotations.dart';
import 'src/lints/dart/always_specify_parameter_names.dart';
import 'src/lints/dart/avoid_abbreviations_in_doc_comments.dart';
import 'src/lints/dart/avoid_dynamic.dart';
import 'src/lints/dart/avoid_empty_blocks.dart';
import 'src/lints/dart/avoid_inverted_boolean_expressions.dart';
import 'src/lints/dart/avoid_mutable_global_variables.dart';
import 'src/lints/dart/avoid_nested_if.dart';
import 'src/lints/dart/avoid_positional_fields_in_records.dart';
import 'src/lints/dart/avoid_redundant_pattern_field_names.dart';
import 'src/lints/dart/avoid_unused_parameters.dart';
import 'src/lints/dart/boolean_prefixes.dart';
import 'src/lints/dart/class_members_ordering.dart';
import 'src/lints/dart/max_lines_for_file.dart';
import 'src/lints/dart/max_lines_for_function.dart';
import 'src/lints/dart/max_switch_cases.dart';
import 'src/lints/dart/no_duplicate_imports.dart';
import 'src/lints/dart/no_self_comparisons.dart';
import 'src/lints/dart/prefer_async_await.dart';
import 'src/lints/dart/prefer_const_constructor_declarations.dart';
import 'src/lints/dart/prefer_immediate_return.dart';
import 'src/lints/dart/prefer_iterable_any.dart';
import 'src/lints/dart/prefer_iterable_every.dart';
import 'src/lints/dart/prefer_iterable_first.dart';
import 'src/lints/dart/prefer_iterable_last.dart';
import 'src/lints/dart/prefer_library_prefixes.dart';
import 'src/lints/dart/prefer_new_line_before_return.dart';
import 'src/lints/dart/prefer_underscore_for_unused_callback_parameters.dart';
import 'src/lints/dart/unnecessary_nullable_return_type.dart';
import 'src/lints/flutter/avoid_public_members_in_states.dart';
import 'src/lints/flutter/avoid_returning_widgets.dart';
import 'src/lints/flutter/avoid_single_child_in_flex.dart';
import 'src/lints/flutter/dispose_controllers.dart';
import 'src/lints/flutter/prefer_async_callback.dart';
import 'src/lints/flutter/prefer_border_from_border_side.dart';
import 'src/lints/flutter/prefer_border_radius_all.dart';
import 'src/lints/flutter/prefer_dedicated_media_query_method.dart';
import 'src/lints/flutter/prefer_text_rich.dart';
import 'src/lints/flutter/prefer_void_callback.dart';
import 'src/lints/flutter/proper_edge_insets_constructors.dart';
import 'src/lints/flutter/proper_expanded_and_flexible.dart';
import 'src/lints/flutter/proper_from_environment.dart';
import 'src/lints/flutter/proper_super_dispose.dart';
import 'src/lints/flutter/proper_super_init_state.dart';
import 'src/lints/flutter/use_spacer.dart';

/// This is the entry point of Pyramid Linter.
PluginBase createPlugin() => _PyramidLinter();

class _PyramidLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // Dart lints
        AlwaysPutDocCommentsBeforeAnnotations.fromConfigs(configs),
        AlwaysSpecifyParameterNames.fromConfigs(configs),
        AvoidAbbreviationsInDocComments.fromConfigs(configs),
        AvoidDynamic.fromConfigs(configs),
        AvoidEmptyBlocks.fromConfigs(configs),
        AvoidInvertedBooleanExpressions.fromConfigs(configs),
        AvoidMutableGlobalVariables.fromConfigs(configs),
        AvoidNestedIf.fromConfigs(configs),
        AvoidPositionalFieldsInRecords.fromConfigs(configs),
        AvoidRedundantPatternFieldNames.fromConfigs(configs),
        AvoidUnusedParameters.fromConfigs(configs),
        BooleanPrefixes.fromConfigs(configs),
        ClassMembersOrdering.fromConfigs(configs),
        MaxLinesForFile.fromConfigs(configs),
        MaxLinesForFunction.fromConfigs(configs),
        MaxSwitchCases.fromConfigs(configs),
        NoDuplicateImports.fromConfigs(configs),
        NoSelfComparisons.fromConfigs(configs),
        PreferAsyncAwait.fromConfigs(configs),
        PreferConstConstructorDeclarations.fromConfigs(configs),
        PreferImmediateReturn.fromConfigs(configs),
        PreferIterableAny.fromConfigs(configs),
        PreferIterableEvery.fromConfigs(configs),
        PreferIterableFirst.fromConfigs(configs),
        PreferIterableLast.fromConfigs(configs),
        PreferLibraryPrefixes.fromConfigs(configs),
        PreferNewLineBeforeReturn.fromConfigs(configs),
        PreferUnderscoreForUnusedCallbackParameters.fromConfigs(configs),
        UnnecessaryNullableReturnType.fromConfigs(configs),
        // Flutter lints
        AvoidPublicMembersInStates.fromConfigs(configs),
        AvoidReturningWidgets.fromConfigs(configs),
        AvoidSingleChildInFlex.fromConfigs(configs),
        DisposeControllers.fromConfigs(configs),
        PreferAsyncCallback.fromConfigs(configs),
        PreferBorderFromBorderSide.fromConfigs(configs),
        PreferBorderRadiusAll.fromConfigs(configs),
        PreferDedicatedMediaQueryMethod.fromConfigs(configs),
        PreferTextRich.fromConfigs(configs),
        PreferVoidCallback.fromConfigs(configs),
        ProperEdgeInsetsConstructors.fromConfigs(configs),
        ProperExpandedAndFlexible.fromConfigs(configs),
        ProperFromEnvironment.fromConfigs(configs),
        ProperSuperDispose.fromConfigs(configs),
        ProperSuperInitState.fromConfigs(configs),
        UseSpacer.fromConfigs(configs),
      ];

  @override
  List<Assist> getAssists() => [
        // Dart assists
        InvertBooleanExpression(),
        SwapThenElseExpression(),
        // Flutter assists
        UseEdgeInsetsZero(),
        WrapWithExpanded(),
        WrapAllChildrenWithExpanded(),
        WrapWithLayoutBuilder(),
        WrapWithListenableBuilder(),
        WrapWithStack(),
        WrapWithValueListenableBuilder(),
      ];
}
