// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMonthlyPensionBalancesHash() =>
    r'7be09a91725fdc7d8cff81240570a79370bb8f9b';

/// See also [AllMonthlyPensionBalances].
@ProviderFor(AllMonthlyPensionBalances)
final allMonthlyPensionBalancesProvider = AutoDisposeAsyncNotifierProvider<
  AllMonthlyPensionBalances,
  List<MonthlyPensionBalanceWithDetail>
>.internal(
  AllMonthlyPensionBalances.new,
  name: r'allMonthlyPensionBalancesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allMonthlyPensionBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllMonthlyPensionBalances =
    AutoDisposeAsyncNotifier<List<MonthlyPensionBalanceWithDetail>>;
String _$monthlyPensionBalanceNotifierHash() =>
    r'1e2d13576589fe7866d0268451c46f1d8f4286c3';

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

abstract class _$MonthlyPensionBalanceNotifier
    extends BuildlessAsyncNotifier<List<MonthlyPensionBalance>> {
  late final String yearMonth;

  FutureOr<List<MonthlyPensionBalance>> build(String yearMonth);
}

/// See also [MonthlyPensionBalanceNotifier].
@ProviderFor(MonthlyPensionBalanceNotifier)
const monthlyPensionBalanceNotifierProvider =
    MonthlyPensionBalanceNotifierFamily();

/// See also [MonthlyPensionBalanceNotifier].
class MonthlyPensionBalanceNotifierFamily
    extends Family<AsyncValue<List<MonthlyPensionBalance>>> {
  /// See also [MonthlyPensionBalanceNotifier].
  const MonthlyPensionBalanceNotifierFamily();

  /// See also [MonthlyPensionBalanceNotifier].
  MonthlyPensionBalanceNotifierProvider call(String yearMonth) {
    return MonthlyPensionBalanceNotifierProvider(yearMonth);
  }

  @override
  MonthlyPensionBalanceNotifierProvider getProviderOverride(
    covariant MonthlyPensionBalanceNotifierProvider provider,
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
  String? get name => r'monthlyPensionBalanceNotifierProvider';
}

/// See also [MonthlyPensionBalanceNotifier].
class MonthlyPensionBalanceNotifierProvider
    extends
        AsyncNotifierProviderImpl<
          MonthlyPensionBalanceNotifier,
          List<MonthlyPensionBalance>
        > {
  /// See also [MonthlyPensionBalanceNotifier].
  MonthlyPensionBalanceNotifierProvider(String yearMonth)
    : this._internal(
        () => MonthlyPensionBalanceNotifier()..yearMonth = yearMonth,
        from: monthlyPensionBalanceNotifierProvider,
        name: r'monthlyPensionBalanceNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$monthlyPensionBalanceNotifierHash,
        dependencies: MonthlyPensionBalanceNotifierFamily._dependencies,
        allTransitiveDependencies:
            MonthlyPensionBalanceNotifierFamily._allTransitiveDependencies,
        yearMonth: yearMonth,
      );

  MonthlyPensionBalanceNotifierProvider._internal(
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
  FutureOr<List<MonthlyPensionBalance>> runNotifierBuild(
    covariant MonthlyPensionBalanceNotifier notifier,
  ) {
    return notifier.build(yearMonth);
  }

  @override
  Override overrideWith(MonthlyPensionBalanceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MonthlyPensionBalanceNotifierProvider._internal(
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
    MonthlyPensionBalanceNotifier,
    List<MonthlyPensionBalance>
  >
  createElement() {
    return _MonthlyPensionBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyPensionBalanceNotifierProvider &&
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
mixin MonthlyPensionBalanceNotifierRef
    on AsyncNotifierProviderRef<List<MonthlyPensionBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyPensionBalanceNotifierProviderElement
    extends
        AsyncNotifierProviderElement<
          MonthlyPensionBalanceNotifier,
          List<MonthlyPensionBalance>
        >
    with MonthlyPensionBalanceNotifierRef {
  _MonthlyPensionBalanceNotifierProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyPensionBalanceNotifierProvider).yearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
