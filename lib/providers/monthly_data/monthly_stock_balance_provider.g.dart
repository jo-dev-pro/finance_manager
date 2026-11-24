// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stock_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllMonthlyStockBalances)
const allMonthlyStockBalancesProvider = AllMonthlyStockBalancesProvider._();

final class AllMonthlyStockBalancesProvider
    extends
        $AsyncNotifierProvider<
          AllMonthlyStockBalances,
          List<MonthlyStockBalanceWithDetail>
        > {
  const AllMonthlyStockBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMonthlyStockBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMonthlyStockBalancesHash();

  @$internal
  @override
  AllMonthlyStockBalances create() => AllMonthlyStockBalances();
}

String _$allMonthlyStockBalancesHash() =>
    r'bd1b43ce6122f69615e3a365c64e7757c398488f';

abstract class _$AllMonthlyStockBalances
    extends $AsyncNotifier<List<MonthlyStockBalanceWithDetail>> {
  FutureOr<List<MonthlyStockBalanceWithDetail>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyStockBalanceWithDetail>>,
              List<MonthlyStockBalanceWithDetail>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyStockBalanceWithDetail>>,
                List<MonthlyStockBalanceWithDetail>
              >,
              AsyncValue<List<MonthlyStockBalanceWithDetail>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MonthlyStockBalanceNotifier)
const monthlyStockBalanceProvider = MonthlyStockBalanceNotifierFamily._();

final class MonthlyStockBalanceNotifierProvider
    extends
        $AsyncNotifierProvider<
          MonthlyStockBalanceNotifier,
          List<MonthlyStockBalance>
        > {
  const MonthlyStockBalanceNotifierProvider._({
    required MonthlyStockBalanceNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyStockBalanceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyStockBalanceNotifierHash();

  @override
  String toString() {
    return r'monthlyStockBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MonthlyStockBalanceNotifier create() => MonthlyStockBalanceNotifier();

  @override
  bool operator ==(Object other) {
    return other is MonthlyStockBalanceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyStockBalanceNotifierHash() =>
    r'43859f27d0d765980c4a53c284aad7c15f9242b0';

final class MonthlyStockBalanceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyStockBalanceNotifier,
          AsyncValue<List<MonthlyStockBalance>>,
          List<MonthlyStockBalance>,
          FutureOr<List<MonthlyStockBalance>>,
          String
        > {
  const MonthlyStockBalanceNotifierFamily._()
    : super(
        retry: null,
        name: r'monthlyStockBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MonthlyStockBalanceNotifierProvider call(String yearMonth) =>
      MonthlyStockBalanceNotifierProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthlyStockBalanceProvider';
}

abstract class _$MonthlyStockBalanceNotifier
    extends $AsyncNotifier<List<MonthlyStockBalance>> {
  late final _$args = ref.$arg as String;
  String get yearMonth => _$args;

  FutureOr<List<MonthlyStockBalance>> build(String yearMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyStockBalance>>,
              List<MonthlyStockBalance>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyStockBalance>>,
                List<MonthlyStockBalance>
              >,
              AsyncValue<List<MonthlyStockBalance>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
