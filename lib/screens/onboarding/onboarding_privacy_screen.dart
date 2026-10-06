import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/onboarding/onboarding_slides_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class OnboardingPrivacyScreen extends StatelessWidget {
  const OnboardingPrivacyScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const OnboardingSlidesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.onboardingPrivacyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.onboardingPrivacyBody1,
                        style: AppTypography.style(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppColors.textPrimary.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: AppTypography.style(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.72),
                          ),
                          children: [
                            TextSpan(text: t.onboardingPrivacyBody2Prefix),
                            TextSpan(
                              text: t.cookiePolicy,
                              style: AppTypography.style(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            TextSpan(text: t.onboardingPrivacyBody2Suffix),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.onboardingDataPurposesTitle,
                        style: AppTypography.style(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PurposeRow(label: t.onboardingDataPurposeSecurity),
                      _PurposeRow(label: t.onboardingDataPurposeAnalytics),
                      _PurposeRow(label: t.onboardingDataPurposeMessaging),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PillPrimaryButton(
                label: t.acceptAll,
                onPressed: () => _continue(context),
              ),
              const SizedBox(height: 10),
              PillOutlinedButton(
                label: t.rejectAll,
                onPressed: () => _continue(context),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => _continue(context),
                  child: Text(
                    t.manageCookies,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurposeRow extends StatelessWidget {
  const _PurposeRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
