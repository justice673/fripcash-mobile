import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/otp_verification_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/auth_layout.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialPhone = ''});

  final String initialPhone;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _phoneController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting && _phoneController.text.trim().isNotEmpty;

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    setState(() => _submitting = true);
    try {
      await MockSession.instance.forgotPassword(phone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phone,
            purpose: OtpPurpose.resetPassword,
          ),
        ),
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
      backLabel: t.backToLogin,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthScreenHeader(
            title: t.forgotPasswordTitle,
            subtitle: t.forgotPasswordSubtitle,
          ),
          const SizedBox(height: 32),
          AuthFieldLabel(t.phoneNumber),
          const SizedBox(height: 8),
          PhoneNumberField(controller: _phoneController),
          const SizedBox(height: 32),
          AuthPrimaryButton(
            label: _submitting ? '…' : t.sendCode,
            onPressed: _canSubmit ? _sendCode : null,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              t.smsCodeInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
