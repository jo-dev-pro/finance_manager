// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyPensionBalancesByAccountHash() =>
    r'b8f3c793c2487ba83b7abf85fb9d3a6d654ff6ed';

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

/// See also [monthlyPensionBalancesByAccount].
@ProviderFor(monthlyPensionBalancesByAccount)
const monthlyPensionBalancesByAccountProvider =
    MonthlyPensionBalancesByAccountFamily();

/// See also [monthlyPensionBalancesByAccount].
class MonthlyPensionBalancesByAccountFamily
    extends Family<AsyncValue<List<MonthlyPensionBalance>>> {
  /// See also [monthlyPensionBalancesByAccount].
  const MonthlyPensionBalancesByAccountFamily();

  /// See also [monthlyPensionBalancesByAccount].
  MonthlyPensionBalancesByAccountProvider call({
    required String yearMonth,
    required String accountId,
  }) {
    return MonthlyPensionBalancesByAccountProvider(
      yearMonth: yearMonth,
      accountId: accountId,
    );
  }

  @override
  MonthlyPensionBalancesByAccountProvider getProviderOverride(
    covariant MonthlyPensionBalancesByAccountProvider provider,
  ) {
    return call(yearMonth: provider.yearMonth, accountId: provider.accountId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyPensionBalancesByAccountProvider';
}

/// See also [monthlyPensionBalancesByAccount].
class MonthlyPensionBalancesByAccountProvider
    extends AutoDisposeFutureProvider<List<MonthlyPensionBalance>> {
  /// See also [monthlyPensionBalancesByAccount].
  MonthlyPensionBalancesByAccountProvider({
    required String yearMonth,
    required String accountId,
  }) : this._internal(
         (ref) => monthlyPensionBalancesByAccount(
           ref as MonthlyPensionBalancesByAccountRef,
           yearMonth: yearMonth,
           accountId: accountId,
         ),
         from: monthlyPensionBalancesByAccountProvider,
         name: r'monthlyPensionBalancesByAccountProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$monthlyPensionBalancesByAccountHash,
         dependencies: MonthlyPensionBalancesByAccountFamily._dependencies,
         allTransitiveDependencies:
             MonthlyPensionBalancesByAccountFamily._allTransitiveDependencies,
         yearMonth: yearMonth,
         accountId: accountId,
       );

  MonthlyPensionBalancesByAccountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.yearMonth,
    required this.accountId,
  }) : super.internal();

  final String yearMonth;
  final String accountId;

  @override
  Override overrideWith(
    FutureOr<List<MonthlyPensionBalance>> Function(
      MonthlyPensionBalancesByAccountRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyPensionBalancesByAccountProvider._internal(
        (ref) => create(ref as MonthlyPensionBalancesByAccountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        yearMonth: yearMonth,
        accountId: accountId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MonthlyPensionBalance>>
  createElement() {
    return _MonthlyPensionBalancesByAccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyPensionBalancesByAccountProvider &&
        other.yearMonth == yearMonth &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, yearMonth.hashCode);
    hash = _SystemHash.combine(hash, accountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyPensionBalancesByAccountRef
    on AutoDisposeFutureProviderRef<List<MonthlyPensionBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;

  /// The parameter `accountId` of this provider.
  String get accountId;
}

class _MonthlyPensionBalancesByAccountProviderElement
    extends AutoDisposeFutureProviderElement<List<MonthlyPensionBalance>>
    with MonthlyPensionBalancesByAccountRef {
  _MonthlyPensionBalancesByAccountProviderElement(super.provider);

  @override
  String get yearMonth =>
      (origin as MonthlyPensionBalancesByAccountProvider).yearMonth;
  @override
  String get accountId =>
      (origin as MonthlyPensionBalancesByAccountProvider).accountId;
}

String _$monthlyPensionBalanceNotifierHash() =>
    r'5dfbdc7a55e01f21c306f8ad7a5702c6178f4e1e';

abstract class _$MonthlyPensionBalanceNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<MonthlyPensionBalance>> {
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
        AutoDisposeAsyncNotifierProviderImpl<
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
  AutoDisposeAsyncNotifierProviderElement<
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
    on AutoDisposeAsyncNotifierProviderRef<List<MonthlyPensionBalance>> {
  /// The parameter `yearMonth` of this provider.
  String get yearMonth;
}

class _MonthlyPensionBalanceNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
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
