// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pensionScreenDataHash() => r'd285b1f63bbf900ce142fd735c8b7f6ae5fabd59';

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

/// See also [pensionScreenData].
@ProviderFor(pensionScreenData)
const pensionScreenDataProvider = PensionScreenDataFamily();

/// See also [pensionScreenData].
class PensionScreenDataFamily
    extends Family<AsyncValue<List<PensionAccountItem>>> {
  /// See also [pensionScreenData].
  const PensionScreenDataFamily();

  /// See also [pensionScreenData].
  PensionScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) {
    return PensionScreenDataProvider(
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    );
  }

  @override
  PensionScreenDataProvider getProviderOverride(
    covariant PensionScreenDataProvider provider,
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
  String? get name => r'pensionScreenDataProvider';
}

/// See also [pensionScreenData].
class PensionScreenDataProvider
    extends AutoDisposeFutureProvider<List<PensionAccountItem>> {
  /// See also [pensionScreenData].
  PensionScreenDataProvider({
    required String currentYearMonth,
    required String lastYearMonth,
  }) : this._internal(
         (ref) => pensionScreenData(
           ref as PensionScreenDataRef,
           currentYearMonth: currentYearMonth,
           lastYearMonth: lastYearMonth,
         ),
         from: pensionScreenDataProvider,
         name: r'pensionScreenDataProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$pensionScreenDataHash,
         dependencies: PensionScreenDataFamily._dependencies,
         allTransitiveDependencies:
             PensionScreenDataFamily._allTransitiveDependencies,
         currentYearMonth: currentYearMonth,
         lastYearMonth: lastYearMonth,
       );

  PensionScreenDataProvider._internal(
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
    FutureOr<List<PensionAccountItem>> Function(PensionScreenDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PensionScreenDataProvider._internal(
        (ref) => create(ref as PensionScreenDataRef),
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
  AutoDisposeFutureProviderElement<List<PensionAccountItem>> createElement() {
    return _PensionScreenDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PensionScreenDataProvider &&
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
mixin PensionScreenDataRef
    on AutoDisposeFutureProviderRef<List<PensionAccountItem>> {
  /// The parameter `currentYearMonth` of this provider.
  String get currentYearMonth;

  /// The parameter `lastYearMonth` of this provider.
  String get lastYearMonth;
}

class _PensionScreenDataProviderElement
    extends AutoDisposeFutureProviderElement<List<PensionAccountItem>>
    with PensionScreenDataRef {
  _PensionScreenDataProviderElement(super.provider);

  @override
  String get currentYearMonth =>
      (origin as PensionScreenDataProvider).currentYearMonth;
  @override
  String get lastYearMonth =>
      (origin as PensionScreenDataProvider).lastYearMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
