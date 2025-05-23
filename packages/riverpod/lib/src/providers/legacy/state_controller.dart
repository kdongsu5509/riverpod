@publicInLegacy
library;

import 'package:state_notifier/state_notifier.dart';

import '../../common/internal_lints.dart';

/// A [StateNotifier] that allows modifying its [state] from outside.
///
/// This avoids having to make a [StateNotifier] subclass for simple scenarios.
class StateController<StateT> extends StateNotifier<StateT> {
  /// Initialize the state of [StateController].
  StateController(super._state);

  // Remove the protected status
  @override
  StateT get state => super.state;

  @override
  set state(StateT value) => super.state = value;

  /// Calls a function with the current [state] and assigns the result as the
  /// new state.
  ///
  /// This allows simplifying the syntax for updating the state when the update
  /// depends on the previous state, such that rather than:
  ///
  /// ```dart
  /// ref.read(provider.notifier).state = ref.read(provider.notifier).state + 1;
  /// ```
  ///
  /// we can do:
  ///
  /// ```dart
  /// ref.read(provider.notifier).update((state) => state + 1);
  /// ```
  StateT update(StateT Function(StateT state) cb) => state = cb(state);
}
