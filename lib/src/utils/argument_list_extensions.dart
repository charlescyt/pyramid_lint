import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

extension ArgumentListExtensions on ArgumentList {
  /// Returns the child argument, or `null` if there are none.
  NamedExpression? get childArgument {
    return getArgumentByName('child');
  }

  /// Returns the children argument, or `null` if there are none.
  NamedExpression? get childrenArgument {
    return getArgumentByName('children');
  }

  /// Returns an iterable of named arguments from the [ArgumentList].
  Iterable<NamedExpression> get namedArguments {
    return arguments.whereType<NamedExpression>();
  }

  /// Returns an iterable of positional arguments from the [ArgumentList].
  Iterable<Expression> get positionalArguments {
    return arguments.where((e) => e is! NamedExpression);
  }

  /// Returns the named argument with the given [name], or `null` if there are
  /// none.
  NamedExpression? getArgumentByName(String name) {
    return namedArguments.firstWhereOrNull((e) => e.name.label.name == name);
  }
}
