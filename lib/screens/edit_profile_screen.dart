import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  String? _zoneId;
  List<CatalogZone> _apiZones = const [];
  bool _zonesLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = MockSession.instance.user;
    _nameController = TextEditingController(text: user.name);
    _addressController = TextEditingController(text: user.address ?? '');
    _phoneController = TextEditingController(text: user.phone);
    _zoneId = user.zoneId;
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() => _zonesLoading = true);
    try {
      final zones = await MeApi.instance.fetchZones();
      if (!mounted) return;
      setState(() {
        _apiZones = zones;
        if (_zoneId != null && !zones.any((z) => z.id == _zoneId)) {
          _zoneId = null;
        }
        _zonesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiZones = const [];
        _zoneId = null;
        _zonesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await MeApi.instance.patchMe({
        'displayName': _nameController.text.trim(),
        if (_zoneId != null) 'zoneId': _zoneId,
        'address': _addressController.text.trim(),
      });
      await MockSession.instance.refreshMe();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.profileUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<DropdownMenuItem<String>> get _zoneItems {
    final french = AppLocaleService.instance.locale?.languageCode != 'en';
    return [
      for (final zone in _apiZones)
        DropdownMenuItem(
          value: zone.id,
          child: Text(zone.label(french: french)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final zoneValue =
        _zoneId != null && _apiZones.any((z) => z.id == _zoneId)
            ? _zoneId
            : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.editMyProfile,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  AuthFieldLabel(t.nameLabel),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _nameController,
                    hintText: t.nameOrUsernameHint,
                  ),
                  const SizedBox(height: 16),
                  AuthFieldLabel(t.phone),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _phoneController,
                    hintText: t.phone,
                    enabled: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      t.phoneCannotBeEditedHere,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthFieldLabel(t.zone),
                  const SizedBox(height: 8),
                  if (_zonesLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    AuthDropdownField<String>(
                      value: zoneValue,
                      hintText: t.chooseZone,
                      items: _zoneItems,
                      onChanged: (v) => setState(() => _zoneId = v),
                    ),
                  const SizedBox(height: 16),
                  AuthFieldLabel(t.address),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _addressController,
                    hintText: t.addressHintShort,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PillPrimaryButton(
                label: _saving ? '…' : t.save,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
