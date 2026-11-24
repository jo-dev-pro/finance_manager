// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pensionScreenData)
const pensionScreenDataProvider = PensionScreenDataFamily._();

final class PensionScreenDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PensionAccountItem>>,
          List<PensionAccountItem>,
          FutureOr<List<PensionAccountItem>>
        >
    with
        $FutureModifier<List<PensionAccountItem>>,
        $FutureProvider<List<PensionAccountItem>> {
  const PensionScreenDataProvider._({
    required PensionScreenDataFamily super.from,
    required ({String currentYearMonth, String lastYearMonth}) super.argument,
  }) : super(
         retry: null,
         name: r'pensionScreenDataProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pensionScreenDataHash();

  @override
  String toString() {
    return r'pensionScreenDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PensionAccountItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PensionAccountItem>> create(Ref ref) {
    final argument =
        this.argument as ({String currentYearMonth, String lastYearMonth});
    return pensionScreenData(
      ref,
      currentYearMonth: argument.currentYearMonth,
      lastYearMonth: argument.lastYearMonth,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PensionScreenDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pensionScreenDataHash() => r'd5392d3e961a3b8a32ba2abe6f5b119813bc2d09';

final class PensionScreenDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PensionAccountItem>>,
          ({String currentYearMonth, String lastYearMonth})
        > {
  const PensionScreenDataFamily._()
    : super(
        retry: null,
        name: r'pensionScreenDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PensionScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) => PensionScreenDataProvider._(
    argument: (
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    ),
    from: this,
  );

  @override
  String toString() => r'pensionScreenDataProvider';
}

@ProviderFor(SelectedPensionAccountFilter)
const selectedPensionAccountFilterProvider =
    SelectedPensionAccountFilterProvider._();

final class SelectedPensionAccountFilterProvider
    extends $NotifierProvider<SelectedPensionAccountFilter, String?> {
  const SelectedPensionAccountFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPensionAccountFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPensionAccountFilterHash();

  @$internal
  @override
  SelectedPensionAccountFilter create() => SelectedPensionAccountFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedPensionAccountFilterHash() =>
    r'f2601570323d79249a61e4abfb2bf51247f2bc96';

abstract class _$SelectedPensionAccountFilter extends $Notifier<String?> {
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
