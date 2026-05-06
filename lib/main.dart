import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/dart/always_specify_parameter_names.dart';
import 'src/rules/dart/avoid_dynamic.dart';
import 'src/rules/dart/avoid_mutable_global_variables.dart';
import 'src/rules/dart/prefer_async_await.dart';
import 'src/rules/dart/prefer_new_line_before_return.dart';

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
      ..registerLintRule(PreferAsyncAwaitRule())
      ..registerLintRule(PreferNewLineBeforeReturnRule())
      ..registerFixForRule(PreferNewLineBeforeReturnRule.code, AddNewLineBeforeReturn.new);
  }
}
