import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';

class HomeCtaSection extends StatelessWidget {
  const HomeCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              color: AppColors.primary,
              child: Column(
                children: [
                  Text(
                    t.homeCtaTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.homeCtaSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        onTap: () {
                          if (hasSellerAccess) {
                            if (isSellerVerificationPending) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t.sellerVerificationPendingBody),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CreateListingScreen(),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const BecomeSellerScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.homeCtaButton,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
