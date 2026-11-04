// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stock_account_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMonthlyStockAccountBalancesHash() =>
    r'c5782299278918f3f7f18380a10a042538f8cb56';

/// See also [AllMonthlyStockAccountBalances].
@ProviderFor(AllMonthlyStockAccountBalances)
final allMonthlyStockAccountBalancesProvider = AutoDisposeAsyncNotifierProvider<
  AllMonthlyStockAccountBalances,
  List<MonthlyStockAccountBalanceWithDetail>
>.internal(
  AllMonthlyStockAccountBalances.new,
  name: r'allMonthlyStockAccountBalancesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allMonthlyStockAccountBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllMonthlyStockAccountBalances =
    AutoDisposeAsyncNotifier<List<MonthlyStockAccountBalanceWithDetail>>;
String _$monthlyStockAccountBalanceNotifierHash() =>
    r'19db9a23f7c76b9b99b09f9f7be536c61420b124';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MonthlyStockAccountBalanceNotifier
    extends BuildlessAsyncNotifier<List<MonthlyStockAccountBalance>> {
  late final String yearMonth;

  FutureOr<List<MonthlyStockAccountBalance>> build(String yearMonth);
}

/// See also [MonthlyStockAccountBalanceNotifier].
@ProviderFor(MonthlyStockAccountBalanceNotifier)
const monthlyStockAccountBalanceNotifierProvider =
    MonthlyStockAccountBalanceNotifierFamily();

/// See also [MonthlyStockAccountBalanceNotifier].
class MonthlyStockAccountBalanceNotifierFamily
    extends Family<AsyncValue<List<MonthlyStockAccountBalance>>> {
  /// See also [MonthlyStockAccountBalanceNotifier].
  const MonthlyStockAccountBalanceNotifierFamily();

  /// See also [MonthlyStockAccountBalanceNotifier].
  MonthlyStockAccountBalanceNotifierProvider call(String yearMonth) {
    return MonthlyStockAccountBalanceNotifierProvider(yearMonth);
  }

  @override
  MonthlyStockAccountBalanceNotifierProvider getProviderOverride(
    covariant MonthlyStockAccountBalanceNotifierProvider provider,
  ) {
    return call(provider.yearMonth);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyStockAccountBalanceNotifierProvider';
}

/// See also [MonthlyStockAccountBalanceNotifier].
class MonthlyStockAccountBalanceNotifierProvider
    extends
        AsyncNotifierProviderImpl<
          MonthlyStockAccountBalanceNotifier,
          List<MonthlyStockAccountBalance>
        > {
  /// See also [MonthlyStockAccountBalanceNotifier].
  MonthlyStockAccountBalanceNotifierProvider(String yearMonth)
    : this._internal(
        () => MonthlyStockAccountBalanceNotifier()..yearMonth = yearMonth,
        from: monthlyStockAccountBalanceNotifierProvider,
        name: r'monthlyStockAccountBalanceNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$monthlyStockAccountBalanceNotifierHash,
        dependencies: MonthlyStockAccountBalanceNotifierFamily._dependencies,
        allTransitiveDependencies:
            MonthlyStockAccountBalanceNotifierFamily._allTransitiveDependencies,
        yearMonth: yearMonth,
      );

  MonthlyStockAccountBalanceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.yearMonth,
  }) : super.internal();

  final String yearMonth;

  @override
  FutureOr<List<MonthlyStockAccountBalance>> runNotifierBuild(
    covariant MonthlyStockAccountBalanceNotifier notifier,
  ) {
    return notifier.build(yearMonth);
  }

  @override
  Override overrideWith(MonthlyStockAccountBalanceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MonthlyStockAccountBalanceNotifierProvider._internal(
        () => create()..yearMonth = yearMonth,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        yearMonth: yearMonth,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<
    MonthlyStockAccountBalanceNotifier,
    List<MonthlyStockAccountBalance>
  >
  createElement() {
    return _MonthlyStockAccountBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyStockAccountBalanceNotifierProvider &&
        other.yearMonth == yearMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, yearMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyStockAccountBalanceNotifierRef
    on AsyncNotifierProviderRef<List<MonthlyStockAccountBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyStockAccountBalanceNotifierProviderElement
    extends
        AsyncNotifierProviderElement<
          MonthlyStockAccountBalanceNotifier,
          List<MonthlyStockAccountBalance>
        >
    with MonthlyStockAccountBalanceNotifierRef {
  _MonthlyStockAccountBalanceNotifierProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyStockAccountBalanceNotifierProvider).yearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
