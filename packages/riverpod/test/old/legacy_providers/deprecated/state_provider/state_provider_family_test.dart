import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/internals.dart' show ProviderElement;
import 'package:test/test.dart';

void main() {
  test('supports .name', () {
    expect(
      StateProvider.family<int, int>((ref, id) => 0)(0).name,
      null,
    );
    expect(
      StateProvider.family<int, int>((ref, id) => 0, name: 'foo')(0).name,
      'foo',
    );
  });

  group('StateProvider.family', () {
    test('specifies `from` and `argument` for related providers', () {
      final provider = StateProvider.family<AsyncValue<int>, int>(
        (ref, _) => const AsyncValue.data(42),
      );

      expect(provider(0).from, provider);
      expect(provider(0).argument, 0);
    });

    group('scoping an override overrides all the associated subproviders', () {
      test('when passing the provider itself', () async {
        final provider = StateProvider.family<int, int>(
          (ref, _) => 0,
          dependencies: const [],
        );
        final root = ProviderContainer.test();
        final container = ProviderContainer.test(
          parent: root,
          overrides: [provider],
        );

        expect(container.read(provider(0).notifier).state, 0);
        expect(container.read(provider(0)), 0);
        expect(
          container.getAllProviderElementsInOrder(),
          unorderedEquals(<Object?>[
            isA<ProviderElement>()
                .having((e) => e.origin, 'origin', provider(0)),
          ]),
        );
        expect(root.getAllProviderElementsInOrder(), isEmpty);
      });

      test('when using provider.overrideWith', () async {
        final provider = StateProvider.family<int, int>(
          (ref, _) => 0,
          dependencies: const [],
        );
        final root = ProviderContainer.test();
        final container = ProviderContainer.test(
          parent: root,
          overrides: [
            provider.overrideWith((ref, value) => 42),
          ],
        );

        expect(container.read(provider(0).notifier).state, 42);
        expect(container.read(provider(0)), 42);
        expect(root.getAllProviderElementsInOrder(), isEmpty);
        expect(
          container.getAllProviderElementsInOrder(),
          unorderedEquals(<Object?>[
            isA<ProviderElement>()
                .having((e) => e.origin, 'origin', provider(0)),
          ]),
        );
      });
    });

    test('can be auto-scoped', () async {
      final dep = Provider(
        (ref) => 0,
        dependencies: const [],
      );
      final provider = StateProvider.family<int, int>(
        (ref, i) => ref.watch(dep) + i,
        dependencies: [dep],
      );
      final root = ProviderContainer.test();
      final container = ProviderContainer.test(
        parent: root,
        overrides: [dep.overrideWithValue(42)],
      );

      expect(container.read(provider(10)), 52);
      expect(container.read(provider(10).notifier).state, 52);

      expect(root.getAllProviderElements(), isEmpty);
    });

    test('StateProviderFamily', () async {
      final provider = StateProvider.family<String, int>((ref, a) {
        return '$a';
      });
      final container = ProviderContainer.test();

      expect(container.read(provider(0)), '0');
      expect(container.read(provider(1)), '1');
    });

    test('StateProviderFamily override', () async {
      final provider = StateProvider.family<String, int>((ref, a) {
        return '$a';
      });
      final container = ProviderContainer.test(
        overrides: [
          provider.overrideWith((ref, a) => 'override $a'),
        ],
      );

      expect(container.read(provider(0)), 'override 0');
      expect(container.read(provider(1)), 'override 1');
    });
  });
}
