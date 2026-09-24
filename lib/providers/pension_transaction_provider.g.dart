// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pensionTransactionsByAccountHash() =>
    r'031294c965b908846cdc3a43949cb6c51287533e';

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

/// See also [pensionTransactionsByAccount].
@ProviderFor(pensionTransactionsByAccount)
const pensionTransactionsByAccountProvider =
    PensionTransactionsByAccountFamily();

/// See also [pensionTransactionsByAccount].
class PensionTransactionsByAccountFamily
    extends Family<AsyncValue<List<PensionTransaction>>> {
  /// See also [pensionTransactionsByAccount].
  const PensionTransactionsByAccountFamily();

  /// See also [pensionTransactionsByAccount].
  PensionTransactionsByAccountProvider call(String accountId) {
    return PensionTransactionsByAccountProvider(accountId);
  }

  @override
  PensionTransactionsByAccountProvider getProviderOverride(
    covariant PensionTransactionsByAccountProvider provider,
  ) {
    return call(provider.accountId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pensionTransactionsByAccountProvider';
}

/// See also [pensionTransactionsByAccount].
class PensionTransactionsByAccountProvider
    extends AutoDisposeFutureProvider<List<PensionTransaction>> {
  /// See also [pensionTransactionsByAccount].
  PensionTransactionsByAccountProvider(String accountId)
    : this._internal(
        (ref) => pensionTransactionsByAccount(
          ref as PensionTransactionsByAccountRef,
          accountId,
        ),
        from: pensionTransactionsByAccountProvider,
        name: r'pensionTransactionsByAccountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pensionTransactionsByAccountHash,
        dependencies: PensionTransactionsByAccountFamily._dependencies,
        allTransitiveDependencies:
            PensionTransactionsByAccountFamily._allTransitiveDependencies,
        accountId: accountId,
      );

  PensionTransactionsByAccountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountId,
  }) : super.internal();

  final String accountId;

  @override
  Override overrideWith(
    FutureOr<List<PensionTransaction>> Function(
      PensionTransactionsByAccountRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PensionTransactionsByAccountProvider._internal(
        (ref) => create(ref as PensionTransactionsByAccountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountId: accountId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PensionTransaction>> createElement() {
    return _PensionTransactionsByAccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PensionTransactionsByAccountProvider &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PensionTransactionsByAccountRef
    on AutoDisposeFutureProviderRef<List<PensionTransaction>> {
  /// The parameter `accountId` of this provider.
  String get accountId;
}

class _PensionTransactionsByAccountProviderElement
    extends AutoDisposeFutureProviderElement<List<PensionTransaction>>
    with PensionTransactionsByAccountRef {
  _PensionTransactionsByAccountProviderElement(super.provider);

  @override
  String get accountId =>
      (origin as PensionTransactionsByAccountProvider).accountId;
}

String _$pensionTransactionsByProductHash() =>
    r'c275fdc6f2f5179bc5918b3dff1de10b13dd69d6';

/// See also [pensionTransactionsByProduct].
@ProviderFor(pensionTransactionsByProduct)
const pensionTransactionsByProductProvider =
    PensionTransactionsByProductFamily();

/// See also [pensionTransactionsByProduct].
class PensionTransactionsByProductFamily
    extends Family<AsyncValue<List<PensionTransaction>>> {
  /// See also [pensionTransactionsByProduct].
  const PensionTransactionsByProductFamily();

  /// See also [pensionTransactionsByProduct].
  PensionTransactionsByProductProvider call(String productId) {
    return PensionTransactionsByProductProvider(productId);
  }

  @override
  PensionTransactionsByProductProvider getProviderOverride(
    covariant PensionTransactionsByProductProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pensionTransactionsByProductProvider';
}

/// See also [pensionTransactionsByProduct].
class PensionTransactionsByProductProvider
    extends AutoDisposeFutureProvider<List<PensionTransaction>> {
  /// See also [pensionTransactionsByProduct].
  PensionTransactionsByProductProvider(String productId)
    : this._internal(
        (ref) => pensionTransactionsByProduct(
          ref as PensionTransactionsByProductRef,
          productId,
        ),
        from: pensionTransactionsByProductProvider,
        name: r'pensionTransactionsByProductProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pensionTransactionsByProductHash,
        dependencies: PensionTransactionsByProductFamily._dependencies,
        allTransitiveDependencies:
            PensionTransactionsByProductFamily._allTransitiveDependencies,
        productId: productId,
      );

  PensionTransactionsByProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<List<PensionTransaction>> Function(
      PensionTransactionsByProductRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PensionTransactionsByProductProvider._internal(
        (ref) => create(ref as PensionTransactionsByProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PensionTransaction>> createElement() {
    return _PensionTransactionsByProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PensionTransactionsByProductProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PensionTransactionsByProductRef
    on AutoDisposeFutureProviderRef<List<PensionTransaction>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _PensionTransactionsByProductProviderElement
    extends AutoDisposeFutureProviderElement<List<PensionTransaction>>
    with PensionTransactionsByProductRef {
  _PensionTransactionsByProductProviderElement(super.provider);

  @override
  String get productId =>
      (origin as PensionTransactionsByProductProvider).productId;
}

String _$pensionTransactionNotifierHash() =>
    r'480e095a47a0e0e7bb9d5938889b60ae8aa45458';

/// See also [PensionTransactionNotifier].
@ProviderFor(PensionTransactionNotifier)
final pensionTransactionNotifierProvider = AutoDisposeAsyncNotifierProvider<
  PensionTransactionNotifier,
  List<PensionTransaction>
>.internal(
  PensionTransactionNotifier.new,
  name: r'pensionTransactionNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pensionTransactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PensionTransactionNotifier =
    AutoDisposeAsyncNotifier<List<PensionTransaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
