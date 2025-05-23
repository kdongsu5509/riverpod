import 'package:meta/meta.dart';

import '../builder.dart';
import '../common/internal_lints.dart';
import '../common/result.dart';
import '../framework.dart';
import 'async_notifier.dart';
import 'provider.dart';

part 'notifier/orphan.dart';
part 'notifier/family.dart';

/// A base class for [$Notifier].
/// Not meant for public consumption.
@publicInCodegen
abstract class $Notifier<StateT> extends $SyncNotifierBase<StateT> {
  /// The value currently exposed by this [Notifier].
  ///
  /// If used inside [Notifier.build], may throw if the notifier is not yet initialized.
  ///
  /// Invoking the setter will notify listeners if [updateShouldNotify] returns true.
  /// By default, this will compare the previous and new value using [identical].
  ///
  /// Reading [state] if the provider is out of date (such as if one of its
  /// dependency has changed) will trigger [Notifier.build] to be re-executed.
  ///
  /// If [Notifier.build] threw, reading [state] will rethrow the exception.
  @override
  @protected
  @visibleForTesting
  StateT get state;

  /// The value currently exposed by this [Notifier].
  ///
  /// If used inside [Notifier.build], may return null if the notifier is not yet initialized.
  /// It will also return null if [Notifier.build] threw.
  ///
  /// Invoking the setter will notify listeners if [updateShouldNotify] returns true.
  /// By default, this will compare the previous and new value using [identical].
  ///
  /// Reading [stateOrNull] if the provider is out of date (such as if one of its
  /// dependency has changed) will trigger [Notifier.build] to be re-executed.
  @protected
  @visibleForTesting
  StateT? get stateOrNull {
    final element = this.element();
    if (element == null) throw StateError(uninitializedElementError);

    element.flush();
    return element.stateResult?.value;
  }

  /// A method invoked when the state exposed by this [Notifier] changes.
  /// It compares the previous and new value, and return whether listeners
  /// should be notified.
  ///
  /// By default, the previous and new value are compared using [identical]
  /// for performance reasons.
  ///
  /// Doing so ensured that doing:
  ///
  /// ```dart
  /// state = 42;
  /// state = 42;
  /// ```
  ///
  /// does not notify listeners twice.
  ///
  /// But at the same time, for very complex objects with potentially dozens
  /// if not hundreds of properties, Riverpod won't deeply compare every single
  /// value.
  ///
  /// This ensures that the comparison stays efficient for the most common scenarios.
  /// But it also means that listeners should be notified even if the
  /// previous and new values are considered "equal".
  ///
  /// If you do not want that, you can override this method to perform a deep
  /// comparison of the previous and new values.
  @override
  @visibleForOverriding
  bool updateShouldNotify(StateT previous, StateT next) {
    return !identical(previous, next);
  }
}

/// An implementation detail of `riverpod_generator`.
/// Do not use.
@publicInCodegen
abstract base class $NotifierProvider //
    <NotifierT extends $Notifier<StateT>, StateT>
    extends $ClassProvider<NotifierT, StateT, StateT, StateT> {
  /// An internal base class for [Notifier].
  ///
  /// Not meant for public consumption.
  const $NotifierProvider({
    required super.name,
    required super.from,
    required super.argument,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.isAutoDispose,
    required super.retry,
  });

  @internal
  @override
  $NotifierProviderElement<NotifierT, StateT> $createElement(
    $ProviderPointer pointer,
  ) {
    return $NotifierProviderElement(pointer);
  }
}

/// An implementation detail of `riverpod_generator`.
/// Do not use.
@internal
@publicInCodegen
class $NotifierProviderElement< //
        NotifierT extends $Notifier<StateT>,
        StateT> //
    extends $ClassProviderElement< //
        NotifierT,
        StateT,
        StateT,
        StateT> {
  /// An implementation detail of `riverpod_generator`.
  /// Do not use.
  $NotifierProviderElement(super.pointer);

  @override
  void handleError(Ref ref, Object error, StackTrace stackTrace) =>
      setStateResult($ResultError<StateT>(error, stackTrace));

  @override
  void handleValue(Ref ref, StateT created) =>
      setStateResult($ResultData(created));
}
