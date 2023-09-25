import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';

extension ArgumentListExtensions on ArgumentList {
  /// Returns the named argument with the name child in this [ArgumentList], or
  /// `null` if there is none.
  NamedExpression? get childArgument {
    return getArgumentByName('child');
  }

  /// Returns the named argument with the name children in this [ArgumentList],
  /// or `null` if there is none.
  NamedExpression? get childrenArgument {
    return getArgumentByName('children');
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
  NamedExpression? getArgumentByName(String name) {
    return namedArguments.firstWhereOrNull((e) => e.name.label.name == name);
  }
}
