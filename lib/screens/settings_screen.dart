import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/change_password_screen.dart';
import 'package:frip_cash/screens/edit_profile_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/seller_verification_service.dart';
import 'package:frip_cash/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _pushEnabled;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final prefs = await MeApi.instance.fetchPreferences();
      if (!mounted) return;
      setState(() {
        _pushEnabled = prefs['pushEnabled'] == true;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.message;
        _pushEnabled = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
        _pushEnabled = null;
      });
    }
  }

  Future<void> _onPushChanged(bool value) async {
    final previous = _pushEnabled;
    setState(() {
      _pushEnabled = value;
      _saving = true;
    });
    try {
      final saved = await MeApi.instance.patchPreferences({'pushEnabled': value});
      if (!mounted) return;
      setState(() {
        _pushEnabled = saved['pushEnabled'] == true;
        _saving = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = previous;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = previous;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.customization,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          MockSession.instance,
          SellerVerificationService.instance,
        ]),
        builder: (context, _) {
          final user = MockSession.instance.user;

          return ListView(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: t.editMyProfile,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: t.changePassword,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_loadError != null)
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(_loadError!),
                  trailing: TextButton(
                    onPressed: _loadPreferences,
                    child: Text(t.retryAction),
                  ),
                )
              else
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(t.pushNotifications),
                  subtitle: Text(t.ordersMessagesOffers),
                  value: _pushEnabled ?? false,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_saving || _pushEnabled == null)
                      ? null
                      : _onPushChanged,
                ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  t.sellerAccountSection,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ),
              if (!user.role.isSeller)
                _SettingsTile(
                  icon: Icons.storefront_outlined,
                  label: t.becomeSellerAccountTile,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BecomeSellerScreen(),
                      ),
                    );
                  },
                )
              else
                _SettingsTile(
                  icon: Icons.storefront_outlined,
                  label: t.sellerAccountSection,
                  onTap: null,
                  trailing: Text(
                    user.hasShop ? 'Boutique' : 'Particulier',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary.withValues(alpha: 0.55),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
