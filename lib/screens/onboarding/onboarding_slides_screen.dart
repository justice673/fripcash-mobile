import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/screens/product_library_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/seller_verification_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/onboarding/onboarding_illustrations.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class OnboardingSlidesScreen extends StatefulWidget {
  const OnboardingSlidesScreen({super.key});

  @override
  State<OnboardingSlidesScreen> createState() => _OnboardingSlidesScreenState();
}

class _OnboardingSlidesScreenState extends State<OnboardingSlidesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pageCount = 4;
  static const _kinds = [
    OnboardingArtKind.sell,
    OnboardingArtKind.free,
    OnboardingArtKind.delivery,
    OnboardingArtKind.welcome,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    final user = MockSession.instance.user;
    final openLibrary = user.isProximityShop;
    final needsVerification = user.isProximityShop || user.isPartnerEnseigne;

    void navigate(Widget screen) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => screen),
        (route) => false,
      );
      if (needsVerification &&
          SellerVerificationService.instance.requiresManualReview(user.sellerId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final t = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.sellerPendingVerificationMessage),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
            ),
          );
        });
      }
    }

    if (openLibrary) {
      navigate(const ProductLibraryScreen(fromSignup: true));
      return;
    }
    navigate(const MainShell());
  }

  void _onCtaPressed() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [
      t.onboardingSlide1Title,
      t.onboardingSlide2Title,
      t.onboardingSlide3Title,
      t.onboardingSlide4Title,
    ];
    final subtitles = [
      t.onboardingSlide1Subtitle,
      t.onboardingSlide2Subtitle,
      t.onboardingSlide3Subtitle,
      t.onboardingSlide4Subtitle,
    ];
    final isLastPage = _currentPage == _pageCount - 1;
    final ctaLabel = isLastPage ? t.onboardingGetStarted : t.continueAction;
    final media = MediaQuery.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBFFF3),
              Color(0xFFF7FFF9),
              Colors.white,
            ],
            stops: [0.0, 0.35, 0.72],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: media.padding.top + 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 96,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) => Text(
                      'FripCash',
                      style: AppTypography.style(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OnboardingSkipChip(
                    label: t.skipTutorial,
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final active = index == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 12,
                          child: OnboardingSlideReveal(
                            visible: active,
                            child: OnboardingHeroArt(
                              kind: _kinds[index],
                              active: active,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                titles[index],
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.12,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subtitles[index],
                                textAlign: TextAlign.center,
                                style: AppTypography.style(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 28, 18 + media.padding.bottom),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: active
                              ? AppColors.primary
                              : AppColors.textPrimary.withValues(alpha: 0.12),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  PillPrimaryButton(
                    label: ctaLabel,
                    onPressed: _onCtaPressed,
                    height: 56,
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
