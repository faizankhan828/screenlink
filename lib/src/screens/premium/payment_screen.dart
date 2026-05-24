import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/scene_link_widgets.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _Plan { monthly, yearly }

class _PaymentScreenState extends State<PaymentScreen> {
  _Plan _selected = _Plan.yearly;
  bool _processing = false;
  bool _success = false;

  Future<void> _checkout() async {
    setState(() => _processing = true);
    // Simulated payment delay (replace with Stripe SDK call)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _processing = false;
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Payment successful! Welcome to Premium 🎉'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Premium', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))),
      body: _success ? _buildSuccess(context) : _buildPlans(context, scheme),
    );
  }

  // ── Plan selection ────────────────────────────────────────────────────────

  Widget _buildPlans(BuildContext context, ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.workspace_premium_rounded, color: scheme.primary, size: 44),
                const SizedBox(height: 12),
                Text(
                  'SceneLink Premium',
                  style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlock analytics, priority visibility, and advanced insights.',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('What\'s included', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (final feature in _premiumFeatures)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(feature.$2, color: scheme.primary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(feature.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          Text('Choose your plan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Monthly',
            price: '£6.99',
            period: '/month',
            badge: null,
            selected: _selected == _Plan.monthly,
            onTap: () => setState(() => _selected = _Plan.monthly),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Yearly',
            price: '£49.99',
            period: '/year',
            badge: 'Save 40%',
            selected: _selected == _Plan.yearly,
            onTap: () => setState(() => _selected = _Plan.yearly),
          ),
          const SizedBox(height: 32),

          // Checkout button
          FilledButton(
            onPressed: _processing ? null : _checkout,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _processing
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Subscribe — ${_selected == _Plan.monthly ? '£6.99/mo' : '£49.99/yr'}',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Text('Secured by Stripe test mode · Cancel anytime', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  // ── Success state ─────────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: scheme.primary, size: 54),
            ),
            const SizedBox(height: 24),
            Text('You\'re Premium!', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Enjoy unlimited analytics, priority visibility, and exclusive SceneLink features.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ScenePillButton(
              label: 'Go to Premium Dashboard',
              icon: Icons.bar_chart_rounded,
              onPressed: () => context.go('/premium-dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: 2),
                color: selected ? scheme.primary : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(badge!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: selected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: period,
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _premiumFeatures = [
  ('Engagement & reach analytics', Icons.bar_chart_rounded),
  ('Profile views breakdown', Icons.visibility_rounded),
  ('Priority listing in search', Icons.star_rounded),
  ('Advanced portfolio insights', Icons.insights_rounded),
  ('Collaboration performance metrics', Icons.handshake_rounded),
  ('Unlimited project applications', Icons.folder_copy_rounded),
];
