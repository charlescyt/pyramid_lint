import 'package:analyzer/dart/ast/ast.dart';

extension ConstructorInitializersExtensions
    on NodeList<ConstructorInitializer> {
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
