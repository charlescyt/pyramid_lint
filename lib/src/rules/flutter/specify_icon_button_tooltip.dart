import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../../utils/extensions/ast.dart';
import '../../utils/type_checker.dart';

class SpecifyIconButtonTooltipRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'specify_icon_button_tooltip',
    'There is no tooltip specified for the icon button.',
    correctionMessage: 'Try specifying a tooltip for the icon button.',
    severity: DiagnosticSeverity.INFO,
  );

  SpecifyIconButtonTooltipRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type == null || !iconButtonChecker.isAssignableFromType(type)) return;

    if (node.argumentList.getArgumentByName('tooltip') != null) return;

    rule.reportAtNode(node.constructorName);
  }
}

class AddTooltip extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.addTooltip',
    DartFixKindPriority.standard,
    'Add tooltip',
  );

  static const _tooltipGroupName = 'tooltip';
  static const _defaultTooltip = 'tooltip';

  AddTooltip({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final instanceCreation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (instanceCreation == null) return;

    final argumentList = instanceCreation.argumentList;
    final multiline = _isMultiline(argumentList);

    await builder.addDartFileEdit(file, (fileEdit) {
      fileEdit.addInsertion(argumentList.leftParenthesis.end, (edit) {
        if (multiline) {
          edit.writeln();
          edit.write(_indentForTooltip(argumentList));
        }
        edit.write("tooltip: '");
        edit.addSimpleLinkedEdit(_tooltipGroupName, _defaultTooltip);
        edit.write("'");
        if (argumentList.arguments.isNotEmpty) {
          edit.write(multiline ? ',' : ', ');
        }
      });
    });
  }

  bool _isMultiline(ArgumentList argumentList) {
    return utils.getLineThis(argumentList.offset) != utils.getLineThis(argumentList.end);
  }

  String _indentForTooltip(ArgumentList argumentList) {
    if (argumentList.arguments.isNotEmpty) {
      return utils.getNodePrefix(argumentList.arguments.first);
    }
    return '${utils.getPrefix(argumentList.end)}${utils.oneIndent}';
  }
}
