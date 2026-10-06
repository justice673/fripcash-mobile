import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';

/// Blocks a screen unless [allowed] is true.
class CapabilityGate extends StatelessWidget {
  const CapabilityGate({
    super.key,
    required this.allowed,
    required this.child,
    this.title,
    this.message,
  });

  final bool allowed;
  final Widget child;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockSession.instance,
      builder: (context, _) {
        if (allowed) return child;
        final t = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: AppColors.textPrimary.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title ?? t.sellerOnlyAreaTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message ?? t.becomeSellerRequiredHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
