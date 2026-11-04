// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_account_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyPensionAccountBalanceNotifierHash() =>
    r'4051bd17dc2400e5406eab93a04fe157ce70634b';

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

abstract class _$MonthlyPensionAccountBalanceNotifier
    extends BuildlessAsyncNotifier<List<MonthlyPensionAccountBalance>> {
  late final String yearMonth;

  FutureOr<List<MonthlyPensionAccountBalance>> build(String yearMonth);
}

/// See also [MonthlyPensionAccountBalanceNotifier].
@ProviderFor(MonthlyPensionAccountBalanceNotifier)
const monthlyPensionAccountBalanceNotifierProvider =
    MonthlyPensionAccountBalanceNotifierFamily();

/// See also [MonthlyPensionAccountBalanceNotifier].
class MonthlyPensionAccountBalanceNotifierFamily
    extends Family<AsyncValue<List<MonthlyPensionAccountBalance>>> {
  /// See also [MonthlyPensionAccountBalanceNotifier].
  const MonthlyPensionAccountBalanceNotifierFamily();

  /// See also [MonthlyPensionAccountBalanceNotifier].
  MonthlyPensionAccountBalanceNotifierProvider call(String yearMonth) {
    return MonthlyPensionAccountBalanceNotifierProvider(yearMonth);
  }

  @override
  MonthlyPensionAccountBalanceNotifierProvider getProviderOverride(
    covariant MonthlyPensionAccountBalanceNotifierProvider provider,
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
  String? get name => r'monthlyPensionAccountBalanceNotifierProvider';
}

/// See also [MonthlyPensionAccountBalanceNotifier].
class MonthlyPensionAccountBalanceNotifierProvider
    extends
        AsyncNotifierProviderImpl<
          MonthlyPensionAccountBalanceNotifier,
          List<MonthlyPensionAccountBalance>
        > {
  /// See also [MonthlyPensionAccountBalanceNotifier].
  MonthlyPensionAccountBalanceNotifierProvider(String yearMonth)
    : this._internal(
        () => MonthlyPensionAccountBalanceNotifier()..yearMonth = yearMonth,
        from: monthlyPensionAccountBalanceNotifierProvider,
        name: r'monthlyPensionAccountBalanceNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$monthlyPensionAccountBalanceNotifierHash,
        dependencies: MonthlyPensionAccountBalanceNotifierFamily._dependencies,
        allTransitiveDependencies:
            MonthlyPensionAccountBalanceNotifierFamily
                ._allTransitiveDependencies,
        yearMonth: yearMonth,
      );

  MonthlyPensionAccountBalanceNotifierProvider._internal(
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
  FutureOr<List<MonthlyPensionAccountBalance>> runNotifierBuild(
    covariant MonthlyPensionAccountBalanceNotifier notifier,
  ) {
    return notifier.build(yearMonth);
  }

  @override
  Override overrideWith(
    MonthlyPensionAccountBalanceNotifier Function() create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyPensionAccountBalanceNotifierProvider._internal(
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
    MonthlyPensionAccountBalanceNotifier,
    List<MonthlyPensionAccountBalance>
  >
  createElement() {
    return _MonthlyPensionAccountBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyPensionAccountBalanceNotifierProvider &&
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
mixin MonthlyPensionAccountBalanceNotifierRef
    on AsyncNotifierProviderRef<List<MonthlyPensionAccountBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyPensionAccountBalanceNotifierProviderElement
    extends
        AsyncNotifierProviderElement<
          MonthlyPensionAccountBalanceNotifier,
          List<MonthlyPensionAccountBalance>
        >
    with MonthlyPensionAccountBalanceNotifierRef {
  _MonthlyPensionAccountBalanceNotifierProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyPensionAccountBalanceNotifierProvider).yearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
