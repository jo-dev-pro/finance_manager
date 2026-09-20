// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_bank_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyBankBalanceNotifierHash() =>
    r'1de3765198ba698bdd53d249181c26d08bdff9f8';

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

abstract class _$MonthlyBankBalanceNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<MonthlyBankBalance>> {
  late final String yearMonth;

  FutureOr<List<MonthlyBankBalance>> build(String yearMonth);
}

/// See also [MonthlyBankBalanceNotifier].
@ProviderFor(MonthlyBankBalanceNotifier)
const monthlyBankBalanceNotifierProvider = MonthlyBankBalanceNotifierFamily();

/// See also [MonthlyBankBalanceNotifier].
class MonthlyBankBalanceNotifierFamily
    extends Family<AsyncValue<List<MonthlyBankBalance>>> {
  /// See also [MonthlyBankBalanceNotifier].
  const MonthlyBankBalanceNotifierFamily();

  /// See also [MonthlyBankBalanceNotifier].
  MonthlyBankBalanceNotifierProvider call(String yearMonth) {
    return MonthlyBankBalanceNotifierProvider(yearMonth);
  }

  @override
  MonthlyBankBalanceNotifierProvider getProviderOverride(
    covariant MonthlyBankBalanceNotifierProvider provider,
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
  String? get name => r'monthlyBankBalanceNotifierProvider';
}

/// See also [MonthlyBankBalanceNotifier].
class MonthlyBankBalanceNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MonthlyBankBalanceNotifier,
          List<MonthlyBankBalance>
        > {
  /// See also [MonthlyBankBalanceNotifier].
  MonthlyBankBalanceNotifierProvider(String yearMonth)
    : this._internal(
        () => MonthlyBankBalanceNotifier()..yearMonth = yearMonth,
        from: monthlyBankBalanceNotifierProvider,
        name: r'monthlyBankBalanceNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$monthlyBankBalanceNotifierHash,
        dependencies: MonthlyBankBalanceNotifierFamily._dependencies,
        allTransitiveDependencies:
            MonthlyBankBalanceNotifierFamily._allTransitiveDependencies,
        yearMonth: yearMonth,
      );

  MonthlyBankBalanceNotifierProvider._internal(
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
  FutureOr<List<MonthlyBankBalance>> runNotifierBuild(
    covariant MonthlyBankBalanceNotifier notifier,
  ) {
    return notifier.build(yearMonth);
  }

  @override
  Override overrideWith(MonthlyBankBalanceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MonthlyBankBalanceNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<
    MonthlyBankBalanceNotifier,
    List<MonthlyBankBalance>
  >
  createElement() {
    return _MonthlyBankBalanceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyBankBalanceNotifierProvider &&
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
mixin MonthlyBankBalanceNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<MonthlyBankBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyBankBalanceNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MonthlyBankBalanceNotifier,
          List<MonthlyBankBalance>
        >
    with MonthlyBankBalanceNotifierRef {
  _MonthlyBankBalanceNotifierProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyBankBalanceNotifierProvider).yearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
