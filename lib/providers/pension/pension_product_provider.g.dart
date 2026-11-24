// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PensionProductNotifier)
const pensionProductProvider = PensionProductNotifierProvider._();

final class PensionProductNotifierProvider
    extends
        $AsyncNotifierProvider<PensionProductNotifier, List<PensionProduct>> {
  const PensionProductNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pensionProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pensionProductNotifierHash();

  @$internal
  @override
  PensionProductNotifier create() => PensionProductNotifier();
}

String _$pensionProductNotifierHash() =>
    r'ad9366a4676b81f350c59ce641f4c76c5c931a6d';

abstract class _$PensionProductNotifier
    extends $AsyncNotifier<List<PensionProduct>> {
  FutureOr<List<PensionProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PensionProduct>>, List<PensionProduct>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PensionProduct>>,
                List<PensionProduct>
              >,
              AsyncValue<List<PensionProduct>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
