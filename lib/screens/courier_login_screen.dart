import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/courier_auth_nav.dart';
import 'package:frip_cash/widgets/auth_step_actions.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/courier_bike_illustration.dart';
import 'package:frip_cash/widgets/tablet_constrained_content.dart';

class CourierLoginScreen extends StatefulWidget {
  const CourierLoginScreen({super.key});

  @override
  State<CourierLoginScreen> createState() => _CourierLoginScreenState();
}

class _CourierLoginScreenState extends State<CourierLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _signIn() async {
    setState(() => _submitting = true);
    try {
      final result = await MockSession.instance.loginCourier(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await navigateCourierLoginResult(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
              const Center(
                child: CourierBikeIllustration(size: 240),
              ),
              const SizedBox(height: 12),
              Text(
                t.courierSpaceTitle,
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.courierLoginSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.style(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              AuthFieldLabel(t.phoneNumber),
              const SizedBox(height: 8),
              PhoneNumberField(controller: _phoneController),
              const SizedBox(height: 20),
              AuthFieldLabel(t.password),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _passwordController,
                hintText: t.password,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AuthStepActions(
                onBack: () => Navigator.of(context).pop(),
                primaryLabel: _submitting ? '…' : t.signIn,
                onPrimary: _canSubmit ? _signIn : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
