import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatId, required this.title});

  final String chatId;
  final String title;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _otherParticipantId(AppController controller) {
    final chatId = widget.chatId;
    if (!chatId.contains('_')) return chatId;
    final parts = chatId.split('_');
    final currentId = controller.currentUser?.uid;
    if (currentId == null || parts.length < 2) return parts.last;
    return parts.first == currentId ? parts.last : parts.first;
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final controller = context.read<AppController>();
    final currentUser = controller.currentUser;
    if (currentUser == null) return;

    setState(() => _sending = true);
    final error = await controller.sendMessage(
      CreativeMessage(
        senderId: currentUser.uid,
        receiverId: _otherParticipantId(controller) ?? widget.chatId,
        message: text,
        timestamp: DateTime.now(),
        read: false,
        chatId: widget.chatId,
        imageUrl: null,
      ),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null && !error.contains('shown locally')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    }
    _messageController.clear();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final currentUser = controller.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/app'),
        ),
        title: Text(widget.title),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<CreativeMessage>>(
              stream: controller.repository.watchMessages(widget.chatId),
              builder: (context, snapshot) {
                // Show a loading spinner on the very first load before any
                // Firestore data arrives.
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Prefer Firestore stream data (includes Firestore's own
                // optimistic-write cache, so newly sent messages appear
                // instantly without manual local state).
                // Fall back to seed + local messages only when Firebase is
                // unavailable (demo / offline mode).
                final messages = snapshot.hasData
                    ? snapshot.data!
                    : controller.messagesForChatDisplay(widget.chatId);

                // Auto-scroll to the bottom whenever the message list grows.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _scrollController.position.maxScrollExtent > 0) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'Say hello to start the conversation',
                                style: TextStyle(color: scheme.onSurfaceVariant),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isMe = message.senderId == currentUser.uid;
                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    decoration: BoxDecoration(
                                      color: isMe ? scheme.primary : scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      message.message,
                                      style: TextStyle(
                                        color: isMe ? scheme.onPrimary : scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(hintText: 'Type a message...'),
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FloatingActionButton.small(
                              onPressed: _sending ? null : _send,
                              child: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
