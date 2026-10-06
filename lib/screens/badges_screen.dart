import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';

class MockBadge {
  const MockBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
}

const mockBadges = <MockBadge>[
  MockBadge(
    id: 'first_sale',
    title: 'Première vente',
    description: 'Tu as vendu ton premier article sur FripCash.',
    icon: Icons.emoji_events_outlined,
    unlocked: true,
  ),
  MockBadge(
    id: 'fast_shipper',
    title: 'Expédition rapide',
    description: '5 colis préparés en moins de 24 h.',
    icon: Icons.local_shipping_outlined,
    unlocked: true,
  ),
  MockBadge(
    id: 'top_rated',
    title: 'Vendeur 5 étoiles',
    description: '10 avis avec une note moyenne de 5/5.',
    icon: Icons.star_outline,
    unlocked: false,
  ),
  MockBadge(
    id: 'eco_seller',
    title: 'Éco-responsable',
    description: '20 articles seconde main vendus.',
    icon: Icons.eco_outlined,
    unlocked: false,
  ),
];

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.badges,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockBadges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final badge = mockBadges[index];
          return _BadgeTile(badge: badge);
        },
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final MockBadge badge;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final unlocked = badge.unlocked;
    final (title, description) = switch (badge.id) {
      'first_sale' => (t.badgeFirstSaleTitle, t.badgeFirstSaleDescription),
      'fast_shipper' => (t.badgeFastShipperTitle, t.badgeFastShipperDescription),
      'top_rated' => (t.badgeTopRatedTitle, t.badgeTopRatedDescription),
      'eco_seller' => (t.badgeEcoSellerTitle, t.badgeEcoSellerDescription),
      _ => (badge.title, badge.description),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        color: unlocked ? null : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              color: unlocked ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: unlocked ? null : Colors.grey.shade600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            Icon(Icons.lock_outline, size: 18, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
