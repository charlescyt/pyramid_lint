import 'package:analyzer/dart/ast/ast.dart';

extension ConstructorInitializersExtensions
    on NodeList<ConstructorInitializer> {
  /// Returns the constructor field initializers in this list.
  Iterable<ConstructorFieldInitializer> get constructorFieldInitializers =>
      whereType<ConstructorFieldInitializer>();

  /// Returns the super constructor invocations in this list.
  Iterable<RedirectingConstructorInvocation>
      get redirectingConstructorInvocations =>
          whereType<RedirectingConstructorInvocation>();

  /// Returns the super constructor invocations in this list.
  Iterable<SuperConstructorInvocation> get superConstructorInvocations =>
      whereType<SuperConstructorInvocation>();
}
