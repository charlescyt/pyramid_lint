import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/ast_node_extensions.dart';
import '../../utils/constants.dart';
import '../../utils/pubspec_extension.dart';
import '../../utils/type_checker.dart';

class SpecifyIconButtonTooltip extends PyramidLintRule {
  SpecifyIconButtonTooltip({required super.options})
    : super(
        name: ruleName,
        problemMessage: 'There is no tooltip specified for the icon button.',
        correctionMessage: 'Try specifying a tooltip for the icon button.',
        url: url,
        errorSeverity: ErrorSeverity.INFO,
      );

  static const ruleName = 'specify_icon_button_tooltip';
  static const url = '$flutterLintDocUrl/$ruleName';

  factory SpecifyIconButtonTooltip.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[ruleName]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(
      json: json,
      paramsConverter: (_) => null,
    );

    return SpecifyIconButtonTooltip(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!context.pubspec.isFlutterProject) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType;
      if (type == null || !iconButtonChecker.isAssignableFromType(type)) {
        return;
      }

      final tooltip = node.argumentList.findArgumentByName('tooltip');
      if (tooltip != null) return;

      reporter.atNode(
        node.constructorName,
        code,
        data: node,
      );
    });
  }

  @override
  List<Fix> getFixes() => [_AddTooltip()];
}

class _AddTooltip extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final data = analysisError.data;
    if (data is! InstanceCreationExpression) return;

    final node = data;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Add tooltip',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      final isArgumentListOnSameLine = _isNodeWithinSameLine(
        resolver.lineInfo,
        node.argumentList,
      );

      const tooltipGroupName = 'tooltip';
      const tooltipText = 'tooltip';

      final leftParenthesis = node.argumentList.leftParenthesis;

      if (isArgumentListOnSameLine) {
        builder.addInsertion(leftParenthesis.end, (builder) {
          builder.write("tooltip: '");
          builder.addSimpleLinkedEdit(tooltipGroupName, tooltipText);
          builder.write("', ");
        });
      } else {
        final hasArgument = node.argumentList.arguments.isNotEmpty;

        int indentLevel;
        if (hasArgument) {
          // Indent the tooltip to the same level as the first argument
          indentLevel = _getLineIndentLevelAtToken(
            resolver.lineInfo,
            node.argumentList.arguments.first.beginToken,
          );
        } else {
          // Indent the tooltip to the +1 level of the right parenthesis
          indentLevel =
              _getLineIndentLevelAtToken(
                resolver.lineInfo,
                node.argumentList.rightParenthesis,
              ) +
              1;
        }

        builder.addInsertion(leftParenthesis.end, (builder) {
          builder.writeln();
          builder.writeIndent(indentLevel);
          builder.write("tooltip: '");
          builder.addSimpleLinkedEdit(tooltipGroupName, tooltipText);
          builder.write("',");
        });
      }
    });
  }
}

/// Returns true if the given [node] is entirely on the same line and
/// false otherwise.
bool _isNodeWithinSameLine(LineInfo lineInfo, AstNode node) {
  return _areEntitiesOnSameLine(
    lineInfo,
    begin: node.beginToken,
    end: node.endToken,
  );
}

/// Whether the given [begin] and [end] entities are on the same line.
bool _areEntitiesOnSameLine(
  LineInfo lineInfo, {
  required SyntacticEntity begin,
  required SyntacticEntity end,
}) {
  final beginLineNumber = lineInfo.getLocation(begin.offset).lineNumber;
  final endLineNumber = lineInfo.getLocation(end.end).lineNumber;
  return beginLineNumber == endLineNumber;
}

/// Returns the indentation level of the line containing the given [token].
int _getLineIndentLevelAtToken(
  LineInfo lineInfo,
  Token token, {
  int indentSize = 2,
}) {
  final lineNumber = lineInfo.getLocation(token.offset).lineNumber;
  // Subtract lineNumber by 1 since getOffsetOfLine requires 0-based line number
  final lineOffset = lineInfo.getOffsetOfLine(lineNumber - 1);

  // Find the first token on the same line
  var currentToken = token;
  while (currentToken.previous != null &&
      currentToken.previous!.offset >= lineOffset) {
    currentToken = currentToken.previous!;
  }

  return (currentToken.offset - lineOffset) ~/ indentSize;
}
