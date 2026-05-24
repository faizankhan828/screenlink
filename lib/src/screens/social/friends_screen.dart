import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/data/seed_data.dart';
import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _connected = {};
  final Set<String> _requested = {};
  final Set<String> _declined = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _sendRequest(String uid) => setState(() {
        _requested.add(uid);
        _declined.remove(uid);
      });

  void _accept(String uid) => setState(() {
        _connected.add(uid);
        _requested.remove(uid);
      });

  void _decline(String uid) => setState(() {
        _declined.add(uid);
        _requested.remove(uid);
      });

  void _remove(String uid) => setState(() => _connected.remove(uid));

  @override
  Widget build(BuildContext context) {
    final allUsers = SeedData.users();
    final controller = context.watch<AppController>();
    final myUid = controller.currentUser?.uid ?? '';
    final others = allUsers.where((u) => u.uid != myUid).toList();

    final connections = others.where((u) => _connected.contains(u.uid)).toList();
    final incoming = others.where((u) => _requested.contains(u.uid) && !_connected.contains(u.uid)).toList();
    final suggestions = others.where((u) => !_connected.contains(u.uid) && !_declined.contains(u.uid)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Connections', style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Network (${connections.length})'),
            Tab(text: 'Requests (${incoming.length})'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── My Network tab ─────────────────────────────────────────
          _UserList(
            users: connections,
            emptyTitle: 'No connections yet',
            emptyMessage: 'Find and connect with creatives in the Discover tab.',
            emptyIcon: Icons.people_outline_rounded,
            actionBuilder: (user) => OutlinedButton(
              onPressed: () => _remove(user.uid),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),

          // ── Requests tab ────────────────────────────────────────────
          _UserList(
            users: incoming,
            emptyTitle: 'No pending requests',
            emptyMessage: 'Requests from other creatives will appear here.',
            emptyIcon: Icons.inbox_outlined,
            actionBuilder: (user) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: () => _accept(user.uid),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _decline(user.uid),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // ── Discover tab ────────────────────────────────────────────
          _UserList(
            users: suggestions,
            emptyTitle: 'You\'ve connected with everyone!',
            emptyMessage: 'Check back when new creatives join SceneLink.',
            emptyIcon: Icons.celebration_rounded,
            actionBuilder: (user) => FilledButton(
              onPressed: () => _sendRequest(user.uid),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Connect', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable user list ────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  const _UserList({
    required this.users,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.actionBuilder,
  });

  final List<AppUser> users;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(AppUser) actionBuilder;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SceneEmptyState(
            title: emptyTitle,
            message: emptyMessage,
            icon: emptyIcon,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return SceneCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SceneCachedAvatar(imageUrl: user.profileImage, name: user.name, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.verified)
                          const Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                      ],
                    ),
                    Text(
                      '${user.role.label} • ${user.location}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: user.skills.take(2).map((s) => SceneTag(label: s)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              actionBuilder(user),
            ],
          ),
        );
      },
    );
  }
}
