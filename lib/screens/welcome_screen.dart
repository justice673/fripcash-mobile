import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/login_screen.dart';
import 'package:frip_cash/screens/signup_screen.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/tablet_constrained_content.dart';
import 'package:frip_cash/widgets/welcome_masonry_grid.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LanguageSelector(),
            const Expanded(flex: 48, child: WelcomeMasonryGrid()),
            const _WelcomeContent(),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  Future<void> _showLanguagePicker(BuildContext context) async {
    final current = Localizations.localeOf(context).languageCode;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                label: 'English',
                selected: current == 'en',
                onTap: () => Navigator.of(context).pop('en'),
              ),
              _LanguageOption(
                label: 'Français',
                selected: current == 'fr',
                onTap: () => Navigator.of(context).pop('fr'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    AppLocaleService.instance.setLocale(Locale(selected));
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final label = languageCode == 'fr' ? 'Français' : 'English';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => _showLanguagePicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _openSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
      child: TabletConstrainedContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.welcomeBuySell,
              textAlign: TextAlign.center,
              style: AppTypography.style(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 28),
            PillPrimaryButton(
              label: t.signUpButton,
              onPressed: () => _openSignUp(context),
            ),
            const SizedBox(height: 12),
            PillOutlinedButton(
              label: t.alreadyHaveAccount,
              onPressed: () => _openLogin(context),
            ),
          ],
        ),
      ),
    );
  }
}
