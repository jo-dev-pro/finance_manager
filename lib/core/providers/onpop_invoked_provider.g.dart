// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onpop_invoked_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JOnPopInvoked)
const jOnPopInvokedProvider = JOnPopInvokedProvider._();

final class JOnPopInvokedProvider
    extends $NotifierProvider<JOnPopInvoked, bool> {
  const JOnPopInvokedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jOnPopInvokedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jOnPopInvokedHash();

  @$internal
  @override
  JOnPopInvoked create() => JOnPopInvoked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$jOnPopInvokedHash() => r'7bae9f189139b0f851858ba6dd84633f85c11a0b';

abstract class _$JOnPopInvoked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
