import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/courier_login_screen.dart';
import 'package:frip_cash/screens/login_screen.dart';
import 'package:frip_cash/screens/onboarding/onboarding_privacy_screen.dart';
import 'package:frip_cash/screens/reset_password_screen.dart';
import 'package:frip_cash/screens/verification_loader_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/auth_layout.dart';
import 'package:frip_cash/widgets/otp_input.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.purpose = OtpPurpose.resetPassword,
  });

  final String phoneNumber;
  final OtpPurpose purpose;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

enum OtpPurpose { resetPassword, signUp, signIn }

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _codeLength = 6;
  static const _resendDelaySeconds = 60;

  String _code = '';
  int _secondsRemaining = _resendDelaySeconds;
  Timer? _timer;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _resendDelaySeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  bool get _canSubmit => !_submitting && _code.length == _codeLength;

  String get _maskedPhone {
    final phone = widget.phoneNumber;
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 2)}X XXX ${phone.substring(phone.length - 3)}';
  }

  Future<void> _verifyCode() async {
    setState(() => _submitting = true);
    try {
      if (widget.purpose == OtpPurpose.signUp) {
        await MockSession.instance.verifyRegisterOtpAndComplete(
          phone: widget.phoneNumber,
          code: _code,
        );
        if (!mounted) return;
        if (MockSession.instance.isCourierSession) {
          await MockSession.instance.signOut();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const CourierLoginScreen(),
            ),
          );
          return;
        }
        VerificationLoaderScreen.push(
          context,
          nextScreen: const OnboardingPrivacyScreen(),
        );
        return;
      }

      if (widget.purpose == OtpPurpose.resetPassword) {
        await MockSession.instance.verifyResetOtp(
          phone: widget.phoneNumber,
          code: _code,
        );
        if (!mounted) return;
        VerificationLoaderScreen.push(
          context,
          nextScreen: ResetPasswordScreen(phoneNumber: widget.phoneNumber),
        );
        return;
      }

      // Legacy signIn purpose — redirect to password login.
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
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

  Future<void> _resendCode() async {
    final t = AppLocalizations.of(context)!;
    if (_secondsRemaining > 0) return;
    final purpose = switch (widget.purpose) {
      OtpPurpose.signUp => 'register',
      OtpPurpose.resetPassword => 'reset_password',
      OtpPurpose.signIn => 'register',
    };
    try {
      await MockSession.instance.requestOtp(
        phone: widget.phoneNumber,
        purpose: purpose,
      );
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.newCodeSent),
          behavior: SnackBarBehavior.floating,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopScope(
      canPop: widget.purpose != OtpPurpose.signUp,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _SoftGlow(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: widget.purpose == OtpPurpose.signUp
                      ? const SizedBox(height: 40)
                      : AuthBackButton(
                          label: t.back,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: AppBreakpoints.contentMaxWidth(context),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                              ),
                              child: const Icon(
                                Icons.sms_outlined,
                                size: 34,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              t.verificationTitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.enterCodeSentTo,
                              textAlign: TextAlign.center,
                              style: AppTypography.style(
                                fontSize: 15,
                                height: 1.45,
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '+224 $_maskedPhone',
                              textAlign: TextAlign.center,
                              style: AppTypography.style(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (kDebugMode) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Dev OTP: 000000',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                            const SizedBox(height: 36),
                            OtpInput(
                              length: _codeLength,
                              onChanged: (code) =>
                                  setState(() => _code = code),
                              onCompleted: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 28),
                            if (_secondsRemaining > 0)
                              Text(
                                '${t.resendCodeIn} ${_secondsRemaining}s',
                                textAlign: TextAlign.center,
                                style: AppTypography.style(
                                  fontSize: 14,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.55),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: _resendCode,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  t.resendCode,
                                  style: AppTypography.style(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 36),
                            PillPrimaryButton(
                              label: _submitting ? '…' : t.verify,
                              onPressed: _canSubmit ? _verifyCode : null,
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
        ],
      ),
    ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.14),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
