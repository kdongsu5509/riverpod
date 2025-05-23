import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Utilities for [ArgumentList] to help with specific argument retrieval.
@internal
extension ArgumentListUtils on ArgumentList {
  /// Lists the positional arguments of an argument list.
  Iterable<Expression> positionalArguments() {
    return arguments.where((e) => e is! NamedExpression);
  }

  /// Lists the named arguments of an argument list.
  Iterable<NamedExpression> namedArguments() {
    return arguments.whereType<NamedExpression>();
  }

  NamedExpression? named(String name) {
    return namedArguments().firstWhereOrNull((e) => e.name.label.name == name);
  }

  Expression? positional(int index) {
    return positionalArguments().elementAtOrNull(index);
  }
}
