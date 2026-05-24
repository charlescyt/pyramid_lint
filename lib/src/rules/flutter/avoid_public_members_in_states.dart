import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/type_checker.dart';

class AvoidPublicMembersInStatesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_public_members_in_states',
    'Avoid public members in widget state classes.',
    correctionMessage: 'Consider using private members.',
    severity: DiagnosticSeverity.INFO,
  );

  AvoidPublicMembersInStatesRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addFieldDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!_isStateClassMember(node)) return;
    if (_shouldIgnoreMember(node.metadata)) return;

    _checkMethodDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!_isStateClassMember(node)) return;
    if (_shouldIgnoreMember(node.metadata)) return;

    _checkFieldDeclaration(node);
  }

  bool _isStateClassMember(ClassMember member) {
    final classDeclaration = member.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration == null) return false;

    final superClass = classDeclaration.extendsClause?.superclass;
    if (superClass == null) return false;

    final type = superClass.type;
    return type != null && stateChecker.isAssignableFromType(type);
  }

  bool _shouldIgnoreMember(NodeList<Annotation> metadata) {
    return metadata.any((annotation) {
      final elementAnnotation = annotation.elementAnnotation;
      if (elementAnnotation == null) return false;
      if (elementAnnotation.isOverride) return true;
      if (elementAnnotation.isVisibleForTesting) return true;

      return false;
    });
  }

  void _checkMethodDeclaration(MethodDeclaration methodDeclaration) {
    if (methodDeclaration.isStatic) return;

    final element = methodDeclaration.declaredFragment?.element;
    if (element == null) return;
    if (element.isPrivate) return;

    rule.reportAtToken(methodDeclaration.name);
  }

  void _checkFieldDeclaration(FieldDeclaration fieldDeclaration) {
    if (fieldDeclaration.isStatic) return;

    for (final variable in fieldDeclaration.fields.variables) {
      final element = variable.declaredFragment?.element;
      if (element == null) return;
      if (element.isPrivate) return;

      rule.reportAtToken(variable.name);
    }
  }
}
