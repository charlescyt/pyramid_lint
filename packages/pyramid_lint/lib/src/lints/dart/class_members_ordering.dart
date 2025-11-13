import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../../pyramid_lint_rule.dart';
import '../../utils/constants.dart';
import '../../utils/type_checker.dart';

class ClassMembersOrdering extends PyramidLintRule {
  ClassMembersOrdering({required super.options})
    : super(
        name: name,
        problemMessage: 'Incorrect order of {0}.',
        correctionMessage: 'Consider putting {0} {1} {2}.',
        url: url,
        errorSeverity: DiagnosticSeverity.INFO,
      );

  static const name = 'class_members_ordering';
  static const url = '$dartLintDocUrl#$name';

  factory ClassMembersOrdering.fromConfigs(CustomLintConfigs configs) {
    final json = configs.rules[name]?.json ?? {};
    final options = PyramidLintRuleOptions.fromJson(json: json, paramsConverter: (_) => null);

    return ClassMembersOrdering(options: options);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final members = node.members;
      if (members.isEmpty || members.length == 1) return;

      final comparator = _isWidget(node) ? _compareMembersInWidget : _compareMembersInClass;

      for (var i = 0; i < members.length; i++) {
        final current = members[i];
        final previous = i > 0 ? members[i - 1] : null;
        final next = i < members.length - 1 ? members[i + 1] : null;

        if (previous != null && comparator(current.type, previous.type) < 0) {
          reporter.atNode(current, code, arguments: [current.type.label, 'before', previous.type.label]);
        }

        if (next != null && comparator(current.type, next.type) > 0) {
          reporter.atNode(current, code, arguments: [current.type.label, 'after', next.type.label]);
        }
      }
    });
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

extension on ClassMember {
  bool get isPrivate {
    return switch (this) {
      FieldDeclaration(:final fields) => fields.variables.any((e) => e.name.lexeme.startsWith('_')),
      ConstructorDeclaration(:final name) => name?.lexeme.startsWith('_') == true,
      MethodDeclaration(:final name) => name.lexeme.startsWith('_'),
    };
  }

  _MemberType get type {
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
