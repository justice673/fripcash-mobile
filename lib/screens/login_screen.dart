import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/screens/courier_login_screen.dart';
import 'package:frip_cash/screens/forgot_password_screen.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/screens/signup_screen.dart';
import 'package:frip_cash/screens/verification_loader_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/courier_auth_nav.dart';
import 'package:frip_cash/widgets/auth_step_actions.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/consent_checkboxes.dart';
import 'package:frip_cash/widgets/tablet_constrained_content.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _marketingAccepted = false;
  bool _termsAccepted = false;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _phoneController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      _termsAccepted &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  void _showLegalDialog({required String title, required String body}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  /// Same Sign in form — courier accounts use a different API audience.
  Future<bool> _tryCourierSignIn({
    required String phone,
    required String password,
  }) async {
    final result = await MockSession.instance.loginCourier(
      phone: phone,
      password: password,
    );
    if (!mounted) return true;
    await navigateCourierLoginResult(context, result);
    return true;
  }

  Future<void> _signIn() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    setState(() => _submitting = true);
    try {
      await MockSession.instance.loginMarketplace(
        phone: phone,
        password: password,
        termsAccepted: _termsAccepted,
      );
      if (!mounted) return;
      final user = MockSession.instance.user;
      if (user.role == UserRole.livreur ||
          MockSession.instance.isCourierSession) {
        await MockSession.instance.signOut();
        if (!mounted) return;
        await _tryCourierSignIn(phone: phone, password: password);
        return;
      }
      VerificationLoaderScreen.push(
        context,
        nextScreen: const MainShell(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      // Courier phones must use /auth/courier/login. Nest returns 403
      // WRONG_AUTH_SURFACE (sometimes plain FORBIDDEN) on marketplace login.
      final retryCourier = e.code == 'WRONG_AUTH_SURFACE' ||
          e.code == 'FORBIDDEN_AUDIENCE' ||
          e.code == 'FORBIDDEN' ||
          e.code.toUpperCase() == 'FORBIDDEN' ||
          e.statusCode == 403;
      if (retryCourier) {
        try {
          await _tryCourierSignIn(phone: phone, password: password);
        } on ApiException catch (courierErr) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authErrorMessage(courierErr)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
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
              GestureDetector(
                onLongPress: kDebugMode
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CourierLoginScreen(),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  t.welcomeBack,
                  style: AppTypography.display(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.loginSubtitle,
                style: AppTypography.style(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              AuthFieldLabel(t.phoneNumber),
              const SizedBox(height: 8),
              PhoneNumberField(controller: _phoneController),
              const SizedBox(height: 16),
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
              if (kDebugMode) ...[
                const SizedBox(height: 10),
                Text(
                  'API login — no OTP. Dev register OTP: 000000\n'
                  'Courier: same Sign in (admin phone + password)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary.withValues(alpha: 0.45),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ConsentCheckboxes(
                marketingAccepted: _marketingAccepted,
                termsAccepted: _termsAccepted,
                onMarketingChanged: (value) {
                  setState(() => _marketingAccepted = value);
                },
                onTermsChanged: (value) {
                  setState(() => _termsAccepted = value);
                },
                onTermsTap: () => _showLegalDialog(
                  title: t.termsAndConditions,
                  body: t.legalTermsBody,
                ),
                onPrivacyTap: () => _showLegalDialog(
                  title: t.privacyPolicy,
                  body: t.legalPrivacyBody,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ForgotPasswordScreen(
                          initialPhone: _phoneController.text.trim(),
                        ),
                      ),
                    );
                  },
                  child: Text(t.forgotPasswordQuestion),
                ),
              ),
              const SizedBox(height: 8),
              AuthStepActions(
                onBack: () => Navigator.of(context).pop(),
                primaryLabel: _submitting ? '…' : t.signIn,
                onPrimary: _canSubmit ? _signIn : null,
              ),
              const SizedBox(height: 8),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                    children: [
                      TextSpan(text: t.noAccountPrompt),
                      TextSpan(
                        text: t.signUp,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                      ),
                    ],
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
