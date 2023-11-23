import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/dart/invert_boolean_expression.dart';
import 'src/assists/dart/swap_then_else_expression.dart';
import 'src/assists/flutter/use_edge_insets_zero.dart';
import 'src/assists/flutter/wrap_with_expanded.dart';
import 'src/assists/flutter/wrap_with_layout_builder.dart';
import 'src/assists/flutter/wrap_with_stack.dart';
import 'src/lints/dart/always_declare_parameter_names.dart';
import 'src/lints/dart/avoid_abbreviations_in_doc_comments.dart';
import 'src/lints/dart/avoid_duplicate_import.dart';
import 'src/lints/dart/avoid_dynamic.dart';
import 'src/lints/dart/avoid_empty_blocks.dart';
import 'src/lints/dart/avoid_inverted_boolean_expressions.dart';
import 'src/lints/dart/avoid_unused_parameters.dart';
import 'src/lints/dart/boolean_prefix.dart';
import 'src/lints/dart/doc_comments_before_annotations.dart';
import 'src/lints/dart/max_lines_for_file.dart';
import 'src/lints/dart/max_lines_for_function.dart';
import 'src/lints/dart/prefer_async_await.dart';
import 'src/lints/dart/prefer_declaring_const_constructors.dart';
import 'src/lints/dart/prefer_immediate_return.dart';
import 'src/lints/dart/prefer_iterable_first.dart';
import 'src/lints/dart/prefer_iterable_last.dart';
import 'src/lints/dart/prefer_library_prefixes.dart';
import 'src/lints/dart/prefer_new_line_before_return.dart';
import 'src/lints/dart/prefer_underscore_for_unused_callback_parameters.dart';
import 'src/lints/dart/unnecessary_nullable_return_type.dart';
import 'src/lints/flutter/avoid_returning_widgets.dart';
import 'src/lints/flutter/avoid_single_child_in_flex.dart';
import 'src/lints/flutter/prefer_async_callback.dart';
import 'src/lints/flutter/prefer_border_from_border_side.dart';
import 'src/lints/flutter/prefer_border_radius_all.dart';
import 'src/lints/flutter/prefer_dedicated_media_query_method.dart';
import 'src/lints/flutter/prefer_spacer.dart';
import 'src/lints/flutter/prefer_text_rich.dart';
import 'src/lints/flutter/prefer_value_changed.dart';
import 'src/lints/flutter/prefer_void_callback.dart';
import 'src/lints/flutter/proper_controller_dispose.dart';
import 'src/lints/flutter/proper_edge_insets_constructor.dart';
import 'src/lints/flutter/proper_expanded_and_flexible.dart';
import 'src/lints/flutter/proper_from_environment.dart';
import 'src/lints/flutter/proper_super_dispose.dart';
import 'src/lints/flutter/proper_super_init_state.dart';

/// This is the entry point of Pyramid Linter.
PluginBase createPlugin() => _PyramidLinter();

class _PyramidLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // Dart lints
        const AlwaysDeclareParameterNames(),
        AvoidAbbreviationsInDocComments.fromConfigs(configs),
        const AvoidDuplicateImport(),
        const AvoidDynamic(),
        const AvoidEmptyBlocks(),
        const AvoidInvertedBooleanExpressions(),
        AvoidUnusedParameters.fromConfigs(configs),
        BooleanPrefix.fromConfigs(configs),
        const DocCommentsBeforeAnnotations(),
        MaxLinesForFile(configs),
        MaxLinesForFunction(configs),
        const PreferAsyncAwait(),
        const PreferDeclaringConstConstructors(),
        const PreferImmediateReturn(),
        const PreferIterableFirst(),
        const PreferIterableLast(),
        PreferLibraryPrefixes.fromConfigs(configs),
        const PreferNewLineBeforeReturn(),
        const PreferUnderscoreForUnusedCallbackParameters(),
        const UnnecessaryNullableReturnType(),
        // Flutter lints
        const AvoidReturningWidgets(),
        const AvoidSingleChildInFlex(),
        const PreferAsyncCallback(),
        const PreferBorderFromBorderSide(),
        const PreferBorderRadiusAll(),
        const PreferDedicatedMediaQueryMethod(),
        const PreferSpacer(),
        const PreferTextRich(),
        const PreferValueChanged(),
        const PreferVoidCallback(),
        const ProperControllerDispose(),
        const ProperEdgeInsetsConstructor(),
        const ProperExpandedAndFlexible(),
        const ProperFromEnvironment(),
        const ProperSuperDispose(),
        const ProperSuperInitState(),
      ];

  @override
  List<Assist> getAssists() => [
        // Dart assists
        InvertBooleanExpression(),
        SwapThenElseExpression(),
        // Flutter assists
        UseEdgeInsetsZero(),
        WrapWithExpanded(),
        WrapWithLayoutBuilder(),
        WrapWithStack(),
      ];
}
