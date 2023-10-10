import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AvoidDynamic extends DartLintRule {
  const AvoidDynamic() : super(code: _code);

  static const name = 'avoid_dynamic';

  static const _code = LintCode(
    name: name,
    problemMessage: 'Avoid using dynamic type.',
    correctionMessage: 'Consider specifying a type other than dynamic.',
    url: '$docUrl#${AvoidDynamic.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedType((node) {
      if (node.type is! DynamicType) return;

      if (_isNodeUsedInMap(node)) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  bool _isNodeUsedInMap(AstNode node) {
    final parent = node.parent;
    final grandParent = parent?.parent;

    if (parent is! TypeArgumentList) return false;

    if ((grandParent is NamedType && grandParent.type?.isDartCoreMap == true) ||
        (grandParent is SetOrMapLiteral && grandParent.isMap)) return true;

    return false;
  }
}
