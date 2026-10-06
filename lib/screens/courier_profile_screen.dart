import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/edit_profile_screen.dart';
import 'package:frip_cash/screens/help_screen.dart';
import 'package:frip_cash/screens/welcome_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

enum _DocType {
  nationalId,
  driversLicense,
  vehicleRegistration,
  insurance,
  profilePhoto,
}

enum _DocStatus { approved, pending, rejected }

class CourierProfileScreen extends StatefulWidget {
  const CourierProfileScreen({super.key});

  @override
  State<CourierProfileScreen> createState() => _CourierProfileScreenState();
}

class _CourierProfileScreenState extends State<CourierProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CourierRepository.instance.refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: ListenableBuilder(
        listenable: CourierRepository.instance,
        builder: (context, _) {
          final repo = CourierRepository.instance;
          final apiProfile = repo.profile;
          final zoneName = repo.zoneLabel(
            apiProfile?.zoneId ?? user.zoneId ?? '',
          );
          final isAvailable = repo.isAvailable;
          final displayName = (apiProfile?.displayName.isNotEmpty == true)
              ? apiProfile!.displayName
              : (user.name.isNotEmpty ? user.name : '—');
          final phone = (apiProfile?.phone.isNotEmpty == true)
              ? apiProfile!.phone
              : (user.phone.isNotEmpty ? user.phone : '—');
          final address = apiProfile?.address ?? user.address;
          final isVerified = apiProfile?.isVerified ?? false;
          final plate = (apiProfile?.plateNumber?.trim().isNotEmpty == true)
              ? apiProfile!.plateNumber!
              : '—';
          final vehicleRaw = apiProfile?.vehicleType;
          final vehicle = () {
            if (vehicleRaw == null || vehicleRaw.trim().isEmpty) return '—';
            switch (vehicleRaw.toLowerCase()) {
              case 'moto':
              case 'motorcycle':
                return t.courierVehicleMotorcycle;
              case 'voiture':
              case 'car':
                return 'Voiture';
              case 'velo':
              case 'bike':
                return 'Vélo';
              default:
                return vehicleRaw;
            }
          }();
          final memberSinceRaw = apiProfile?.memberSince;
          final memberSince = () {
            if (memberSinceRaw == null || memberSinceRaw.trim().isEmpty) {
              return '—';
            }
            final parsed = DateTime.tryParse(memberSinceRaw);
            if (parsed == null) {
              return memberSinceRaw.localizedDateLabel(t);
            }
            // Date only — e.g. "17 September 2026" / "17 septembre 2026"
            return DateFormat('d MMMM y', Localizations.localeOf(context).toString())
                .format(parsed);
          }();
          final docs = apiProfile?.documents ?? const [];
          final courierId = (apiProfile?.courierId.isNotEmpty == true)
              ? apiProfile!.courierId
              : (user.courierId ?? '—');

          if (repo.isLoading && apiProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.courierProfileTitle,
                      style: AppTypography.display(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: AppIcon(
                      Symbols.edit_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      t.editMyProfile,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ProfileHeader(
                name: displayName,
                roleLabel: t.courierRole,
                courierId: courierId,
                isVerified: isVerified,
                verifiedLabel: t.courierVerified,
                isAvailable: isAvailable,
                statusLabel: isAvailable ? t.active : t.unavailableShort,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isAvailable ? t.active : t.unavailableShort,
                  style: AppTypography.style(fontWeight: FontWeight.w700),
                ),
                value: isAvailable,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: (value) async {
                  try {
                    await repo.setAvailability(value);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              _SectionHeader(
                icon: Symbols.badge_rounded,
                title: t.courierPersonalInfo,
              ),
              _InfoCard(
                rows: [
                  _InfoRow(
                    icon: Symbols.person_rounded,
                    label: t.nameLabel,
                    value: displayName,
                  ),
                  _InfoRow(
                    icon: Symbols.call_rounded,
                    label: t.phone,
                    value: phone,
                  ),
                  _InfoRow(
                    icon: Symbols.location_on_rounded,
                    label: t.zone,
                    value: zoneName.isEmpty ? '—' : zoneName,
                  ),
                  if (address != null && address.isNotEmpty)
                    _InfoRow(
                      icon: Symbols.home_rounded,
                      label: t.address,
                      value: address,
                    ),
                  _InfoRow(
                    icon: Symbols.calendar_month_rounded,
                    label: t.courierMemberSince,
                    value: memberSince,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                icon: Symbols.two_wheeler_rounded,
                title: t.courierVehicleInfo,
              ),
              _InfoCard(
                rows: [
                  _InfoRow(
                    icon: Symbols.two_wheeler_rounded,
                    label: t.courierVehicleType,
                    value: vehicle,
                  ),
                  _InfoRow(
                    icon: Symbols.pin_rounded,
                    label: t.courierPlateNumber,
                    value: plate,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                icon: Symbols.description_rounded,
                title: t.courierSubmittedDocuments,
              ),
              Text(
                t.courierDocumentsSubtitle,
                style: AppTypography.style(
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Aucun document soumis pour le moment.',
                    textAlign: TextAlign.center,
                    style: AppTypography.style(
                      fontSize: 13,
                      color: AppColors.textPrimary.withValues(alpha: 0.55),
                    ),
                  ),
                )
              else
                ...docs.map((document) {
                  final type = _mapDocType(document.type);
                  final status = _mapDocStatus(document.status);
                  final submitted = (document.submittedAt ?? '').trim();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DocumentTile(
                      title: _documentTitle(t, type),
                      icon: _documentIcon(type),
                      status: status,
                      statusLabel: _documentStatusLabel(t, status),
                      submittedLabel: submitted.isEmpty
                          ? '—'
                          : t.courierSubmittedOn(
                              submitted.localizedDateLabel(t),
                            ),
                      onView: (document.fileUrl == null ||
                              document.fileUrl!.isEmpty)
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(document.fileUrl!),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      viewLabel: t.courierViewDocument,
                    ),
                  );
                }),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Symbols.help_rounded,
                label: t.help,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Symbols.logout_rounded,
                label: t.signOut,
                destructive: true,
                onTap: () async {
                  await MockSession.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const WelcomeScreen(),
                    ),
                    (_) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  _DocType _mapDocType(String raw) {
    switch (raw) {
      case 'nationalId':
        return _DocType.nationalId;
      case 'driversLicense':
        return _DocType.driversLicense;
      case 'vehicleRegistration':
        return _DocType.vehicleRegistration;
      case 'insurance':
        return _DocType.insurance;
      case 'profilePhoto':
        return _DocType.profilePhoto;
      default:
        return _DocType.nationalId;
    }
  }

  _DocStatus _mapDocStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return _DocStatus.approved;
      case 'rejected':
        return _DocStatus.rejected;
      default:
        return _DocStatus.pending;
    }
  }

  IconData _documentIcon(_DocType type) {
    return switch (type) {
      _DocType.nationalId => Symbols.id_card_rounded,
      _DocType.driversLicense => Symbols.badge_rounded,
      _DocType.vehicleRegistration => Symbols.directions_car_rounded,
      _DocType.insurance => Symbols.shield_rounded,
      _DocType.profilePhoto => Symbols.photo_camera_rounded,
    };
  }

  String _documentTitle(AppLocalizations t, _DocType type) {
    return switch (type) {
      _DocType.nationalId => t.courierDocNationalId,
      _DocType.driversLicense => t.courierDocDriversLicense,
      _DocType.vehicleRegistration => t.courierDocVehicleRegistration,
      _DocType.insurance => t.courierDocInsurance,
      _DocType.profilePhoto => t.courierDocProfilePhoto,
    };
  }

  String _documentStatusLabel(AppLocalizations t, _DocStatus status) {
    return switch (status) {
      _DocStatus.approved => t.courierDocStatusApproved,
      _DocStatus.pending => t.courierDocStatusPending,
      _DocStatus.rejected => t.courierDocStatusRejected,
    };
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.roleLabel,
    required this.courierId,
    required this.isVerified,
    required this.verifiedLabel,
    required this.isAvailable,
    required this.statusLabel,
  });

  final String name;
  final String roleLabel;
  final String courierId;
  final bool isVerified;
  final String verifiedLabel;
  final bool isAvailable;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.style(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  roleLabel,
                  style: AppTypography.style(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.courierIdLabel}: $courierId',
                  style: AppTypography.style(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (isVerified)
                      _StatusChip(
                        label: verifiedLabel,
                        color: AppColors.primary,
                        background: AppColors.primary.withValues(alpha: 0.18),
                        icon: Symbols.verified_rounded,
                      ),
                    _StatusChip(
                      label: statusLabel,
                      color: isAvailable
                          ? AppColors.primary
                          : const Color(0xFFFFB74D),
                      background: isAvailable
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Colors.orange.withValues(alpha: 0.18),
                      icon: isAvailable
                          ? Symbols.sensors_rounded
                          : Symbols.pause_circle_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final part = parts.first;
      return part.length >= 2
          ? part.substring(0, 2).toUpperCase()
          : part.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 13, color: color, filled: true),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AppIcon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.style(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            icon,
            size: 18,
            color: AppColors.textPrimary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 13,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.title,
    required this.icon,
    required this.status,
    required this.statusLabel,
    required this.submittedLabel,
    required this.onView,
    required this.viewLabel,
  });

  final String title;
  final IconData icon;
  final _DocStatus status;
  final String statusLabel;
  final String submittedLabel;
  final VoidCallback? onView;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      _DocStatus.approved => AppColors.primary,
      _DocStatus.pending => Colors.orange.shade800,
      _DocStatus.rejected => Colors.red.shade700,
    };
    final statusBg = switch (status) {
      _DocStatus.approved => AppColors.primary.withValues(alpha: 0.12),
      _DocStatus.pending => Colors.orange.shade50,
      _DocStatus.rejected => Colors.red.shade50,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: AppIcon(
                icon,
                size: 20,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  submittedLabel,
                  style: AppTypography.style(
                    fontSize: 12,
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onView,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              viewLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red.shade700 : AppColors.textPrimary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              AppIcon(icon, size: 22, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.style(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              AppIcon(
                AppIcons.chevronRight,
                size: 20,
                color: color.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
