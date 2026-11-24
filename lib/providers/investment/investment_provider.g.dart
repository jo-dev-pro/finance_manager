// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InvestmentNotifier)
const investmentProvider = InvestmentNotifierProvider._();

final class InvestmentNotifierProvider
    extends $AsyncNotifierProvider<InvestmentNotifier, List<Investment>> {
  const InvestmentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investmentNotifierHash();

  @$internal
  @override
  InvestmentNotifier create() => InvestmentNotifier();
}

String _$investmentNotifierHash() =>
    r'e23a174356245b5f14ef53475f57e793b359606a';

abstract class _$InvestmentNotifier extends $AsyncNotifier<List<Investment>> {
  FutureOr<List<Investment>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Investment>>, List<Investment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Investment>>, List<Investment>>,
              AsyncValue<List<Investment>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
