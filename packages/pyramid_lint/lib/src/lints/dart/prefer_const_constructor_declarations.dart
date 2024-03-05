import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';

class PreferConstConstructorDeclarations extends PyramidLintRule {
  PreferConstConstructorDeclarations({required super.options})
      : super(
          name: ruleName,
          problemMessage:
              'Constructors should be declared as const constructors when possible.',
          correctionMessage:
              'Consider adding a const keyword to the constructor.',
          url: url,
          errorSeverity: ErrorSeverity.INFO,
        );

  static const ruleName = 'prefer_const_constructor_declarations';
  static const url = '$dartLintDocUrl/$ruleName';

  factory PreferConstConstructorDeclarations.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return PreferConstConstructorDeclarations(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addConstructorDeclaration((node) {
      if (node.constKeyword != null || node.factoryKeyword != null) return;

      final parent = node.parent;
      if (parent is! ClassDeclaration) return;

      if (!_areAllFieldsFinal(parent)) return;
      if (!_areAllRedirectingConstructorInvocationsConst(node)) return;
      if (!_areAllSuperConstructorInvocationsConst(node)) return;

      // TODO(charlescyt): need to check if the super constructor is a const constructor when using super parameters.
      final superParameters =
          node.parameters.parameters.whereType<SuperFormalParameter>();
      if (superParameters.isNotEmpty) return;

      final fieldInitializers = node.initializers.constructorFieldInitializers;
      if (fieldInitializers.isNotEmpty) {
        final allExpressionResolveToConstant = fieldInitializers.every(
          (e) {
            // TODO(charlescyt): find a better way to check if the expression resolves to a constant value.
            if (e.expression is BooleanLiteral ||
                e.expression is DoubleLiteral ||
                e.expression is IntegerLiteral ||
                e.expression is StringLiteral) {
              return true;
            } else {
              return e.expression.inConstantContext;
            }
          },
        );

        if (!allExpressionResolveToConstant) return;
      }

      reporter.reportErrorForNode(code, node);
    });
  }

  bool _areAllFieldsFinal(ClassDeclaration node) {
    return node.members.fieldDeclarations.every((e) => e.fields.isFinal);
  }

  bool _areAllRedirectingConstructorInvocationsConst(
    ConstructorDeclaration node,
  ) {
    return node.initializers.redirectingConstructorInvocations
        .every((e) => e.staticElement?.isConst == true);
  }

  bool _areAllSuperConstructorInvocationsConst(
    ConstructorDeclaration node,
  ) {
    return node.initializers.superConstructorInvocations
        .every((e) => e.staticElement?.isConst == true);
  }

  @override
  List<Fix> getFixes() => [_AddConst()];
}

class _AddConst extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addConstructorDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add const keyword',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(
          node.offset,
          'const ',
        );
      });
    });
  }
}
