// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_bank_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allMonthlyBankBalances)
const allMonthlyBankBalancesProvider = AllMonthlyBankBalancesProvider._();

final class AllMonthlyBankBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyBankBalanceWithAccount>>,
          List<MonthlyBankBalanceWithAccount>,
          FutureOr<List<MonthlyBankBalanceWithAccount>>
        >
    with
        $FutureModifier<List<MonthlyBankBalanceWithAccount>>,
        $FutureProvider<List<MonthlyBankBalanceWithAccount>> {
  const AllMonthlyBankBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMonthlyBankBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMonthlyBankBalancesHash();

  @$internal
  @override
  $FutureProviderElement<List<MonthlyBankBalanceWithAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlyBankBalanceWithAccount>> create(Ref ref) {
    return allMonthlyBankBalances(ref);
  }
}

String _$allMonthlyBankBalancesHash() =>
    r'7283a2ad38521ca22f980d7282102b866306a9e5';

@ProviderFor(MonthlyBankBalanceNotifier)
const monthlyBankBalanceProvider = MonthlyBankBalanceNotifierFamily._();

final class MonthlyBankBalanceNotifierProvider
    extends
        $AsyncNotifierProvider<
          MonthlyBankBalanceNotifier,
          List<MonthlyBankBalance>
        > {
  const MonthlyBankBalanceNotifierProvider._({
    required MonthlyBankBalanceNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyBankBalanceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyBankBalanceNotifierHash();

  @override
  String toString() {
    return r'monthlyBankBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MonthlyBankBalanceNotifier create() => MonthlyBankBalanceNotifier();

  @override
  bool operator ==(Object other) {
    return other is MonthlyBankBalanceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyBankBalanceNotifierHash() =>
    r'38b29a61561a2e4802f4579f1c3bb00cc87995a4';

final class MonthlyBankBalanceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyBankBalanceNotifier,
          AsyncValue<List<MonthlyBankBalance>>,
          List<MonthlyBankBalance>,
          FutureOr<List<MonthlyBankBalance>>,
          String
        > {
  const MonthlyBankBalanceNotifierFamily._()
    : super(
        retry: null,
        name: r'monthlyBankBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MonthlyBankBalanceNotifierProvider call(String yearMonth) =>
      MonthlyBankBalanceNotifierProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'monthlyBankBalanceProvider';
}

abstract class _$MonthlyBankBalanceNotifier
    extends $AsyncNotifier<List<MonthlyBankBalance>> {
  late final _$args = ref.$arg as String;
  String get yearMonth => _$args;

  FutureOr<List<MonthlyBankBalance>> build(String yearMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyBankBalance>>,
              List<MonthlyBankBalance>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyBankBalance>>,
                List<MonthlyBankBalance>
              >,
              AsyncValue<List<MonthlyBankBalance>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
