import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/data/seed_data.dart';
import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late List<CreativePost> _posts;
  final _postCtrl = TextEditingController();
  bool _showCompose = false;

  @override
  void initState() {
    super.initState();
    _posts = SeedData.posts();
  }

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    final controller = context.read<AppController>();
    final uid = controller.currentUser?.uid ?? 'me';
    setState(() {
      final post = _posts[index];
      final likes = List<String>.from(post.likes);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      _posts[index] = post.copyWith(likes: likes);
    });
  }

  void _addPost() {
    final text = _postCtrl.text.trim();
    if (text.isEmpty) return;
    final controller = context.read<AppController>();
    final user = controller.currentUser;
    setState(() {
      _posts.insert(
        0,
        CreativePost(
          postId: 'post_${DateTime.now().millisecondsSinceEpoch}',
          creatorId: user?.uid ?? 'me',
          creatorName: user?.name ?? 'You',
          creatorImage: user?.profileImage ?? '',
          creatorRole: user?.role ?? UserRole.freelancer,
          content: text,
          mediaUrls: const [],
          createdAt: DateTime.now(),
          likes: const [],
          commentCount: 0,
        ),
      );
      _postCtrl.clear();
      _showCompose = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.read<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Creative Feed', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'New post',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => setState(() => _showCompose = !_showCompose),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Compose box ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showCompose ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: SceneCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SceneCachedAvatar(
                        imageUrl: controller.currentUser?.profileImage ?? '',
                        name: controller.currentUser?.name ?? 'Me',
                        radius: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "What's on your mind?",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share a project update, behind-the-scenes moment, or collaboration opportunity…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _showCompose = false;
                          _postCtrl.clear();
                        }),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ScenePillButton(label: 'Post', icon: Icons.send_rounded, onPressed: _addPost),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
          if (_showCompose) const SizedBox(height: 16),

          // ── Posts ──────────────────────────────────────────────────
          ..._posts.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PostCard(
                    post: entry.value,
                    currentUserId: controller.currentUser?.uid ?? 'me',
                    onLike: () => _toggleLike(entry.key),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ── Post card ─────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
  });

  final CreativePost post;
  final String currentUserId;
  final VoidCallback onLike;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liked = post.likes.contains(currentUserId);

    return SceneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Row(
            children: [
              SceneCachedAvatar(imageUrl: post.creatorImage, name: post.creatorName, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.creatorName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      '${post.creatorRole.label} • ${_relativeTime(post.createdAt)}',
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SceneTag(label: post.creatorRole.label),
            ],
          ),
          const SizedBox(height: 12),

          // ── Content ──────────────────────────────────────────────
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium),

          // ── Media ────────────────────────────────────────────────
          if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SceneCachedImage(url: post.mediaUrls.first, height: 180),
            ),
          ],
          const SizedBox(height: 14),

          // ── Actions ──────────────────────────────────────────────
          Row(
            children: [
              _ActionButton(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                label: '${post.likes.length}',
                color: liked ? Colors.red : scheme.onSurfaceVariant,
                onTap: onLike,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.commentCount}',
                color: scheme.onSurfaceVariant,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: scheme.onSurfaceVariant,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
