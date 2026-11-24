// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_name_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountNameNotifier)
const accountNameProvider = AccountNameNotifierProvider._();

final class AccountNameNotifierProvider
    extends $AsyncNotifierProvider<AccountNameNotifier, List<AccountName>> {
  const AccountNameNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountNameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNameNotifierHash();

  @$internal
  @override
  AccountNameNotifier create() => AccountNameNotifier();
}

String _$accountNameNotifierHash() =>
    r'b58c9ae929e565c306a4add945dfcd488bd96e47';

abstract class _$AccountNameNotifier extends $AsyncNotifier<List<AccountName>> {
  FutureOr<List<AccountName>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<AccountName>>, List<AccountName>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AccountName>>, List<AccountName>>,
              AsyncValue<List<AccountName>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
