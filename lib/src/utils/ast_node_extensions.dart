import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

import 'visitors.dart';

extension AstNodeExtension on AstNode {
  /// Returns an iterable of all the [IfStatement] that are
  /// children of this [AstNode].
  Iterable<IfStatement> get childrenIfStatements {
    final ifStatements = <IfStatement>[];
    final visitor = RecursiveIfStatementVisitor(
      onVisitIfStatement: ifStatements.add,
    );

    visitChildren(visitor);

    return ifStatements;
  }

  /// Returns an iterable of all the [ConditionalExpression] that are
  /// children of this [AstNode].
  Iterable<ConditionalExpression> get childrenConditionalExpressions {
    final conditionalExpressions = <ConditionalExpression>[];
    final visitor = RecursiveConditionalExpressionVisitor(
      onVisitConditionalExpression: conditionalExpressions.add,
    );

    visitChildren(visitor);

    return conditionalExpressions;
  }

  /// Returns an iterable of all the [BinaryExpression] that are
  /// children of this [AstNode].
  Iterable<BinaryExpression> get childrenBinaryExpressions {
    final binaryExpressions = <BinaryExpression>[];
    final visitor = RecursiveBinaryExpressionVisitor(
      onVisitBinaryExpression: binaryExpressions.add,
    );

    visitChildren(visitor);

    return binaryExpressions;
  }
}

extension ArgumentListExtension on ArgumentList {
  /// Returns the named argument with the name child in this [ArgumentList], or
  /// `null` if there is none.
  NamedExpression? get childArgument {
    return findArgumentByName('child');
  }

  /// Returns the named argument with the name children in this [ArgumentList],
  /// or `null` if there is none.
  NamedExpression? get childrenArgument {
    return findArgumentByName('children');
  }

  /// Returns an iterable of all the named arguments in this [ArgumentList].
  Iterable<NamedExpression> get namedArguments {
    return arguments.whereType<NamedExpression>();
  }

  /// Returns an iterable of all the positional arguments in this [ArgumentList].
  Iterable<Expression> get positionalArguments {
    return arguments.where((e) => e is! NamedExpression);
  }

  /// Returns the named argument with the given [name], or `null` if there is
  /// none.
  NamedExpression? findArgumentByName(String name) {
    return namedArguments.firstWhereOrNull((e) => e.name.label.name == name);
  }
}

extension ClassMembersExtension on NodeList<ClassMember> {
  /// Returns an iterable of all the [ConstructorDeclaration] in this
  /// [ClassMember] list.
  Iterable<ConstructorDeclaration> get constructorDeclarations {
    return whereType<ConstructorDeclaration>();
  }

  /// Returns an iterable of all the [MethodDeclaration] in this [ClassMember]
  /// list.
  Iterable<MethodDeclaration> get methodDeclarations {
    return whereType<MethodDeclaration>();
  }

  /// Returns an iterable of all the [FieldDeclaration] in this [ClassMember]
  /// list.
  Iterable<FieldDeclaration> get fieldDeclarations {
    return whereType<FieldDeclaration>();
  }

  /// Returns the first [ConstructorDeclaration] with the given [name], or
  /// `null` if there is none.
  ConstructorDeclaration? findConstructorDeclarationByName(String name) {
    return constructorDeclarations
        .firstWhereOrNull((e) => e.name?.lexeme == name);
  }

  /// Returns the first [MethodDeclaration] with the given [name], or `null` if
  /// there is none.
  MethodDeclaration? findMethodDeclarationByName(String name) {
    return methodDeclarations.firstWhereOrNull((e) => e.name.lexeme == name);
  }

  /// Returns the first [FieldDeclaration] with the given [name], or `null` if
  /// there is none.
  FieldDeclaration? findFieldDeclarationByName(String name) {
    return fieldDeclarations.firstWhereOrNull(
      (e) => e.fields.variables.first.name.lexeme == name,
    );
  }
}

extension ConstructorInitializersExtension on NodeList<ConstructorInitializer> {
  /// Returns an iterable of all the [ConstructorFieldInitializer] in this
  /// [ConstructorInitializer] list.
  Iterable<ConstructorFieldInitializer> get constructorFieldInitializers =>
      whereType<ConstructorFieldInitializer>();

  /// Returns an iterable of all the [RedirectingConstructorInvocation] in this
  /// [ConstructorInitializer] list.
  Iterable<RedirectingConstructorInvocation>
      get redirectingConstructorInvocations =>
          whereType<RedirectingConstructorInvocation>();

  /// Returns an iterable of all the [SuperConstructorInvocation] in this
  /// [ConstructorInitializer] list.
  Iterable<SuperConstructorInvocation> get superConstructorInvocations =>
      whereType<SuperConstructorInvocation>();
}

extension StatementsExtension on NodeList<Statement> {
  /// Returns an iterable of all the [ExpressionStatement] in this [Statement]
  /// list.
  Iterable<ExpressionStatement> get expressionStatements {
    return whereType<ExpressionStatement>();
  }
}
