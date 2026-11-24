// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MonthlyPensionBalanceNotifier)
const monthlyPensionBalanceProvider = MonthlyPensionBalanceNotifierFamily._();

final class MonthlyPensionBalanceNotifierProvider
    extends
        $AsyncNotifierProvider<
          MonthlyPensionBalanceNotifier,
          List<MonthlyPensionBalance>
        > {
  const MonthlyPensionBalanceNotifierProvider._({
    required MonthlyPensionBalanceNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyPensionBalanceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyPensionBalanceNotifierHash();

  @override
  String toString() {
    return r'monthlyPensionBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MonthlyPensionBalanceNotifier create() => MonthlyPensionBalanceNotifier();

  @override
  bool operator ==(Object other) {
    return other is MonthlyPensionBalanceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyPensionBalanceNotifierHash() =>
    r'd8d2a4be2aaf49ff23d9af478ca70623df25d513';

final class MonthlyPensionBalanceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyPensionBalanceNotifier,
          AsyncValue<List<MonthlyPensionBalance>>,
          List<MonthlyPensionBalance>,
          FutureOr<List<MonthlyPensionBalance>>,
          String
        > {
  const MonthlyPensionBalanceNotifierFamily._()
    : super(
        retry: null,
        name: r'monthlyPensionBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MonthlyPensionBalanceNotifierProvider call(String yearMonth) =>
      MonthlyPensionBalanceNotifierProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthlyPensionBalanceProvider';
}

abstract class _$MonthlyPensionBalanceNotifier
    extends $AsyncNotifier<List<MonthlyPensionBalance>> {
  late final _$args = ref.$arg as String;
  String get yearMonth => _$args;

  FutureOr<List<MonthlyPensionBalance>> build(String yearMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyPensionBalance>>,
              List<MonthlyPensionBalance>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyPensionBalance>>,
                List<MonthlyPensionBalance>
              >,
              AsyncValue<List<MonthlyPensionBalance>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AllMonthlyPensionBalances)
const allMonthlyPensionBalancesProvider = AllMonthlyPensionBalancesProvider._();

final class AllMonthlyPensionBalancesProvider
    extends
        $AsyncNotifierProvider<
          AllMonthlyPensionBalances,
          List<MonthlyPensionBalanceWithDetail>
        > {
  const AllMonthlyPensionBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMonthlyPensionBalancesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMonthlyPensionBalancesHash();

  @$internal
  @override
  AllMonthlyPensionBalances create() => AllMonthlyPensionBalances();
}

String _$allMonthlyPensionBalancesHash() =>
    r'a2f625b8d1eb45e2b23f22203f70f9e218868bc1';

abstract class _$AllMonthlyPensionBalances
    extends $AsyncNotifier<List<MonthlyPensionBalanceWithDetail>> {
  FutureOr<List<MonthlyPensionBalanceWithDetail>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyPensionBalanceWithDetail>>,
              List<MonthlyPensionBalanceWithDetail>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyPensionBalanceWithDetail>>,
                List<MonthlyPensionBalanceWithDetail>
              >,
              AsyncValue<List<MonthlyPensionBalanceWithDetail>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
