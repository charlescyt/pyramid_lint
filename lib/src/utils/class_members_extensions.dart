import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

extension ClassMembersExtensions on NodeList<ClassMember> {
  /// Returns the constructor declarations in this list.
  Iterable<ConstructorDeclaration> get constructorDeclarations {
    return whereType<ConstructorDeclaration>();
  }

  /// Returns the method declarations in this list.
  Iterable<MethodDeclaration> get methodDeclarations {
    return whereType<MethodDeclaration>();
  }

  /// Returns the field declarations in this list.
  Iterable<FieldDeclaration> get fieldDeclarations {
    return whereType<FieldDeclaration>();
  }

  /// Returns the first [ConstructorDeclaration] with the given [name], or
  /// `null` if there are none.
  ConstructorDeclaration? getConstructorDeclarationByName(String name) {
    return constructorDeclarations
        .firstWhereOrNull((e) => e.name?.lexeme == name);
  }

  /// Returns the first [MethodDeclaration] with the given [name], or `null` if
  /// there are none.
  MethodDeclaration? getMethodDeclarationByName(String name) {
    return methodDeclarations.firstWhereOrNull((e) => e.name.lexeme == name);
  }

  /// Returns the first [FieldDeclaration] with the given [name], or `null` if
  /// there are none.
  FieldDeclaration? getFieldDeclarationByName(String name) {
    return fieldDeclarations.firstWhereOrNull(
      (e) => e.fields.variables.first.name.lexeme == name,
    );
  }
}
