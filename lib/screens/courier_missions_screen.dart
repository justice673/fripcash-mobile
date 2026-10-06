import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/courier_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/courier_mission_detail_screen.dart';
import 'package:frip_cash/screens/notifications_screen.dart';
import 'package:frip_cash/screens/wallet_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/courier_bike_illustration.dart';
import 'package:material_symbols_icons/symbols.dart';

enum _MissionFilter { all, active, completed }

class CourierMissionsScreen extends StatefulWidget {
  const CourierMissionsScreen({super.key});

  @override
  State<CourierMissionsScreen> createState() => _CourierMissionsScreenState();
}

class _CourierMissionsScreenState extends State<CourierMissionsScreen> {
  final _searchController = TextEditingController();
  _MissionFilter _filter = _MissionFilter.active;
  String _query = '';
  Timer? _debounce;

  String get _apiFilter => switch (_filter) {
        _MissionFilter.all => 'all',
        _MissionFilter.active => 'active',
        _MissionFilter.completed => 'completed',
      };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CourierRepository.instance.refreshMissions(filter: _apiFilter);
      CourierRepository.instance.refreshEarnings();
      CourierRepository.instance.refreshProfile();
    });
  }

  void _onSearchChanged() {
    final next = _searchController.text.trim().toLowerCase();
    if (next == _query) return;
    setState(() => _query = next);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      CourierRepository.instance.refreshMissions(
        filter: _apiFilter,
        q: _query.isEmpty ? null : _query,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _setFilter(_MissionFilter value) async {
    setState(() => _filter = value);
    await CourierRepository.instance.refreshMissions(
      filter: switch (value) {
        _MissionFilter.all => 'all',
        _MissionFilter.active => 'active',
        _MissionFilter.completed => 'completed',
      },
      q: _query.isEmpty ? null : _query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: ListenableBuilder(
          listenable: CourierRepository.instance,
          builder: (context, _) {
            final repo = CourierRepository.instance;
            final orders = repo.missions;
            final earnings = repo.earnings;
            final balance = earnings?.availableGnf ?? 0;
            final today = earnings?.todayGnf ?? 0;
            final emptyLabel = !repo.isAvailable &&
                    _filter != _MissionFilter.completed
                ? t.enableAvailabilityForMissions
                : (_filter == _MissionFilter.completed
                    ? t.noCompletedMissions
                    : t.noActiveMissions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -28,
                          bottom: 42,
                          child: Opacity(
                            opacity: 0.95,
                            child: CourierBikeIllustration(
                              size: 148,
                              showBackdrop: false,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.courierWelcomeBack,
                                          style: AppTypography.style(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.name.trim().isEmpty
                                              ? t.courierRole
                                              : user.name.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.display(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t.courierWelcomeSubtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.style(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white
                                                .withValues(alpha: 0.45),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Tooltip(
                                    message: repo.isAvailable
                                        ? t.active
                                        : t.unavailableShort,
                                    child: Transform.scale(
                                      scale: 0.88,
                                      child: Switch.adaptive(
                                        value: repo.isAvailable,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: AppColors.primary,
                                        onChanged: (value) async {
                                          try {
                                            await repo.setAvailability(value);
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  authErrorMessage(e),
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  _HeaderIconButton(
                                    icon: AppIcons.notifications,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const NotificationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const WalletScreen(),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.52,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          AppIcon(
                                            Symbols
                                                .account_balance_wallet_rounded,
                                            size: 16,
                                            color: AppColors.primary,
                                            filled: true,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            t.availableBalance,
                                            style: AppTypography.style(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white
                                                  .withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${formatPrice(balance)} GNF',
                                        style: AppTypography.display(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppIcon(
                                              Symbols.trending_up_rounded,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                '${t.courierTodayEarnings}: ${formatPrice(today)} GNF',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.style(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    AppIcon(
                                      AppIcons.search,
                                      size: 20,
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: AppTypography.style(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        cursorColor: AppColors.primary,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          hintText: t.courierSearchMissionsHint,
                                          hintStyle: AppTypography.style(
                                            fontSize: 15,
                                            color: Colors.white
                                                .withValues(alpha: 0.38),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_query.isNotEmpty)
                                      GestureDetector(
                                        onTap: _searchController.clear,
                                        child: AppIcon(
                                          AppIcons.close,
                                          size: 18,
                                          color: Colors.white
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _FilterSegment(
                    filter: _filter,
                    allLabel: t.courierFilterAll,
                    activeLabel: t.courierFilterActive,
                    completedLabel: t.completed,
                    onChanged: _setFilter,
                  ),
                ),
                Expanded(
                  child: repo.isLoading && orders.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : orders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  emptyLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.55),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () =>
                                  CourierRepository.instance.refreshMissions(
                                filter: _apiFilter,
                                q: _query.isEmpty ? null : _query,
                              ),
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 24),
                                itemCount: orders.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final mission = orders[index];
                                  return _MissionCard(mission: mission);
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2A2A),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: AppIcon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.filter,
    required this.allLabel,
    required this.activeLabel,
    required this.completedLabel,
    required this.onChanged,
  });

  final _MissionFilter filter;
  final String allLabel;
  final String activeLabel;
  final String completedLabel;
  final ValueChanged<_MissionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _SegmentTab(
            label: allLabel,
            selected: filter == _MissionFilter.all,
            onTap: () => onChanged(_MissionFilter.all),
          ),
          _SegmentTab(
            label: activeLabel,
            selected: filter == _MissionFilter.active,
            onTap: () => onChanged(_MissionFilter.active),
          ),
          _SegmentTab(
            label: completedLabel,
            selected: filter == _MissionFilter.completed,
            onTap: () => onChanged(_MissionFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.1,
                color: selected
                    ? Colors.white
                    : AppColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final CourierMission mission;

  Color _statusFill() {
    if (mission.isCompleted) return AppColors.primary;
    if (mission.status == MissionStatus.open) {
      return const Color(0xFF7B2CBF);
    }
    if (mission.status == MissionStatus.inTransit ||
        mission.status == MissionStatus.collected) {
      return AppColors.primary;
    }
    return const Color(0xFFE67E22);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = CourierRepository.instance;
    final pickupZone = repo.zoneLabel(mission.pickupZoneId);
    final deliveryZone = repo.zoneLabel(mission.deliveryZoneId);
    final isNew = mission.isOpen;
    final statusLabel = mission.orderStatus.localizedLabel(t);
    final statusFill = _statusFill();
    final dateLabel = mission.createdAtLabel.localizedDateLabel(t);

    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CourierMissionDetailScreen(missionId: mission.actionId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: AppIcon(
                        Symbols.package_2_rounded,
                        size: 22,
                        color: AppColors.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${mission.orderId.isNotEmpty ? mission.orderId : mission.id}',
                          style: AppTypography.style(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            AppIcon(
                              Symbols.route_rounded,
                              size: 13,
                              color: AppColors.textPrimary
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$pickupZone → $deliveryZone',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.style(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatPrice(mission.deliveryFeeGnf)} GNF',
                      style: AppTypography.style(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (isNew)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  AppIcon(
                    AppIcons.chevronRight,
                    size: 24,
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.courierShippedBy}:',
                          style: AppTypography.style(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.style(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${t.courierExpectedOn}:',
                          style: AppTypography.style(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.style(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
