// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_holding_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StockHoldingItemNotifier)
const stockHoldingItemProvider = StockHoldingItemNotifierProvider._();

final class StockHoldingItemNotifierProvider
    extends
        $AsyncNotifierProvider<
          StockHoldingItemNotifier,
          List<StockHoldingItem>
        > {
  const StockHoldingItemNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockHoldingItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockHoldingItemNotifierHash();

  @$internal
  @override
  StockHoldingItemNotifier create() => StockHoldingItemNotifier();
}

String _$stockHoldingItemNotifierHash() =>
    r'4d6186d5f8b7e8ca9b16aae5040de4d4f8f022b3';

abstract class _$StockHoldingItemNotifier
    extends $AsyncNotifier<List<StockHoldingItem>> {
  FutureOr<List<StockHoldingItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<StockHoldingItem>>, List<StockHoldingItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<StockHoldingItem>>,
                List<StockHoldingItem>
              >,
              AsyncValue<List<StockHoldingItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
