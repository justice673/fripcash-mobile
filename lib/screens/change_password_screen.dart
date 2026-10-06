import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/courier_home_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    this.forced = false,
    this.replaceWithCourierHome = false,
  });

  /// Block back until password is changed (courier first login).
  final bool forced;

  /// After success, replace stack with [CourierHomeScreen].
  final bool replaceWithCourierHome;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  bool get _canSubmit =>
      !_submitting &&
      _currentController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmController.text;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _currentController,
      _passwordController,
      _confirmController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await MockSession.instance.changePassword(
        currentPassword: _currentController.text,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.passwordUpdatedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (widget.replaceWithCourierHome) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const CourierHomeScreen()),
          (_) => false,
        );
        return;
      }
      Navigator.of(context).pop();
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
    return PopScope(
      canPop: !widget.forced,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          automaticallyImplyLeading: !widget.forced,
          title: Text(
            t.changePassword,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    if (widget.forced) ...[
                      Text(
                        'Change your temporary password before continuing.',
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    AuthFieldLabel(t.currentPassword),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthFieldLabel(t.newPasswordLabel),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      hintText: t.choosePassword,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthFieldLabel(t.confirmPassword),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      hintText: t.confirmPasswordShort,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PillPrimaryButton(
                  label: _submitting ? '…' : t.save,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
