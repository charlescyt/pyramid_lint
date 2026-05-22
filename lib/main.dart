import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/dart/always_specify_parameter_names.dart';
import 'src/rules/dart/avoid_dynamic.dart';
import 'src/rules/dart/avoid_mutable_global_variables.dart';
import 'src/rules/dart/avoid_positional_fields_in_records.dart';
import 'src/rules/dart/no_duplicate_imports.dart';
import 'src/rules/dart/no_self_comparisons.dart';
import 'src/rules/dart/prefer_async_await.dart';
import 'src/rules/dart/prefer_iterable_any.dart';
import 'src/rules/dart/prefer_iterable_every.dart';
import 'src/rules/dart/prefer_iterable_first.dart';
import 'src/rules/dart/prefer_iterable_last.dart';
import 'src/rules/dart/prefer_new_line_before_return.dart';
import 'src/rules/flutter/prefer_async_callback.dart';
import 'src/rules/flutter/prefer_text_rich.dart';
import 'src/rules/flutter/prefer_void_callback.dart';
import 'src/rules/flutter/proper_expanded_and_flexible.dart';
import 'src/rules/flutter/use_spacer.dart';

final plugin = PyramidLintPlugin();

class PyramidLintPlugin extends Plugin {
  @override
  String get name => 'Pyramid Lint';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(AlwaysSpecifyParameterNamesRule())
      ..registerLintRule(AvoidDynamicRule())
      ..registerLintRule(AvoidMutableGlobalVariablesRule())
      ..registerLintRule(AvoidPositionalFieldsInRecordsRule())
      ..registerLintRule(NoDuplicateImportsRule())
      ..registerLintRule(NoSelfComparisonsRule())
      ..registerLintRule(PreferAsyncAwaitRule())
      ..registerLintRule(PreferIterableAnyRule())
      ..registerFixForRule(PreferIterableAnyRule.code, ReplaceWithIterableAny.new)
      ..registerLintRule(PreferIterableEveryRule())
      ..registerFixForRule(PreferIterableEveryRule.code, ReplaceWithIterableEvery.new)
      ..registerLintRule(PreferIterableFirstRule())
      ..registerFixForRule(PreferIterableFirstRule.code, ReplaceWithIterableFirst.new)
      ..registerLintRule(PreferIterableLastRule())
      ..registerFixForRule(PreferIterableLastRule.code, ReplaceWithIterableLast.new)
      ..registerLintRule(PreferNewLineBeforeReturnRule())
      ..registerFixForRule(PreferNewLineBeforeReturnRule.code, AddNewLineBeforeReturn.new);

    registry
      ..registerLintRule(PreferAsyncCallbackRule())
      ..registerFixForRule(PreferAsyncCallbackRule.code, ReplaceWithAsyncCallback.new)
      ..registerLintRule(PreferTextRichRule())
      ..registerFixForRule(PreferTextRichRule.code, ReplaceWithTextRich.new)
      ..registerLintRule(PreferVoidCallbackRule())
      ..registerFixForRule(PreferVoidCallbackRule.code, ReplaceWithVoidCallback.new)
      ..registerLintRule(ProperExpandedAndFlexibleRule())
      ..registerLintRule(UseSpacerRule())
      ..registerFixForRule(UseSpacerRule.code, ReplaceWithSpacer.new);
  }
}
