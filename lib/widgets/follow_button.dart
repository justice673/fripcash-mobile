import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/follow_store.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Straight-edged follow control — matches welcome/auth button style.
class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.sellerId,
    this.fullWidth = false,
  });

  final String sellerId;
  final bool fullWidth;

  static const _shape = RoundedRectangleBorder();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: FollowStore.instance,
      builder: (context, _) {
        final following = FollowStore.instance.isFollowing(sellerId);

        if (fullWidth) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => FollowStore.instance.toggle(sellerId),
              style: FilledButton.styleFrom(
                backgroundColor:
                    following ? Colors.grey.shade100 : AppColors.primary,
                foregroundColor:
                    following ? AppColors.textPrimary : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: _shape,
                textStyle: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(following ? t.following : t.follow),
            ),
          );
        }

        return OutlinedButton(
          onPressed: () => FollowStore.instance.toggle(sellerId),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                following ? AppColors.textPrimary : AppColors.primary,
            side: BorderSide(
              color: following ? Colors.grey.shade300 : AppColors.primary,
              width: 1.5,
            ),
            minimumSize: const Size(88, 40),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: _shape,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
          ),
          child: Text(
            following ? t.following : t.follow,
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: following ? AppColors.textPrimary : AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
