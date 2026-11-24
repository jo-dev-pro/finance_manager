// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_account_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MonthlyPensionAccountBalanceNotifier)
const monthlyPensionAccountBalanceProvider =
    MonthlyPensionAccountBalanceNotifierFamily._();

final class MonthlyPensionAccountBalanceNotifierProvider
    extends
        $AsyncNotifierProvider<
          MonthlyPensionAccountBalanceNotifier,
          List<MonthlyPensionAccountBalance>
        > {
  const MonthlyPensionAccountBalanceNotifierProvider._({
    required MonthlyPensionAccountBalanceNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyPensionAccountBalanceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$monthlyPensionAccountBalanceNotifierHash();

  @override
  String toString() {
    return r'monthlyPensionAccountBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MonthlyPensionAccountBalanceNotifier create() =>
      MonthlyPensionAccountBalanceNotifier();

  @override
  bool operator ==(Object other) {
    return other is MonthlyPensionAccountBalanceNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyPensionAccountBalanceNotifierHash() =>
    r'0edd30eafa58f2d61885f4ffa752c9911e9cc37f';

final class MonthlyPensionAccountBalanceNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyPensionAccountBalanceNotifier,
          AsyncValue<List<MonthlyPensionAccountBalance>>,
          List<MonthlyPensionAccountBalance>,
          FutureOr<List<MonthlyPensionAccountBalance>>,
          String
        > {
  const MonthlyPensionAccountBalanceNotifierFamily._()
    : super(
        retry: null,
        name: r'monthlyPensionAccountBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MonthlyPensionAccountBalanceNotifierProvider call(String yearMonth) =>
      MonthlyPensionAccountBalanceNotifierProvider._(
        argument: yearMonth,
        from: this,
      );

  @override
  String toString() => r'monthlyPensionAccountBalanceProvider';
}

abstract class _$MonthlyPensionAccountBalanceNotifier
    extends $AsyncNotifier<List<MonthlyPensionAccountBalance>> {
  late final _$args = ref.$arg as String;
  String get yearMonth => _$args;

  FutureOr<List<MonthlyPensionAccountBalance>> build(String yearMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MonthlyPensionAccountBalance>>,
              List<MonthlyPensionAccountBalance>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MonthlyPensionAccountBalance>>,
                List<MonthlyPensionAccountBalance>
              >,
              AsyncValue<List<MonthlyPensionAccountBalance>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
