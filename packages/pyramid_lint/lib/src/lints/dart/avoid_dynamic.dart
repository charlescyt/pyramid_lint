import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';

class AvoidDynamic extends PyramidLintRule {
  AvoidDynamic({required super.options})
    : super(
        name: ruleName,
        problemMessage:
            'Avoid using dynamic type as it reduces type safety and can '
            'lead to potential runtime errors.',
        correctionMessage: 'Consider specifying a type instead of using dynamic.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const ruleName = 'avoid_dynamic';
  static const url = '$dartLintDocUrl/$ruleName';

  factory AvoidDynamic.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return AvoidDynamic(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedType((node) {
      if (node.type is! DynamicType) return;
      if (_isUsedInMap(node)) return;

      reporter.atNode(node, code);
    });
  }

  bool _isUsedInMap(NamedType node) {
    final parent = node.parent;
    if (parent is! TypeArgumentList) return false;

    final grandParent = parent.parent;

    // Map<String, dynamic>
    // node: dynamic
    // parent: <String, dynamic>
    // grandParent: Map
    if (grandParent is NamedType && grandParent.type?.isDartCoreMap == true) {
      return true;
    }

    // <String, dynamic>{}
    // node: dynamic
    // parent: <String, dynamic>
    // grandParent: <String, dynamic>{}
    if (grandParent is SetOrMapLiteral && grandParent.isMap) {
      return true;
    }

    return false;
  }
}
