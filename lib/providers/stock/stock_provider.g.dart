// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockScreenDataHash() => r'fad9e40c693b202b01aa271951c8f2d08aa26b02';

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

/// See also [stockScreenData].
@ProviderFor(stockScreenData)
const stockScreenDataProvider = StockScreenDataFamily();

/// See also [stockScreenData].
class StockScreenDataFamily extends Family<AsyncValue<List<StockAccountItem>>> {
  /// See also [stockScreenData].
  const StockScreenDataFamily();

  /// See also [stockScreenData].
  StockScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) {
    return StockScreenDataProvider(
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    );
  }

  @override
  StockScreenDataProvider getProviderOverride(
    covariant StockScreenDataProvider provider,
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
  String? get name => r'stockScreenDataProvider';
}

/// See also [stockScreenData].
class StockScreenDataProvider extends FutureProvider<List<StockAccountItem>> {
  /// See also [stockScreenData].
  StockScreenDataProvider({
    required String currentYearMonth,
    required String lastYearMonth,
  }) : this._internal(
         (ref) => stockScreenData(
           ref as StockScreenDataRef,
           currentYearMonth: currentYearMonth,
           lastYearMonth: lastYearMonth,
         ),
         from: stockScreenDataProvider,
         name: r'stockScreenDataProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$stockScreenDataHash,
         dependencies: StockScreenDataFamily._dependencies,
         allTransitiveDependencies:
             StockScreenDataFamily._allTransitiveDependencies,
         currentYearMonth: currentYearMonth,
         lastYearMonth: lastYearMonth,
       );

  StockScreenDataProvider._internal(
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
    FutureOr<List<StockAccountItem>> Function(StockScreenDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StockScreenDataProvider._internal(
        (ref) => create(ref as StockScreenDataRef),
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
  FutureProviderElement<List<StockAccountItem>> createElement() {
    return _StockScreenDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockScreenDataProvider &&
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
mixin StockScreenDataRef on FutureProviderRef<List<StockAccountItem>> {
  /// The parameter `currentYearMonth` of this provider.
  String get currentYearMonth;

  /// The parameter `lastYearMonth` of this provider.
  String get lastYearMonth;
}

class _StockScreenDataProviderElement
    extends FutureProviderElement<List<StockAccountItem>>
    with StockScreenDataRef {
  _StockScreenDataProviderElement(super.provider);

  @override
  String get currentYearMonth =>
      (origin as StockScreenDataProvider).currentYearMonth;
  @override
  String get lastYearMonth => (origin as StockScreenDataProvider).lastYearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
