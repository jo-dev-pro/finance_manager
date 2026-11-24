// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_holding_product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PensionHoldingProductNotifier)
const pensionHoldingProductProvider = PensionHoldingProductNotifierProvider._();

final class PensionHoldingProductNotifierProvider
    extends
        $AsyncNotifierProvider<
          PensionHoldingProductNotifier,
          List<PensionHoldingProduct>
        > {
  const PensionHoldingProductNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pensionHoldingProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pensionHoldingProductNotifierHash();

  @$internal
  @override
  PensionHoldingProductNotifier create() => PensionHoldingProductNotifier();
}

String _$pensionHoldingProductNotifierHash() =>
    r'a2455cefe190e7de42ca67cabd3ddcc6a70fd9eb';

abstract class _$PensionHoldingProductNotifier
    extends $AsyncNotifier<List<PensionHoldingProduct>> {
  FutureOr<List<PensionHoldingProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PensionHoldingProduct>>,
              List<PensionHoldingProduct>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PensionHoldingProduct>>,
                List<PensionHoldingProduct>
              >,
              AsyncValue<List<PensionHoldingProduct>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
