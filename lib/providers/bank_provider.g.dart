// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bankScreenDataHash() => r'9eb85d002f42d65af4e15fd52aa9b87a7f3b4162';

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

/// See also [bankScreenData].
@ProviderFor(bankScreenData)
const bankScreenDataProvider = BankScreenDataFamily();

/// See also [bankScreenData].
class BankScreenDataFamily extends Family<AsyncValue<List<BankAccountItem>>> {
  /// See also [bankScreenData].
  const BankScreenDataFamily();

  /// See also [bankScreenData].
  BankScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) {
    return BankScreenDataProvider(
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    );
  }

  @override
  BankScreenDataProvider getProviderOverride(
    covariant BankScreenDataProvider provider,
  ) {
    return call(
      currentYearMonth: provider.currentYearMonth,
      lastYearMonth: provider.lastYearMonth,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bankScreenDataProvider';
}

/// See also [bankScreenData].
class BankScreenDataProvider
    extends AutoDisposeFutureProvider<List<BankAccountItem>> {
  /// See also [bankScreenData].
  BankScreenDataProvider({
    required String currentYearMonth,
    required String lastYearMonth,
  }) : this._internal(
         (ref) => bankScreenData(
           ref as BankScreenDataRef,
           currentYearMonth: currentYearMonth,
           lastYearMonth: lastYearMonth,
         ),
         from: bankScreenDataProvider,
         name: r'bankScreenDataProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$bankScreenDataHash,
         dependencies: BankScreenDataFamily._dependencies,
         allTransitiveDependencies:
             BankScreenDataFamily._allTransitiveDependencies,
         currentYearMonth: currentYearMonth,
         lastYearMonth: lastYearMonth,
       );

  BankScreenDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentYearMonth,
    required this.lastYearMonth,
  }) : super.internal();

  final String currentYearMonth;
  final String lastYearMonth;

  @override
  Override overrideWith(
    FutureOr<List<BankAccountItem>> Function(BankScreenDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BankScreenDataProvider._internal(
        (ref) => create(ref as BankScreenDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentYearMonth: currentYearMonth,
        lastYearMonth: lastYearMonth,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BankAccountItem>> createElement() {
    return _BankScreenDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BankScreenDataProvider &&
        other.currentYearMonth == currentYearMonth &&
        other.lastYearMonth == lastYearMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentYearMonth.hashCode);
    hash = _SystemHash.combine(hash, lastYearMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BankScreenDataRef on AutoDisposeFutureProviderRef<List<BankAccountItem>> {
  /// The parameter `currentYearMonth` of this provider.
  String get currentYearMonth;

  /// The parameter `lastYearMonth` of this provider.
  String get lastYearMonth;
}

class _BankScreenDataProviderElement
    extends AutoDisposeFutureProviderElement<List<BankAccountItem>>
    with BankScreenDataRef {
  _BankScreenDataProviderElement(super.provider);

  @override
  String get currentYearMonth =>
      (origin as BankScreenDataProvider).currentYearMonth;
  @override
  String get lastYearMonth => (origin as BankScreenDataProvider).lastYearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
