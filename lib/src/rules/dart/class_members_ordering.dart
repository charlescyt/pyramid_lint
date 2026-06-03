import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../utils/type_checker.dart';

class ClassMembersOrderingRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'class_members_ordering',
    'Incorrect order of {0}.',
    correctionMessage: 'Consider putting {0} {1} {2}.',
    severity: DiagnosticSeverity.INFO,
  );

  ClassMembersOrderingRule()
    : super(
        name: code.lowerCaseName,
        description: code.problemMessage,
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  const _Visitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final classBody = node.body;
    if (classBody is! BlockClassBody) return;

    final members = classBody.members;
    if (members.isEmpty || members.length == 1) return;

    final comparator = _isWidget(node) ? _compareMembersInWidget : _compareMembersInClass;

    for (var i = 0; i < members.length; i++) {
      final current = members[i];
      final previous = i > 0 ? members[i - 1] : null;
      final next = i < members.length - 1 ? members[i + 1] : null;

      if (previous != null && comparator(current.memberType, previous.memberType) < 0) {
        rule.reportAtNode(current, arguments: [current.memberType.label, 'before', previous.memberType.label]);
      }

      if (next != null && comparator(current.memberType, next.memberType) > 0) {
        rule.reportAtNode(current, arguments: [current.memberType.label, 'after', next.memberType.label]);
      }
    }
  }

  bool _isWidget(ClassDeclaration node) {
    final extendClause = node.extendsClause;
    if (extendClause == null) return false;

    final type = extendClause.superclass.type;
    if (type == null) return false;

    return widgetOrStateChecker.isAssignableFromType(type);
  }
}

enum _MemberType implements Comparable<_MemberType> {
  publicStaticFields(11),
  privateStaticFields(12),
  publicFields(13),
  privateFields(14),
  publicConstructors(1),
  publicNamedConstructors(2),
  privateConstructors(3),
  privateNamedConstructors(4),
  publicGetters(21),
  privateGetters(22),
  publicSetters(31),
  privateSetters(32),
  publicStaticMethods(41),
  publicMethods(42),
  privateStaticMethods(43),
  privateMethods(44);

  final int orderInWidget;

  const _MemberType(this.orderInWidget);

  @override
  int compareTo(_MemberType other) => index - other.index;

  String get label => switch (this) {
    publicStaticFields => 'public static fields',
    privateStaticFields => 'private static fields',
    publicFields => 'public fields',
    privateFields => 'private fields',
    publicConstructors => 'public constructors',
    publicNamedConstructors => 'public named constructors',
    privateConstructors => 'private constructors',
    privateNamedConstructors => 'private named constructors',
    publicGetters => 'public getters',
    privateGetters => 'private getters',
    publicSetters => 'public setters',
    privateSetters => 'private setters',
    publicStaticMethods => 'public static methods',
    publicMethods => 'public methods',
    privateStaticMethods => 'private static methods',
    privateMethods => 'private methods',
  };
}

extension on ConstructorDeclaration {
  bool get isNamed => name != null;
}

extension on ConstructorDeclaration {
  bool get isPrivate {
    return declaredFragment?.element.isPrivate ?? false;
  }
}

extension on FieldDeclaration {
  bool get isPrivate {
    return fields.variables.any((e) => e.declaredFragment?.element.isPrivate ?? false);
  }
}

extension on MethodDeclaration {
  bool get isPrivate {
    return declaredFragment?.element.isPrivate ?? false;
  }
}

extension on ClassMember {
  _MemberType get memberType {
    switch (this) {
      case FieldDeclaration(:final isStatic, :final isPrivate):
        if (isStatic) {
          return isPrivate ? _MemberType.privateStaticFields : _MemberType.publicStaticFields;
        }
        return isPrivate ? _MemberType.privateFields : _MemberType.publicFields;
      case ConstructorDeclaration(:final isNamed, :final isPrivate):
        if (isNamed) {
          return isPrivate ? _MemberType.privateNamedConstructors : _MemberType.publicNamedConstructors;
        }
        return isPrivate ? _MemberType.privateConstructors : _MemberType.publicConstructors;
      case PrimaryConstructorBody():
        return _MemberType.publicConstructors;
      case MethodDeclaration(:final isGetter, :final isSetter, :final isStatic, :final isPrivate):
        if (isGetter) {
          return isPrivate ? _MemberType.privateGetters : _MemberType.publicGetters;
        }
        if (isSetter) {
          return isPrivate ? _MemberType.privateSetters : _MemberType.publicSetters;
        }
        if (isStatic) {
          return isPrivate ? _MemberType.privateStaticMethods : _MemberType.publicStaticMethods;
        }

        return isPrivate ? _MemberType.privateMethods : _MemberType.publicMethods;
    }
  }
}

int _compareMembersInWidget(_MemberType a, _MemberType b) {
  return a.orderInWidget.compareTo(b.orderInWidget);
}

int _compareMembersInClass(_MemberType a, _MemberType b) {
  return a.compareTo(b);
}
