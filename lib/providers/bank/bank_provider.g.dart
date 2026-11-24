// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bankScreenData)
const bankScreenDataProvider = BankScreenDataFamily._();

final class BankScreenDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankAccountItem>>,
          List<BankAccountItem>,
          FutureOr<List<BankAccountItem>>
        >
    with
        $FutureModifier<List<BankAccountItem>>,
        $FutureProvider<List<BankAccountItem>> {
  const BankScreenDataProvider._({
    required BankScreenDataFamily super.from,
    required ({String currentYearMonth, String lastYearMonth}) super.argument,
  }) : super(
         retry: null,
         name: r'bankScreenDataProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bankScreenDataHash();

  @override
  String toString() {
    return r'bankScreenDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<BankAccountItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankAccountItem>> create(Ref ref) {
    final argument =
        this.argument as ({String currentYearMonth, String lastYearMonth});
    return bankScreenData(
      ref,
      currentYearMonth: argument.currentYearMonth,
      lastYearMonth: argument.lastYearMonth,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BankScreenDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankScreenDataHash() => r'0b0aad58167c047e333cc3073dc54435687fc9d0';

final class BankScreenDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BankAccountItem>>,
          ({String currentYearMonth, String lastYearMonth})
        > {
  const BankScreenDataFamily._()
    : super(
        retry: null,
        name: r'bankScreenDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  BankScreenDataProvider call({
    required String currentYearMonth,
    required String lastYearMonth,
  }) => BankScreenDataProvider._(
    argument: (
      currentYearMonth: currentYearMonth,
      lastYearMonth: lastYearMonth,
    ),
    from: this,
  );

  @override
  String toString() => r'bankScreenDataProvider';
}
