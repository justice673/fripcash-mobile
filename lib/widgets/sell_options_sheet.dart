import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/copy_listing_screen.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/screens/drafts_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';

Future<void> showSellOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SellOptionsSheet(),
  );
}

class _SellOptionsSheet extends StatefulWidget {
  const _SellOptionsSheet();

  @override
  State<_SellOptionsSheet> createState() => _SellOptionsSheetState();
}

class _SellOptionsSheetState extends State<_SellOptionsSheet> {
  bool _showPromo = true;

  void _push(Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              t.sellAnItem,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_showPromo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.18),
                            AppColors.rosePoudre,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.checkroom,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 28),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.sellPromoTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.sellPromoSubtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.3,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _showPromo = false),
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _SellOptionTile(
            icon: Icons.add,
            label: t.createNewListing,
            onTap: () => _push(const CreateListingScreen()),
          ),
          _SellOptionTile(
            icon: Icons.star_outline,
            label: t.listFromTemplate,
            onTap: () => _push(const CreateListingScreen()),
          ),
          _SellOptionTile(
            icon: Icons.edit_outlined,
            label: t.editDraftListings,
            onTap: () => _push(const DraftsScreen()),
          ),
          _SellOptionTile(
            icon: Icons.copy_all_outlined,
            label: t.copyAListing,
            onTap: () => _push(const CopyListingScreen()),
          ),
          _SellOptionTile(
            icon: Icons.refresh,
            label: t.repostAnItem,
            badge: t.nowWithPhotos,
            onTap: () => _push(const CopyListingScreen()),
          ),
        ],
      ),
    );
  }
}

class _SellOptionTile extends StatelessWidget {
  const _SellOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
