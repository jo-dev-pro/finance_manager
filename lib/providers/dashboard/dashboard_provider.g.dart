// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(availableYearMonths)
const availableYearMonthsProvider = AvailableYearMonthsProvider._();

final class AvailableYearMonthsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  const AvailableYearMonthsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableYearMonthsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableYearMonthsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return availableYearMonths(ref);
  }
}

String _$availableYearMonthsHash() =>
    r'58cfae7bb06b3f621b74a40308bccb4667821194';

@ProviderFor(SelectedYearMonth)
const selectedYearMonthProvider = SelectedYearMonthProvider._();

final class SelectedYearMonthProvider
    extends $NotifierProvider<SelectedYearMonth, String?> {
  const SelectedYearMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedYearMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedYearMonthHash();

  @$internal
  @override
  SelectedYearMonth create() => SelectedYearMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedYearMonthHash() => r'85133661c1bd2b752288cf9e7f89dacb96847f79';

abstract class _$SelectedYearMonth extends $Notifier<String?> {
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

@ProviderFor(dashboardSummary)
const dashboardSummaryProvider = DashboardSummaryProvider._();

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          FutureOr<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $FutureProvider<DashboardSummary> {
  const DashboardSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSummaryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSummaryHash();

  @$internal
  @override
  $FutureProviderElement<DashboardSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardSummary> create(Ref ref) {
    return dashboardSummary(ref);
  }
}

String _$dashboardSummaryHash() => r'26bd3cc92c3816bb2e048d1891ef7aa6d67712e2';
