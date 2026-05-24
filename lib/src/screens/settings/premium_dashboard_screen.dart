import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class PremiumDashboardScreen extends StatelessWidget {
  const PremiumDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final analytics = controller.analytics;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium analytics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              SceneMetricCard(label: 'Profile views', value: '${analytics.profileViews}', icon: Icons.visibility_rounded, accentColor: Colors.blue),
              SceneMetricCard(label: 'Project engagement', value: '${analytics.projectEngagement}', icon: Icons.groups_rounded, accentColor: Colors.orange),
              SceneMetricCard(label: 'Requests', value: '${analytics.collaborationRequests}', icon: Icons.request_page_rounded, accentColor: Colors.green),
              SceneMetricCard(label: 'Portfolio clicks', value: '${analytics.portfolioClicks}', icon: Icons.link_rounded, accentColor: Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          SceneCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Momentum overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                _BarMetric(label: 'Profile views', value: analytics.profileViews, color: Colors.blue),
                _BarMetric(label: 'Project engagement', value: analytics.projectEngagement, color: Colors.orange),
                _BarMetric(label: 'Collaboration requests', value: analytics.collaborationRequests, color: Colors.green),
                _BarMetric(label: 'Portfolio clicks', value: analytics.portfolioClicks, color: Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarMetric extends StatelessWidget {
  const _BarMetric({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = (value.clamp(0, 1000) / 1000) * MediaQuery.of(context).size.width * 0.55;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('$value'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 12, color: color.withValues(alpha: 0.15)),
                Container(height: 12, width: width, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}