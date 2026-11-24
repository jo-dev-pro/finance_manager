// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountNotifier)
const accountProvider = AccountNotifierProvider._();

final class AccountNotifierProvider
    extends $AsyncNotifierProvider<AccountNotifier, List<Account>> {
  const AccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();
}

String _$accountNotifierHash() => r'78808be0298918f4851d0e5551dbf18e4c7722c3';

abstract class _$AccountNotifier extends $AsyncNotifier<List<Account>> {
  FutureOr<List<Account>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Account>>, List<Account>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Account>>, List<Account>>,
              AsyncValue<List<Account>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
