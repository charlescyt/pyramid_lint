import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

class AvoidDynamic extends DartLintRule {
  const AvoidDynamic()
      : super(
          code: const LintCode(
            name: name,
            problemMessage:
                'Avoid using dynamic type as it reduces type safety and can '
                'lead to potential runtime errors.',
            correctionMessage:
                'Consider specifying a type instead of using dynamic.',
            url: url,
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  static const name = 'avoid_dynamic';
  static const url = '$dartLintDocUrl/$name';

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
