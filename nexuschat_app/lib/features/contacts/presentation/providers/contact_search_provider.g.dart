// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactSearchHash() => r'f3617513d10bedcefcb94808be288d94efb633b4';

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

abstract class _$ContactSearch
    extends BuildlessAutoDisposeAsyncNotifier<List<UserProfile>> {
  late final String query;

  FutureOr<List<UserProfile>> build(String query);
}

/// See also [ContactSearch].
@ProviderFor(ContactSearch)
const contactSearchProvider = ContactSearchFamily();

/// See also [ContactSearch].
class ContactSearchFamily extends Family<AsyncValue<List<UserProfile>>> {
  /// See also [ContactSearch].
  const ContactSearchFamily();

  /// See also [ContactSearch].
  ContactSearchProvider call(String query) {
    return ContactSearchProvider(query);
  }

  @override
  ContactSearchProvider getProviderOverride(
    covariant ContactSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactSearchProvider';
}

/// See also [ContactSearch].
class ContactSearchProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ContactSearch, List<UserProfile>> {
  /// See also [ContactSearch].
  ContactSearchProvider(String query)
    : this._internal(
        () => ContactSearch()..query = query,
        from: contactSearchProvider,
        name: r'contactSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactSearchHash,
        dependencies: ContactSearchFamily._dependencies,
        allTransitiveDependencies:
            ContactSearchFamily._allTransitiveDependencies,
        query: query,
      );

  ContactSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<UserProfile>> runNotifierBuild(
    covariant ContactSearch notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(ContactSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactSearchProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContactSearch, List<UserProfile>>
  createElement() {
    return _ContactSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactSearchRef
    on AutoDisposeAsyncNotifierProviderRef<List<UserProfile>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _ContactSearchProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ContactSearch,
          List<UserProfile>
        >
    with ContactSearchRef {
  _ContactSearchProviderElement(super.provider);

  @override
  String get query => (origin as ContactSearchProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
