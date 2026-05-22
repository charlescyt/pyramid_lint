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
import 'src/rules/dart/proper_from_environment.dart';
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
      ..registerLintRule(PreferIterableEveryRule())
      ..registerLintRule(PreferIterableFirstRule())
      ..registerLintRule(PreferIterableLastRule())
      ..registerLintRule(PreferNewLineBeforeReturnRule())
      ..registerLintRule(ProperFromEnvironmentRule());

    registry
      ..registerLintRule(PreferAsyncCallbackRule())
      ..registerLintRule(PreferTextRichRule())
      ..registerLintRule(PreferVoidCallbackRule())
      ..registerLintRule(ProperExpandedAndFlexibleRule())
      ..registerLintRule(UseSpacerRule());

    registry
      ..registerFixForRule(PreferIterableAnyRule.code, ReplaceWithIterableAny.new)
      ..registerFixForRule(PreferIterableEveryRule.code, ReplaceWithIterableEvery.new)
      ..registerFixForRule(PreferIterableFirstRule.code, ReplaceWithIterableFirst.new)
      ..registerFixForRule(PreferIterableLastRule.code, ReplaceWithIterableLast.new)
      ..registerFixForRule(PreferNewLineBeforeReturnRule.code, AddNewLineBeforeReturn.new)
      ..registerFixForRule(ProperFromEnvironmentRule.code, InvokeAsConstConstructor.new);

    registry
      ..registerFixForRule(PreferAsyncCallbackRule.code, ReplaceWithAsyncCallback.new)
      ..registerFixForRule(PreferTextRichRule.code, ReplaceWithTextRich.new)
      ..registerFixForRule(PreferVoidCallbackRule.code, ReplaceWithVoidCallback.new)
      ..registerFixForRule(UseSpacerRule.code, ReplaceWithSpacer.new);
  }
}
