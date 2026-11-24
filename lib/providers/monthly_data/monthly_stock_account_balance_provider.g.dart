// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stock_account_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllMonthlyStockAccountBalances)
const allMonthlyStockAccountBalancesProvider =
    AllMonthlyStockAccountBalancesProvider._();

final class AllMonthlyStockAccountBalancesProvider
    extends
        $AsyncNotifierProvider<
          AllMonthlyStockAccountBalances,
          List<MonthlyStockAccountBalanceWithDetail>
        > {
  const AllMonthlyStockAccountBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMonthlyStockAccountBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMonthlyStockAccountBalancesHash();

  @$internal
  @override
  AllMonthlyStockAccountBalances create() => AllMonthlyStockAccountBalances();
}

String _$allMonthlyStockAccountBalancesHash() =>
    r'38fc27bb44c650926424d5ad1ac648c0e6abb2aa';

abstract class _$AllMonthlyStockAccountBalances
    extends $AsyncNotifier<List<MonthlyStockAccountBalanceWithDetail>> {
  FutureOr<List<MonthlyStockAccountBalanceWithDetail>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyStockAccountBalanceWithDetail>>,
              List<MonthlyStockAccountBalanceWithDetail>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyStockAccountBalanceWithDetail>>,
                List<MonthlyStockAccountBalanceWithDetail>
              >,
              AsyncValue<List<MonthlyStockAccountBalanceWithDetail>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MonthlyStockAccountBalanceNotifier)
const monthlyStockAccountBalanceProvider =
    MonthlyStockAccountBalanceNotifierFamily._();

final class MonthlyStockAccountBalanceNotifierProvider
    extends
        $AsyncNotifierProvider<
          MonthlyStockAccountBalanceNotifier,
          List<MonthlyStockAccountBalance>
        > {
  const MonthlyStockAccountBalanceNotifierProvider._({
    required MonthlyStockAccountBalanceNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyStockAccountBalanceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$monthlyStockAccountBalanceNotifierHash();

  @override
  String toString() {
    return r'monthlyStockAccountBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MonthlyStockAccountBalanceNotifier create() =>
      MonthlyStockAccountBalanceNotifier();

  @override
  bool operator ==(Object other) {
    return other is MonthlyStockAccountBalanceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyStockAccountBalanceNotifierHash() =>
    r'ff444bf7895bcb47fb95b7c825eba6fbf52ddaf6';

final class MonthlyStockAccountBalanceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyStockAccountBalanceNotifier,
          AsyncValue<List<MonthlyStockAccountBalance>>,
          List<MonthlyStockAccountBalance>,
          FutureOr<List<MonthlyStockAccountBalance>>,
          String
        > {
  const MonthlyStockAccountBalanceNotifierFamily._()
    : super(
        retry: null,
        name: r'monthlyStockAccountBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MonthlyStockAccountBalanceNotifierProvider call(String yearMonth) =>
      MonthlyStockAccountBalanceNotifierProvider._(
        argument: yearMonth,
        from: this,
      );

  @override
  String toString() => r'monthlyStockAccountBalanceProvider';
}

abstract class _$MonthlyStockAccountBalanceNotifier
    extends $AsyncNotifier<List<MonthlyStockAccountBalance>> {
  late final _$args = ref.$arg as String;
  String get yearMonth => _$args;

  FutureOr<List<MonthlyStockAccountBalance>> build(String yearMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyStockAccountBalance>>,
              List<MonthlyStockAccountBalance>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyStockAccountBalance>>,
                List<MonthlyStockAccountBalance>
              >,
              AsyncValue<List<MonthlyStockAccountBalance>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
