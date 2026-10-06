import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/login_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/auth_layout.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _passwordController.removeListener(_onFormChanged);
    _confirmPasswordController.removeListener(_onFormChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _submitting = false;

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text;

  bool get _showPasswordMismatch =>
      _confirmPasswordController.text.isNotEmpty && !_passwordsMatch;

  bool get _canSubmit =>
      !_submitting &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      _passwordsMatch;

  Future<void> _resetPassword() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await MockSession.instance.resetPassword(
        phone: widget.phoneNumber,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(
            successMessage: t.passwordUpdatedSuccess,
          ),
        ),
        (route) => false,
      );
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
    return AuthScaffold(
      backLabel: t.back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthScreenHeader(
            title: t.newPasswordTitle,
            subtitle: t.newPasswordSubtitle,
          ),
          const SizedBox(height: 32),
          AuthFieldLabel(t.newPasswordLabel),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _passwordController,
            hintText: t.choosePassword,
            obscureText: _obscurePassword,
            prefixIcon: Icon(
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
          const SizedBox(height: 20),
          AuthFieldLabel(t.confirmPassword),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: t.confirmYourPassword,
            obscureText: _obscureConfirmPassword,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.textPrimary,
              size: 22,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
          if (_showPasswordMismatch) ...[
            const SizedBox(height: 8),
            Text(
              t.passwordsDoNotMatch,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade600,
              ),
            ),
          ],
          const SizedBox(height: 32),
          AuthPrimaryButton(
            label: _submitting ? '…' : t.resetPasswordButton,
            onPressed: _canSubmit ? _resetPassword : null,
          ),
        ],
      ),
    );
  }
}
