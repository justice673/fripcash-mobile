import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/tutorial/app_tutorial_keys.dart';
import 'package:frip_cash/tutorial/app_tutorial_prefs.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

abstract final class AppProductTour {
  static Future<void> showIfNeeded(BuildContext context) async {
    final seen = await AppTutorialPrefs.hasSeenTutorial();
    if (seen || !context.mounted) return;
    show(context);
  }

  static void show(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final targets = _buildTargets(t);

    TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.textPrimary,
      opacityShadow: 0.82,
      paddingFocus: 8,
      alignSkip: Alignment.topRight,
      textSkip: t.skipTutorial,
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontFamily: AppTypography.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      hideSkip: false,
      useSafeArea: true,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 350),
      pulseEnable: true,
      onFinish: () {
        AppTutorialPrefs.markTutorialSeen();
      },
      onSkip: () {
        AppTutorialPrefs.markTutorialSeen();
        return true;
      },
    ).show(context: context);
  }

  static List<TargetFocus> _buildTargets(AppLocalizations t) {
    return [
      _target(
        identify: 'search',
        key: AppTutorialKeys.searchBar,
        align: ContentAlign.bottom,
        title: t.tourSearchTitle,
        description: t.tourSearchDescription,
        shape: ShapeLightFocus.RRect,
        radius: 24,
      ),
      _target(
        identify: 'notifications',
        key: AppTutorialKeys.notifications,
        align: ContentAlign.bottom,
        title: t.tourNotificationsTitle,
        description: t.tourNotificationsDescription,
        shape: ShapeLightFocus.RRect,
        radius: 12,
      ),
      _target(
        identify: 'cart',
        key: AppTutorialKeys.cart,
        align: ContentAlign.bottom,
        title: t.tourCartTitle,
        description: t.tourCartDescription,
        shape: ShapeLightFocus.RRect,
        radius: 12,
      ),
      _target(
        identify: 'categories',
        key: AppTutorialKeys.categoryFilters,
        align: ContentAlign.bottom,
        title: t.tourCategoriesTitle,
        description: t.tourCategoriesDescription,
        shape: ShapeLightFocus.RRect,
        radius: 20,
      ),
      _target(
        identify: 'nav_home',
        key: AppTutorialKeys.navHome,
        align: ContentAlign.top,
        title: t.tourHomeTitle,
        description: t.tourHomeDescription,
        shape: ShapeLightFocus.RRect,
        radius: 16,
      ),
      _target(
        identify: 'nav_browse',
        key: AppTutorialKeys.navBrowse,
        align: ContentAlign.top,
        title: t.tourBrowseTitle,
        description: t.tourBrowseDescription,
        shape: ShapeLightFocus.RRect,
        radius: 16,
      ),
      _target(
        identify: 'nav_sell',
        key: AppTutorialKeys.navSell,
        align: ContentAlign.top,
        title: t.tourSellTitle,
        description: t.tourSellDescription,
        shape: ShapeLightFocus.RRect,
        radius: 16,
      ),
      _target(
        identify: 'nav_messages',
        key: AppTutorialKeys.navMessages,
        align: ContentAlign.top,
        title: t.tourMessagesTitle,
        description: t.tourMessagesDescription,
        shape: ShapeLightFocus.RRect,
        radius: 16,
      ),
      _target(
        identify: 'nav_profile',
        key: AppTutorialKeys.navProfile,
        align: ContentAlign.top,
        title: t.tourProfileTitle,
        description: t.tourProfileDescription,
        shape: ShapeLightFocus.RRect,
        radius: 16,
      ),
    ];
  }

  static TargetFocus _target({
    required dynamic identify,
    required GlobalKey key,
    required ContentAlign align,
    required String title,
    required String description,
    required ShapeLightFocus shape,
    double radius = 12,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: radius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          builder: (context, controller) => _TutorialCard(
            title: title,
            description: description,
          ),
        ),
      ],
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
