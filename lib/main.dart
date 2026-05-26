import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/assists/dart/convert_to_for_in_iterable_indexed_loop.dart';
import 'src/rules/dart/always_put_doc_comments_before_annotations.dart';
import 'src/rules/dart/always_specify_parameter_names.dart';
import 'src/rules/dart/avoid_dynamic.dart';
import 'src/rules/dart/avoid_empty_blocks.dart';
import 'src/rules/dart/avoid_mutable_global_variables.dart';
import 'src/rules/dart/avoid_positional_fields_in_records.dart';
import 'src/rules/dart/avoid_unused_parameters.dart';
import 'src/rules/dart/no_duplicate_imports.dart';
import 'src/rules/dart/no_self_comparisons.dart';
import 'src/rules/dart/prefer_async_await.dart';
import 'src/rules/dart/prefer_iterable_any.dart';
import 'src/rules/dart/prefer_iterable_every.dart';
import 'src/rules/dart/prefer_iterable_first.dart';
import 'src/rules/dart/prefer_iterable_last.dart';
import 'src/rules/dart/prefer_new_line_before_return.dart';
import 'src/rules/dart/prefer_underscore_for_unused_callback_parameters.dart';
import 'src/rules/dart/proper_from_environment.dart';
import 'src/rules/dart/unnecessary_nullable_return_type.dart';
import 'src/rules/flutter/avoid_public_members_in_states.dart';
import 'src/rules/flutter/avoid_single_child_in_flex.dart';
import 'src/rules/flutter/dispose_controllers.dart';
import 'src/rules/flutter/prefer_async_callback.dart';
import 'src/rules/flutter/prefer_border_from_border_side.dart';
import 'src/rules/flutter/prefer_border_radius_all.dart';
import 'src/rules/flutter/prefer_dedicated_media_query_functions.dart';
import 'src/rules/flutter/prefer_text_rich.dart';
import 'src/rules/flutter/prefer_void_callback.dart';
import 'src/rules/flutter/proper_edge_insets_constructors.dart';
import 'src/rules/flutter/proper_expanded_and_flexible.dart';
import 'src/rules/flutter/proper_super_dispose.dart';
import 'src/rules/flutter/proper_super_init_state.dart';
import 'src/rules/flutter/specify_icon_button_tooltip.dart';
import 'src/rules/flutter/use_spacer.dart';

final plugin = PyramidLintPlugin();

class PyramidLintPlugin extends Plugin {
  @override
  String get name => 'Pyramid Lint';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(AlwaysPutDocCommentsBeforeAnnotationsRule())
      ..registerLintRule(AlwaysSpecifyParameterNamesRule())
      ..registerLintRule(AvoidDynamicRule())
      ..registerLintRule(AvoidEmptyBlocksRule())
      ..registerLintRule(AvoidMutableGlobalVariablesRule())
      ..registerLintRule(AvoidPositionalFieldsInRecordsRule())
      ..registerLintRule(AvoidUnusedParametersRule())
      ..registerLintRule(NoDuplicateImportsRule())
      ..registerLintRule(NoSelfComparisonsRule())
      ..registerLintRule(PreferAsyncAwaitRule())
      ..registerLintRule(PreferIterableAnyRule())
      ..registerLintRule(PreferIterableEveryRule())
      ..registerLintRule(PreferIterableFirstRule())
      ..registerLintRule(PreferIterableLastRule())
      ..registerLintRule(PreferNewLineBeforeReturnRule())
      ..registerLintRule(PreferUnderscoreForUnusedCallbackParametersRule())
      ..registerLintRule(ProperFromEnvironmentRule())
      ..registerLintRule(UnnecessaryNullableReturnTypeRule());

    registry
      ..registerLintRule(AvoidPublicMembersInStatesRule())
      ..registerLintRule(AvoidSingleChildInFlexRule())
      ..registerLintRule(DisposeControllersRule())
      ..registerLintRule(PreferAsyncCallbackRule())
      ..registerLintRule(PreferBorderFromBorderSideRule())
      ..registerLintRule(PreferBorderRadiusAllRule())
      ..registerLintRule(PreferDedicatedMediaQueryFunctionsRule())
      ..registerLintRule(PreferTextRichRule())
      ..registerLintRule(PreferVoidCallbackRule())
      ..registerLintRule(ProperEdgeInsetsConstructorsRule())
      ..registerLintRule(ProperExpandedAndFlexibleRule())
      ..registerLintRule(ProperSuperDisposeRule())
      ..registerLintRule(ProperSuperInitStateRule())
      ..registerLintRule(SpecifyIconButtonTooltipRule())
      ..registerLintRule(UseSpacerRule());

    registry
      ..registerFixForRule(AlwaysPutDocCommentsBeforeAnnotationsRule.code, PutDocCommentsBeforeAnnotations.new)
      ..registerFixForRule(PreferIterableAnyRule.code, ReplaceWithIterableAny.new)
      ..registerFixForRule(PreferIterableEveryRule.code, ReplaceWithIterableEvery.new)
      ..registerFixForRule(PreferIterableFirstRule.code, ReplaceWithIterableFirst.new)
      ..registerFixForRule(PreferIterableLastRule.code, ReplaceWithIterableLast.new)
      ..registerFixForRule(PreferNewLineBeforeReturnRule.code, AddNewLineBeforeReturn.new)
      ..registerFixForRule(ProperFromEnvironmentRule.code, InvokeAsConstConstructor.new)
      ..registerFixForRule(UnnecessaryNullableReturnTypeRule.code, ReplaceWithNonNullableType.new);

    registry
      ..registerFixForRule(AvoidSingleChildInFlexRule.code, ReplaceWithAlign.new)
      ..registerFixForRule(AvoidSingleChildInFlexRule.code, ReplaceWithCenter.new)
      ..registerFixForRule(DisposeControllersRule.code, AddControllerDispose.new)
      ..registerFixForRule(PreferAsyncCallbackRule.code, ReplaceWithAsyncCallback.new)
      ..registerFixForRule(PreferBorderFromBorderSideRule.code, ReplaceWithBorderFromBorderSide.new)
      ..registerFixForRule(PreferBorderRadiusAllRule.code, ReplaceWithBorderRadiusAll.new)
      ..registerFixForRule(PreferDedicatedMediaQueryFunctionsRule.code, ReplaceWithDedicatedMediaQueryFunction.new)
      ..registerFixForRule(PreferTextRichRule.code, ReplaceWithTextRich.new)
      ..registerFixForRule(PreferVoidCallbackRule.code, ReplaceWithVoidCallback.new)
      ..registerFixForRule(ProperEdgeInsetsConstructorsRule.code, ReplaceWithProperEdgeInsets.new)
      ..registerFixForRule(ProperSuperDisposeRule.code, PlaceSuperDisposeAtTheEnd.new)
      ..registerFixForRule(ProperSuperInitStateRule.code, PlaceSuperInitStateAtTheStart.new)
      ..registerFixForRule(SpecifyIconButtonTooltipRule.code, AddTooltip.new)
      ..registerFixForRule(UseSpacerRule.code, ReplaceWithSpacer.new);

    registry.registerAssist(ConvertToForInIterableIndexedLoop.new);
  }
}
