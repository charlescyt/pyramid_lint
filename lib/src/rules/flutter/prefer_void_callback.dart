import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PreferVoidCallbackRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_void_callback',
    'There is a typedef VoidCallback defined in flutter.',
    correctionMessage: 'Consider using VoidCallback instead of void Function().',
    severity: DiagnosticSeverity.INFO,
  );

  PreferVoidCallbackRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addGenericFunctionType(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    if (!_isVoidFunctionType(node)) return;

    rule.reportAtNode(node);
  }

  bool _isVoidFunctionType(GenericFunctionType node) {
    if (node.returnType?.type is! VoidType) return false;
    if (node.parameters.parameters.isNotEmpty) return false;
    if (node.typeParameters?.typeParameters.isNotEmpty == true) return false;

    return true;
  }
}

class ReplaceWithVoidCallback extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'dart.fix.replaceWithVoidCallback',
    DartFixKindPriority.standard,
    'Replace with {0}',
  );

  ReplaceWithVoidCallback({required super.context});

  late String replacement;

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _fixKind;

  @override
  List<String>? get fixArguments => [replacement];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! GenericFunctionType) return;

    replacement = node.question == null ? 'VoidCallback' : 'VoidCallback?';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.node(node), replacement);
    });
  }
}
