import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';

class HomeTutorialsSection extends StatelessWidget {
  const HomeTutorialsSection({super.key, this.compact = false});

  /// Tighter padding when embedded in Help (and similar screens).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 0 : 16, compact ? 0 : 28, compact ? 0 : 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.tutorialsTitle,
            style: TextStyle(
              fontSize: compact ? 17 : 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.tutorialsSubtitle,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          _TutorialCard(
            icon: Icons.play_circle_outline,
            title: t.tutorialSellIndividual,
            subtitle: t.videoDuration2min,
          ),
          const SizedBox(height: 10),
          _TutorialCard(
            icon: Icons.play_circle_outline,
            title: t.tutorialCreateShop,
            subtitle: t.videoDuration3min,
          ),
          const SizedBox(height: 10),
          _TutorialCard(
            icon: Icons.article_outlined,
            title: t.tutorialBecomePartner,
            subtitle: t.textGuideLabel,
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.contentComingSoon(title)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
