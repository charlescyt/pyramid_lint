import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../utils/constants.dart';

const _defaultValidPrefixes = [
  'is',
  'are',
  'was',
  'were',
  'has',
  'have',
  'had',
  'can',
  'should',
  'will',
  'do',
  'does',
  'did',
];

class BooleanPrefix extends DartLintRule {
  const BooleanPrefix({
    this.validPrefixes = const [],
  }) : super(code: _code);

  static const name = 'boolean_prefix';

  static const _code = LintCode(
    name: name,
    problemMessage: '{0} should be named with a valid prefix.',
    correctionMessage: 'Try naming your {1} with a valid prefix.',
    url: '$docUrl#${BooleanPrefix.name}',
    errorSeverity: ErrorSeverity.INFO,
  );

  final List<String> validPrefixes;

  factory BooleanPrefix.fromConfigs(CustomLintConfigs configs) {
    final options = configs.rules[BooleanPrefix.name];
    final jsonList = options?.json['valid_prefixes'] as List<Object?>?;
    final validPrefixes = jsonList?.cast<String>() ?? [];

    return BooleanPrefix(
      validPrefixes: validPrefixes,
    );
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBooleanLiteral((node) {
      final parent = node.parent;
      if (parent is! VariableDeclaration) return;

      final name = parent.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        parent.name,
        [
          'Boolean variable',
          'variable',
        ],
      );
    });

    context.registry.addMethodDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;
      if (node.declaredElement?.hasOverride ?? true) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      final parameter = node.parameters;
      switch (parameter) {
        case null:
          reporter.reportErrorForToken(
            code,
            node.name,
            [
              'Getter that returns a boolean',
              'getter',
            ],
          );
        case _:
          reporter.reportErrorForToken(
            code,
            node.name,
            [
              'Method that returns a boolean',
              'method',
            ],
          );
      }
    });

    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        node.name,
        [
          'Function that returns a boolean',
          'function',
        ],
      );
    });
  }

  bool isNameValid(String name) {
    final nameWithoutUnderscore =
        name.startsWith('_') ? name.substring(1) : name;

    if (_defaultValidPrefixes.any(nameWithoutUnderscore.startsWith) ||
        validPrefixes.any(nameWithoutUnderscore.startsWith)) return true;

    return false;
  }
}
