// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stockScreenData)
const stockScreenDataProvider = StockScreenDataFamily._();

final class StockScreenDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockAccountItem>>,
          List<StockAccountItem>,
          FutureOr<List<StockAccountItem>>
        >
    with
        $FutureModifier<List<StockAccountItem>>,
        $FutureProvider<List<StockAccountItem>> {
  const StockScreenDataProvider._({
    required StockScreenDataFamily super.from,
    required ({String currentYearMonth, String lastYearMonth}) super.argument,
  }) : super(
         retry: null,
         name: r'stockScreenDataProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stockScreenDataHash();

  @override
  String toString() {
    return r'stockScreenDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<StockAccountItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StockAccountItem>> create(Ref ref) {
    final argument =
        this.argument as ({String currentYearMonth, String lastYearMonth});
    return stockScreenData(
      ref,
      currentYearMonth: argument.currentYearMonth,
      lastYearMonth: argument.lastYearMonth,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StockScreenDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stockScreenDataHash() => r'fd29fe273b357a0c78814c289223da9b55728fb7';

final class StockScreenDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<StockAccountItem>>,
          ({String currentYearMonth, String lastYearMonth})
        > {
  const StockScreenDataFamily._()
    : super(
        retry: null,
        name: r'stockScreenDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  StockScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) => StockScreenDataProvider._(
    argument: (
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    ),
    from: this,
  );

  @override
  String toString() => r'stockScreenDataProvider';
}

@ProviderFor(SelectedStockAccountFilter)
const selectedStockAccountFilterProvider =
    SelectedStockAccountFilterProvider._();

final class SelectedStockAccountFilterProvider
    extends $NotifierProvider<SelectedStockAccountFilter, String?> {
  const SelectedStockAccountFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedStockAccountFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedStockAccountFilterHash();

  @$internal
  @override
  SelectedStockAccountFilter create() => SelectedStockAccountFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedStockAccountFilterHash() =>
    r'768701527ff92e800eee1bd7beb4f5de82b9b1a6';

abstract class _$SelectedStockAccountFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
