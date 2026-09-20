// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pensionProductsByAccountHash() =>
    r'4044fc6b8e12407c5024091b6fba3e549a6c1038';

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

/// See also [pensionProductsByAccount].
@ProviderFor(pensionProductsByAccount)
const pensionProductsByAccountProvider = PensionProductsByAccountFamily();

/// See also [pensionProductsByAccount].
class PensionProductsByAccountFamily
    extends Family<AsyncValue<List<PensionProduct>>> {
  /// See also [pensionProductsByAccount].
  const PensionProductsByAccountFamily();

  /// See also [pensionProductsByAccount].
  PensionProductsByAccountProvider call(String accountName) {
    return PensionProductsByAccountProvider(accountName);
  }

  @override
  PensionProductsByAccountProvider getProviderOverride(
    covariant PensionProductsByAccountProvider provider,
  ) {
    return call(provider.accountName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pensionProductsByAccountProvider';
}

/// See also [pensionProductsByAccount].
class PensionProductsByAccountProvider
    extends AutoDisposeFutureProvider<List<PensionProduct>> {
  /// See also [pensionProductsByAccount].
  PensionProductsByAccountProvider(String accountName)
    : this._internal(
        (ref) => pensionProductsByAccount(
          ref as PensionProductsByAccountRef,
          accountName,
        ),
        from: pensionProductsByAccountProvider,
        name: r'pensionProductsByAccountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pensionProductsByAccountHash,
        dependencies: PensionProductsByAccountFamily._dependencies,
        allTransitiveDependencies:
            PensionProductsByAccountFamily._allTransitiveDependencies,
        accountName: accountName,
      );

  PensionProductsByAccountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountName,
  }) : super.internal();

  final String accountName;

  @override
  Override overrideWith(
    FutureOr<List<PensionProduct>> Function(
      PensionProductsByAccountRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PensionProductsByAccountProvider._internal(
        (ref) => create(ref as PensionProductsByAccountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountName: accountName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PensionProduct>> createElement() {
    return _PensionProductsByAccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PensionProductsByAccountProvider &&
        other.accountName == accountName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PensionProductsByAccountRef
    on AutoDisposeFutureProviderRef<List<PensionProduct>> {
  /// The parameter `accountName` of this provider.
  String get accountName;
}

class _PensionProductsByAccountProviderElement
    extends AutoDisposeFutureProviderElement<List<PensionProduct>>
    with PensionProductsByAccountRef {
  _PensionProductsByAccountProviderElement(super.provider);

  @override
  String get accountName =>
      (origin as PensionProductsByAccountProvider).accountName;
}

String _$pensionProductNotifierHash() =>
    r'2634a4aefb05e36cd1ef8a283808e9cd2ffec471';

/// See also [PensionProductNotifier].
@ProviderFor(PensionProductNotifier)
final pensionProductNotifierProvider = AutoDisposeAsyncNotifierProvider<
  PensionProductNotifier,
  List<PensionProduct>
>.internal(
  PensionProductNotifier.new,
  name: r'pensionProductNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pensionProductNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PensionProductNotifier =
    AutoDisposeAsyncNotifier<List<PensionProduct>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
