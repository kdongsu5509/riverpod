// ignore_for_file: use_key_in_widget_constructors, omit_local_variable_types, unreachable_from_main

/* SNIPPET START */

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// {@template helloWorld}
// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
// {@endtemplate}
@riverpod
String helloWorld(Ref ref) {
  return 'Hello world';
}

void main() {
  runApp(
    // {@template ProviderScope}
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    // {@endtemplate}
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// {@template HookConsumerWidget}
// Extend HookConsumerWidget instead of HookWidget, which is exposed by Riverpod
// {@endtemplate}
class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // {@template hooksCodegen_counter}
    // We can use hooks inside HookConsumerWidget
    // {@endtemplate}
    final counter = useState(0);

    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: Center(
          child: Text('$value ${counter.value}'),
        ),
      ),
    );
  }
}
