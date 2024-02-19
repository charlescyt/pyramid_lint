import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/dart_type_extension.dart';
import '../../utils/visitors.dart';

class UnnecessaryNullableReturnType extends PyramidLintRule {
  UnnecessaryNullableReturnType({required super.options})
      : super(
          name: ruleName,
          problemMessage: 'The nullable return type is unnecessary.',
          correctionMessage: 'Consider using non-nullable return type.',
          url: url,
          errorSeverity: ErrorSeverity.WARNING,
        );

  static const ruleName = 'unnecessary_nullable_return_type';
  static const url = '$dartLintDocUrl/$ruleName';

  factory UnnecessaryNullableReturnType.fromConfigs(
    CustomLintConfigs configs,
  ) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return UnnecessaryNullableReturnType(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType;
      if (returnType == null) return;

      final questionToken = returnType.question;
      if (questionToken == null) return;

      final body = node.functionExpression.body;

      if (body is BlockFunctionBody) {
        _checkBlockFunctionBody(
          reporter: reporter,
          node: body,
          returnType: returnType,
        );
      }

      if (body is ExpressionFunctionBody) {
        _checkExpressionFunctionBody(
          reporter: reporter,
          node: body,
          returnType: returnType,
        );
      }
    });

    context.registry.addMethodDeclaration((node) {
      final returnType = node.returnType;
      if (returnType == null) return;

      final questionToken = returnType.question;
      if (questionToken == null) return;

      final body = node.body;

      if (body is BlockFunctionBody) {
        _checkBlockFunctionBody(
          reporter: reporter,
          node: body,
          returnType: returnType,
        );
      }

      if (body is ExpressionFunctionBody) {
        _checkExpressionFunctionBody(
          reporter: reporter,
          node: body,
          returnType: node.returnType!,
        );
      }
    });
  }

  void _checkBlockFunctionBody({
    required ErrorReporter reporter,
    required BlockFunctionBody node,
    required TypeAnnotation returnType,
  }) {
    final visitor = RecursiveReturnStatementVisitor();
    node.visitChildren(visitor);

    final returnStatements = visitor.returnStatements;
    if (returnStatements.isEmpty) return;

    final hasNullableReturn = returnStatements.any(
      (s) => switch (s.expression?.staticType) {
        null => false,
        final type => type.isNullable,
      },
    );
    if (hasNullableReturn) return;

    reporter.reportErrorForNode(code, returnType);
  }

  void _checkExpressionFunctionBody({
    required ErrorReporter reporter,
    required ExpressionFunctionBody node,
    required TypeAnnotation returnType,
  }) {
    final type = node.expression.staticType;
    if (type == null || type.isNullable) return;

    reporter.reportErrorForNode(code, returnType);
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithNonNullableType()];
}

class _ReplaceWithNonNullableType extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFunctionDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final questionToken = node.returnType?.question;
      if (questionToken == null) return;

      _deleteQuestionToken(
        reporter: reporter,
        returnType: node.returnType!,
        questionToken: questionToken,
      );
    });

    context.registry.addMethodDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final questionToken = node.returnType?.question;
      if (questionToken == null) return;

      _deleteQuestionToken(
        reporter: reporter,
        returnType: node.returnType!,
        questionToken: questionToken,
      );
    });
  }

  void _deleteQuestionToken({
    required ChangeReporter reporter,
    required TypeAnnotation returnType,
    required Token questionToken,
  }) {
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Replace with non-nullable type',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addDeletion(questionToken.sourceRange);
    });
  }
}
