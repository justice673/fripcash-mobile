import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/change_password_screen.dart';
import 'package:frip_cash/screens/courier_home_screen.dart';
import 'package:frip_cash/screens/verification_loader_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/auth_layout.dart';
import 'package:frip_cash/widgets/otp_input.dart';
import 'package:frip_cash/widgets/pill_button.dart';

/// First-login phone OTP for courier surface (`preAuthToken` only).
class CourierOtpScreen extends StatefulWidget {
  const CourierOtpScreen({
    super.key,
    required this.preAuthToken,
    required this.phoneMasked,
    this.otpLength = 6,
    this.otpAlreadySent = true,
  });

  final String preAuthToken;
  final String phoneMasked;
  final int otpLength;
  final bool otpAlreadySent;

  @override
  State<CourierOtpScreen> createState() => _CourierOtpScreenState();
}

class _CourierOtpScreenState extends State<CourierOtpScreen> {
  static const _resendDelaySeconds = 60;

  String _code = '';
  int _secondsRemaining = _resendDelaySeconds;
  Timer? _timer;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    if (!widget.otpAlreadySent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resendCode(silent: true);
      });
    }
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

  bool get _canSubmit => !_submitting && _code.length == widget.otpLength;

  Future<void> _verifyCode() async {
    setState(() => _submitting = true);
    try {
      await MockSession.instance.verifyCourierOtp(
        code: _code,
        preAuthToken: widget.preAuthToken,
      );
      if (!mounted) return;
      await _routeAfterCourierAuth(context);
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

  Future<void> _resendCode({bool silent = false}) async {
    final t = AppLocalizations.of(context)!;
    if (!silent && _secondsRemaining > 0) return;
    try {
      await MockSession.instance.resendCourierOtp(
        preAuthToken: widget.preAuthToken,
      );
      _startTimer();
      if (!mounted || silent) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.newCodeSent),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'OTP_RATE_LIMITED') {
        _startTimer();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
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
    final displayPhone = widget.phoneMasked.isNotEmpty
        ? widget.phoneMasked
        : '••••';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _SoftGlow(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: AuthBackButton(
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
                              displayPhone,
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
                              length: widget.otpLength,
                              onChanged: (code) =>
                                  setState(() => _code = code),
                              onCompleted: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 28),
                            if (_secondsRemaining > 0)
                              Text(
                                '${t.resendCodeIn} ${_secondsRemaining}s',
                                style: AppTypography.style(
                                  fontSize: 14,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.55),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () => _resendCode(),
                                child: Text(t.resendCode),
                              ),
                            const SizedBox(height: 28),
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
    );
  }
}

/// After full courier token: force password change then home.
Future<void> routeAfterCourierAuth(BuildContext context) =>
    _routeAfterCourierAuth(context);

Future<void> _routeAfterCourierAuth(BuildContext context) async {
  if (!context.mounted) return;
  if (MockSession.instance.mustChangePassword) {
    VerificationLoaderScreen.push(
      context,
      nextScreen: const ChangePasswordScreen(
        forced: true,
        replaceWithCourierHome: true,
      ),
    );
    return;
  }
  VerificationLoaderScreen.push(
    context,
    nextScreen: const CourierHomeScreen(),
  );
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -80,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.1,
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.background.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
