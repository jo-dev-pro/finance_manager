// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StockItemNotifier)
const stockItemProvider = StockItemNotifierProvider._();

final class StockItemNotifierProvider
    extends $AsyncNotifierProvider<StockItemNotifier, List<StockItem>> {
  const StockItemNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockItemNotifierHash();

  @$internal
  @override
  StockItemNotifier create() => StockItemNotifier();
}

String _$stockItemNotifierHash() => r'f879baa8c28c7e9928a188c941f1e710bda45671';

abstract class _$StockItemNotifier extends $AsyncNotifier<List<StockItem>> {
  FutureOr<List<StockItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<StockItem>>, List<StockItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<StockItem>>, List<StockItem>>,
              AsyncValue<List<StockItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
