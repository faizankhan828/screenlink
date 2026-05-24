import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/data/seed_data.dart';
import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  Future<void> _startNewChat(BuildContext context) async {
    final controller = context.read<AppController>();
    final currentUser = controller.currentUser;
    if (currentUser == null) return;

    final others = controller.messageableUsers;
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other creatives available to message yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

  final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('New conversation', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: others.length,
                  itemBuilder: (_, index) {
                    final user = others[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0] : '?')),
                      title: Text(user.name),
                      subtitle: Text('${user.role.label} • ${user.location}'),
                      onTap: () => Navigator.of(ctx).pop(user.uid),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    final other = others.firstWhere((u) => u.uid == selected);
    final chatId = await controller.startChatWithUser(otherUserId: other.uid, title: other.name);
    if (!context.mounted) return;
    final id = chatId ?? SeedData.chatIdFor(currentUser.uid, other.uid);
    context.push(Uri(path: '/messages/$id', queryParameters: {'title': other.name}).toString());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AppController>();
    final currentUser = controller.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                StreamBuilder(
                  stream: controller.watchDisplayChats(currentUser.uid),
                  builder: (context, snapshot) {
                    final chats = snapshot.data ?? controller.displayChatsFor(currentUser.uid);
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Messages',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () => _startNewChat(context),
                                  icon: const Icon(Icons.edit_rounded),
                                  tooltip: 'New message',
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (chats.isEmpty)
                          const SliverPadding(
                            padding: EdgeInsets.all(20),
                            sliver: SliverToBoxAdapter(
                              child: SceneEmptyState(
                                title: 'No messages yet',
                                message: 'Tap the compose button to start a conversation.',
                                icon: Icons.chat_bubble_outline_rounded,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final chat = chats[index];
                                  final hasUnread = chat.unreadCount > 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Material(
                                      color: hasUnread
                                          ? scheme.primaryContainer.withValues(alpha: 0.5)
                                          : scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => context.push(Uri(
                                          path: '/messages/${chat.chatId}',
                                          queryParameters: {'title': chat.title},
                                        ).toString()),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: scheme.primaryContainer,
                                                child: Text(
                                                  chat.title.isNotEmpty ? chat.title[0] : '?',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: scheme.onPrimaryContainer,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            chat.title,
                                                            style: TextStyle(
                                                              fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat.Hm().format(chat.updatedAt),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: scheme.onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      chat.lastMessage.isEmpty ? 'Start chatting…' : chat.lastMessage,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: scheme.onSurfaceVariant,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: chats.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: FloatingActionButton.extended(
                    onPressed: () => _startNewChat(context),
                    icon: const Icon(Icons.add_comment_rounded),
                    label: const Text('New chat'),
                  ),
                ),
              ],
            ),
    );
  }
}
