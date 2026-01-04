// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasChatsHash() => r'70805a3c88e80250af4dd9ca096daa13672cfd57';

/// Provider that tracks if there are any chats
///
/// Copied from [hasChats].
@ProviderFor(hasChats)
final hasChatsProvider = AutoDisposeProvider<bool>.internal(
  hasChats,
  name: r'hasChatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasChatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasChatsRef = AutoDisposeProviderRef<bool>;
String _$chatListHash() => r'7dc30970ae8fb20aa62614409962b4136fb54a57';

/// State for chat list with loading, error, and data states
///
/// Copied from [ChatList].
@ProviderFor(ChatList)
final chatListProvider =
    AutoDisposeAsyncNotifierProvider<ChatList, List<ChatModel>>.internal(
      ChatList.new,
      name: r'chatListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatList = AutoDisposeAsyncNotifier<List<ChatModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
