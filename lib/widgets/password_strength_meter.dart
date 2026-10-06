import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

enum PasswordStrength { empty, weak, fair, good, strong }

class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.strength,
    required this.score,
    required this.hasMinLength,
    required this.hasLetter,
    required this.hasDigit,
  });

  final PasswordStrength strength;
  final int score; // 0–4
  final bool hasMinLength;
  final bool hasLetter;
  final bool hasDigit;
}

PasswordStrengthResult evaluatePassword(
  String password, {
  int minLength = 8,
}) {
  if (password.isEmpty) {
    return const PasswordStrengthResult(
      strength: PasswordStrength.empty,
      score: 0,
      hasMinLength: false,
      hasLetter: false,
      hasDigit: false,
    );
  }

  final hasMinLength = password.length >= minLength;
  final hasLetter = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasUpper = RegExp(r'[A-ZÀ-Ÿ]').hasMatch(password);
  final hasLower = RegExp(r'[a-zà-ÿ]').hasMatch(password);
  final hasSpecial = RegExp(r'[^A-Za-zÀ-ÿ0-9]').hasMatch(password);

  var score = 0;
  if (hasMinLength) score++;
  if (hasLetter && hasDigit) score++;
  if (hasUpper && hasLower) score++;
  if (hasSpecial || password.length >= 12) score++;

  if (!hasMinLength) {
    return PasswordStrengthResult(
      strength: PasswordStrength.weak,
      score: score.clamp(0, 1),
      hasMinLength: false,
      hasLetter: hasLetter,
      hasDigit: hasDigit,
    );
  }

  final strength = switch (score) {
    0 || 1 => PasswordStrength.weak,
    2 => PasswordStrength.fair,
    3 => PasswordStrength.good,
    _ => PasswordStrength.strong,
  };

  return PasswordStrengthResult(
    strength: strength,
    score: score.clamp(0, 4),
    hasMinLength: hasMinLength,
    hasLetter: hasLetter,
    hasDigit: hasDigit,
  );
}

/// Inline strength meter shown under password fields (signup / reset).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.minLength = 8,
  });

  final String password;
  final int minLength;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final result = evaluatePassword(password, minLength: minLength);
    if (result.strength == PasswordStrength.empty) {
      return const SizedBox.shrink();
    }

    final (label, color) = switch (result.strength) {
      PasswordStrength.empty => ('', AppColors.border),
      PasswordStrength.weak => (t.passwordStrengthWeak, AppColors.error),
      PasswordStrength.fair => (t.passwordStrengthFair, const Color(0xFFD4883A)),
      PasswordStrength.good => (t.passwordStrengthGood, AppColors.gold),
      PasswordStrength.strong => (t.passwordStrengthStrong, AppColors.sage),
    };

    final filled = result.strength == PasswordStrength.weak
        ? 1
        : result.strength == PasswordStrength.fair
            ? 2
            : result.strength == PasswordStrength.good
                ? 3
                : 4;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < filled ? color : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                label,
                style: AppTypography.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.hasMinLength
                      ? t.passwordStrengthHintOk
                      : t.passwordStrengthHintMin(minLength),
                  style: AppTypography.style(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _RuleChip(
                ok: result.hasMinLength,
                label: t.passwordRuleMinLength(minLength),
              ),
              _RuleChip(
                ok: result.hasLetter,
                label: t.passwordRuleLetter,
              ),
              _RuleChip(
                ok: result.hasDigit,
                label: t.passwordRuleDigit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.ok, required this.label});

  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.sage : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.sage.withValues(alpha: 0.12)
            : AppColors.rosePoudre.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.style(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
