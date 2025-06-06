import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/internals.dart' show ProviderElement;
import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  group('StreamProvider.autoDispose.family', () {
    test('specifies `from` & `argument` for related providers', () {
      final provider = StreamProvider.autoDispose.family<int, int>(
        (ref, _) => Stream.value(0),
      );

      expect(provider(0).from, provider);
      expect(provider(0).argument, 0);
    });

    group('scoping an override overrides all the associated subproviders', () {
      test('when passing the provider itself', () async {
        final provider = StreamProvider.autoDispose.family<int, int>(
          (ref, _) => Stream.value(0),
          dependencies: const [],
        );
        final root = ProviderContainer.test();
        final container = ProviderContainer.test(
          parent: root,
          overrides: [provider],
        );

        container.listen(provider(0), (p, n) {});

        expect(await container.read(provider(0).future), 0);
        expect(container.read(provider(0)), const AsyncData(0));
        expect(root.getAllProviderElements(), isEmpty);
        expect(
          container.getAllProviderElements(),
          unorderedEquals(<Object?>[
            isA<ProviderElement>()
                .having((e) => e.origin, 'origin', provider(0)),
          ]),
        );
      });
    });

    test('override', () async {
      final provider = StreamProvider.autoDispose.family<int, int>((ref, a) {
        return Stream.value(a * 2);
      });
      final container = ProviderContainer.test();
      final listener = Listener<AsyncValue<int>>();

      container.listen(provider(21), listener.call, fireImmediately: true);

      verifyOnly(listener, listener(null, const AsyncValue.loading()));

      await container.pump();

      verifyOnly(
        listener,
        listener(const AsyncValue.loading(), const AsyncValue.data(42)),
      );
    });

    test('overrideWith', () async {
      final provider = StreamProvider.autoDispose.family<int, int>((ref, a) {
        return Stream.value(a * 2);
      });
      final container = ProviderContainer(
        overrides: [
          provider.overrideWith((ref, a) => Stream.value(a * 4)),
        ],
      );
      final listener = Listener<AsyncValue<int>>();

      container.listen(provider(21), listener.call, fireImmediately: true);

      verifyOnly(listener, listener(null, const AsyncValue.loading()));

      await container.pump();

      verifyOnly(
        listener,
        listener(
          const AsyncLoading(),
          const AsyncValue.data(84),
        ),
      );
    });

    test('can be auto-scoped', () async {
      final dep = Provider(
        (ref) => 0,
        dependencies: const [],
      );
      final provider = StreamProvider.autoDispose.family<int, int>(
        (ref, i) => Stream.value(ref.watch(dep) + i),
        dependencies: [dep],
      );
      final root = ProviderContainer.test();
      final container = ProviderContainer.test(
        parent: root,
        overrides: [dep.overrideWithValue(42)],
      );

      container.listen(provider(10), (p, n) {});

      await expectLater(container.read(provider(10).future), completion(52));
      expect(container.read(provider(10)), const AsyncData(52));

      expect(root.getAllProviderElements(), isEmpty);
    });
  });
}
