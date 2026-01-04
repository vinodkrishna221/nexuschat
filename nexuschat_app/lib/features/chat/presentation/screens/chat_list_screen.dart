import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexuschat_app/features/chat/domain/models/chat_model.dart';
import 'package:nexuschat_app/features/chat/presentation/widgets/chat_item.dart';
import 'package:nexuschat_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:nexuschat_app/core/ui/widgets/empty_state_widget.dart';
import 'package:nexuschat_app/core/ui/widgets/offline_banner.dart';
import 'package:nexuschat_app/core/ui/widgets/error_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.black,
                        const Color(0xFF1A1A1A),
                        const Color(0xFF0D0D0D),
                      ]
                    : [
                        const Color(0xFFF5F5F7),
                        const Color(0xFFE1E1E6),
                        const Color(0xFFF0F0F3),
                      ],
              ),
            ),
          ),
          
          // Blobs for nice glass background effect (optional aesthetic touch)
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                ),
              ),
            ),
          ),

          // Offline Banner
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineBanner(),
          ),

          // Main Content
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  centerTitle: true,
                  backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.7),
                  elevation: 0,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        child: Icon(Icons.person, color: theme.primaryColor),
                      ),
                    ),
                  ),
                  title: Text(
                    'Chats',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: _ChatSearchDelegate(ref),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.create_outlined),
                      onPressed: () {
                        context.push('/contacts');
                      },
                    ),
                  ],
                ),
              ];
            },
            body: _buildChatListBody(context, ref, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListBody(BuildContext context, WidgetRef ref, ThemeData theme) {
    final chatListAsync = ref.watch(chatListProvider);

    return chatListAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => InlineError(
        message: 'Failed to load chats: $error',
        onRetry: () => ref.invalidate(chatListProvider),
      ),
      data: (chats) {
        if (chats.isEmpty) {
          return NoChatsEmptyState(
            onStartChat: () => context.push('/contacts'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(chatListProvider.notifier).refresh();
          },
          displacement: 60,
          edgeOffset: 80,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 0, bottom: 20),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatItem(
                chat: chat,
                onTap: () {
                  context.push('/chat/${chat.id}', extra: chat);
                },
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                  .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
            },
          ),
        );
      },
    );
  }
}

class _ChatSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  
  _ChatSearchDelegate(this.ref);
  
  @override
  String get searchFieldLabel => 'Search chats...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search chats...'),
      );
    }

    final chatListAsync = ref.watch(chatListProvider);
    
    return chatListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading chats')),
      data: (chats) {
        final results = chats.where((chat) {
          final name = chat.name.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery);
        }).toList();

        if (results.isEmpty) {
          return NoSearchResultsEmptyState(query: query);
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final chat = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chat.avatarUrl),
                child: chat.avatarUrl.isEmpty ? Text(chat.name[0]) : null,
              ),
              title: Text(chat.name),
              subtitle: Text(chat.lastMessage),
              onTap: () {
                close(context, chat.id);
                GoRouter.of(context).push('/chat/${chat.id}', extra: chat);
              },
            );
          },
        );
      },
    );
  }
}
