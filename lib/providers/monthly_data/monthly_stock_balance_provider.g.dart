// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stock_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMonthlyStockBalancesHash() =>
    r'4fad37d9b653c8570fd0a897d4440018c4d6b5c4';

/// See also [AllMonthlyStockBalances].
@ProviderFor(AllMonthlyStockBalances)
final allMonthlyStockBalancesProvider = AutoDisposeAsyncNotifierProvider<
  AllMonthlyStockBalances,
  List<MonthlyStockBalanceWithDetail>
>.internal(
  AllMonthlyStockBalances.new,
  name: r'allMonthlyStockBalancesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allMonthlyStockBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllMonthlyStockBalances =
    AutoDisposeAsyncNotifier<List<MonthlyStockBalanceWithDetail>>;
String _$monthlyStockBalanceNotifierHash() =>
    r'9366fb1dd41200d297705ba5a142a8108e9ead8e';

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

abstract class _$MonthlyStockBalanceNotifier
    extends BuildlessAsyncNotifier<List<MonthlyStockBalance>> {
  late final String yearMonth;

  FutureOr<List<MonthlyStockBalance>> build(String yearMonth);
}

/// See also [MonthlyStockBalanceNotifier].
@ProviderFor(MonthlyStockBalanceNotifier)
const monthlyStockBalanceNotifierProvider = MonthlyStockBalanceNotifierFamily();

/// See also [MonthlyStockBalanceNotifier].
class MonthlyStockBalanceNotifierFamily
    extends Family<AsyncValue<List<MonthlyStockBalance>>> {
  /// See also [MonthlyStockBalanceNotifier].
  const MonthlyStockBalanceNotifierFamily();

  /// See also [MonthlyStockBalanceNotifier].
  MonthlyStockBalanceNotifierProvider call(String yearMonth) {
    return MonthlyStockBalanceNotifierProvider(yearMonth);
  }

  @override
  MonthlyStockBalanceNotifierProvider getProviderOverride(
    covariant MonthlyStockBalanceNotifierProvider provider,
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
  String? get name => r'monthlyStockBalanceNotifierProvider';
}

/// See also [MonthlyStockBalanceNotifier].
class MonthlyStockBalanceNotifierProvider
    extends
        AsyncNotifierProviderImpl<
          MonthlyStockBalanceNotifier,
          List<MonthlyStockBalance>
        > {
  /// See also [MonthlyStockBalanceNotifier].
  MonthlyStockBalanceNotifierProvider(String yearMonth)
    : this._internal(
        () => MonthlyStockBalanceNotifier()..yearMonth = yearMonth,
        from: monthlyStockBalanceNotifierProvider,
        name: r'monthlyStockBalanceNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$monthlyStockBalanceNotifierHash,
        dependencies: MonthlyStockBalanceNotifierFamily._dependencies,
        allTransitiveDependencies:
            MonthlyStockBalanceNotifierFamily._allTransitiveDependencies,
        yearMonth: yearMonth,
      );

  MonthlyStockBalanceNotifierProvider._internal(
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
  FutureOr<List<MonthlyStockBalance>> runNotifierBuild(
    covariant MonthlyStockBalanceNotifier notifier,
  ) {
    return notifier.build(yearMonth);
  }

  @override
  Override overrideWith(MonthlyStockBalanceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MonthlyStockBalanceNotifierProvider._internal(
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
    MonthlyStockBalanceNotifier,
    List<MonthlyStockBalance>
  >
  createElement() {
    return _MonthlyStockBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyStockBalanceNotifierProvider &&
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
mixin MonthlyStockBalanceNotifierRef
    on AsyncNotifierProviderRef<List<MonthlyStockBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyStockBalanceNotifierProviderElement
    extends
        AsyncNotifierProviderElement<
          MonthlyStockBalanceNotifier,
          List<MonthlyStockBalance>
        >
    with MonthlyStockBalanceNotifierRef {
  _MonthlyStockBalanceNotifierProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyStockBalanceNotifierProvider).yearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
