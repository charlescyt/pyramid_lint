import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

extension ClassMembersExtensions on NodeList<ClassMember> {
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
  ConstructorDeclaration? getConstructorDeclarationByName(String name) {
    return constructorDeclarations
        .firstWhereOrNull((e) => e.name?.lexeme == name);
  }

  /// Returns the first [MethodDeclaration] with the given [name], or `null` if
  /// there is none.
  MethodDeclaration? getMethodDeclarationByName(String name) {
    return methodDeclarations.firstWhereOrNull((e) => e.name.lexeme == name);
  }

  /// Returns the first [FieldDeclaration] with the given [name], or `null` if
  /// there is none.
  FieldDeclaration? getFieldDeclarationByName(String name) {
    return fieldDeclarations.firstWhereOrNull(
      (e) => e.fields.variables.first.name.lexeme == name,
    );
  }
}
