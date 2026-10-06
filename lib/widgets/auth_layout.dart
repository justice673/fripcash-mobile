import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/tablet_constrained_content.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
    this.label,
  });

  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 0),
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
        label: Text(
          label ?? t.back,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.display(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PillPrimaryButton(label: label, onPressed: onPressed);
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.backLabel,
    this.onBack,
  });

  final Widget child;
  final String? backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: TabletAuthScrollBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthBackButton(
                label: backLabel ?? t.back,
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
