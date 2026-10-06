import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/courier_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/help_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';

class CourierMissionDetailScreen extends StatefulWidget {
  const CourierMissionDetailScreen({super.key, required this.missionId});

  final String missionId;

  @override
  State<CourierMissionDetailScreen> createState() =>
      _CourierMissionDetailScreenState();
}

class _CourierMissionDetailScreenState
    extends State<CourierMissionDetailScreen> {
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CourierRepository.instance.loadMission(widget.missionId);
    });
  }

  void _call(BuildContext context, String label, String phone) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.callLabel} $label : $phone'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showTransferSheet(
    BuildContext context,
    CourierMission mission,
  ) async {
    final t = AppLocalizations.of(context)!;
    final repo = CourierRepository.instance;
    final peers = await repo.peers(zoneId: repo.zoneId);

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.transferToAnotherCourier,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.availableCouriers} — ${repo.zoneLabel(repo.zoneId)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                for (final peer in peers)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(peer.name),
                    subtitle: Text(peer.phone),
                    trailing: const Icon(Icons.swap_horiz),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        await repo.transfer(
                          id: mission.actionId,
                          toCourierId: peer.id,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${t.missionTransferredTo} ${peer.name}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authErrorMessage(e)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                if (peers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      t.noOtherCourierInZone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusFill(MissionStatus status) {
    if (status == MissionStatus.delivered) return AppColors.primary;
    if (status == MissionStatus.open) return const Color(0xFF7B2CBF);
    if (status == MissionStatus.inTransit ||
        status == MissionStatus.collected) {
      return AppColors.primary;
    }
    return const Color(0xFFE67E22);
  }

  double _progressFor(MissionStatus status) {
    if (status == MissionStatus.delivered) return 1;
    if (status == MissionStatus.inTransit) return 0.72;
    if (status == MissionStatus.collected) return 0.45;
    if (status == MissionStatus.assigned) return 0.28;
    return 0.18;
  }

  String _slideLabel(AppLocalizations t, MissionStatus status) {
    return switch (status) {
      MissionStatus.open => t.accept,
      MissionStatus.assigned => t.courierSlideToCollect,
      MissionStatus.collected || MissionStatus.inTransit =>
        t.courierSlideToDeliver,
      _ => t.accept,
    };
  }

  Future<void> _onSlideConfirmed(CourierMission mission) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    final t = AppLocalizations.of(context)!;
    final repo = CourierRepository.instance;
    try {
      switch (mission.status) {
        case MissionStatus.open:
          await repo.accept(mission.actionId);
        case MissionStatus.assigned:
          await repo.markCollected(mission.actionId);
        case MissionStatus.collected:
        case MissionStatus.inTransit:
          await repo.markDelivered(mission.actionId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.deliveryConfirmed),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case MissionStatus.delivered:
        case MissionStatus.cancelled:
          break;
      }
      await repo.refreshMissions(filter: 'active');
      await repo.refreshEarnings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CourierRepository.instance,
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        final repo = CourierRepository.instance;
        CourierMission? mission;
        final selected = repo.selected;
        if (selected != null &&
            (selected.id == widget.missionId ||
                selected.orderId == widget.missionId ||
                selected.actionId == widget.missionId)) {
          mission = selected;
        } else {
          for (final m in repo.missions) {
            if (m.id == widget.missionId ||
                m.orderId == widget.missionId ||
                m.actionId == widget.missionId) {
              mission = m;
              break;
            }
          }
        }

        if (mission == null) {
          return Scaffold(
            body: Center(
              child: repo.isLoading
                  ? const CircularProgressIndicator()
                  : Text(t.missionNotFound),
            ),
          );
        }

        final current = mission;
        final sellerPhone = current.sellerPhone ?? '';
        final buyerPhone = current.buyerPhone ?? '';
        final packageTitle = current.lineSummary?.title.isNotEmpty == true
            ? current.lineSummary!.title
            : current.orderId;
        final quantity = current.lineSummary?.qty ?? 1;
        final canAct = current.status == MissionStatus.open ||
            current.status == MissionStatus.assigned ||
            current.status == MissionStatus.collected ||
            current.status == MissionStatus.inTransit;
        final isDone = current.isCompleted;
        final statusLabel = current.orderStatus.localizedLabel(t);
        final statusFill = _statusFill(current.status);
        final progress = _progressFor(current.status);
        final topInset = MediaQuery.paddingOf(context).top;
        final dateLabel = current.createdAtLabel.localizedDateLabel(t);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF0F1F3),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, topInset + 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textPrimary,
                      ),
                      Expanded(
                        child: Text(
                          '${t.courierExpectedOn}: $dateLabel',
                          style: AppTypography.style(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded),
                        onSelected: (value) {
                          if (value == 'transfer' && !isDone) {
                            _showTransferSheet(context, current);
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isDone)
                            PopupMenuItem(
                              value: 'transfer',
                              child: Text(t.transferToAnotherCourier),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Builder(
                              builder: (context) {
                                final stats = <Widget>[
                                  if ((current.distanceLabel ?? '')
                                      .isNotEmpty)
                                    _TripStat(
                                      value: current.distanceLabel!,
                                      label: t.courierDistanceLabel,
                                    ),
                                  if ((current.etaLabel ?? '').isNotEmpty)
                                    _TripStat(
                                      value: current.etaLabel!,
                                      label: t.courierTimeLeftLabel,
                                    ),
                                  if ((current.arrivalLabel ?? '').isNotEmpty)
                                    _TripStat(
                                      value: current.arrivalLabel!,
                                      label: t.courierArrivalLabel,
                                    ),
                                ];
                                if (stats.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Row(children: stats),
                                );
                              },
                            ),
                            _RouteProgressBar(progress: progress),
                            const SizedBox(height: 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 22,
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '#${current.orderId}',
                                        style: AppTypography.style(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        packageTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.style(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
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
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                _MetaCell(
                                  label: '${t.courierShippedBy}:',
                                  value: current.sellerName,
                                ),
                                _MetaCell(
                                  label: t.courierOrderCost,
                                  value:
                                      '${formatPrice(current.totalGnf)} GNF',
                                ),
                                _MetaCell(
                                  label: t.courierCreated,
                                  value: dateLabel,
                                  alignEnd: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.courierCustomer,
                                        style: AppTypography.style(
                                          fontSize: 12,
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        current.buyerName ?? '—',
                                        style: AppTypography.style(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: AppColors.primary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: buyerPhone.isEmpty
                                        ? null
                                        : () => _call(
                                              context,
                                              t.clientLabel.toLowerCase(),
                                              buyerPhone,
                                            ),
                                    child: const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Icon(
                                        Icons.chat_bubble_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${t.courierDeliveryAddress}:',
                              style: AppTypography.style(
                                fontSize: 12,
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    current.buyerAddress ?? '—',
                                    style: AppTypography.style(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  _SpecRow(
                                    label: t.courierQuantity,
                                    value: '$quantity',
                                  ),
                                  if (current.lineSummary?.size != null)
                                    _SpecRow(
                                      label: t.size,
                                      value: current.lineSummary!.size!,
                                    ),
                                  _SpecRow(
                                    label: t.courierTypeOfOrder,
                                    value: t.courierTypeOwnTerms,
                                  ),
                                  _SpecRow(
                                    label: t.courierOrderCost,
                                    value:
                                        '${formatPrice(current.totalGnf)} GNF',
                                  ),
                                  _SpecRow(
                                    label: t.courierDeliveryFee,
                                    value:
                                        '${formatPrice(current.deliveryFeeGnf)} GNF',
                                  ),
                                  _SpecRow(
                                    label: t.courierPaymentMethod,
                                    value: 'Orange Money',
                                  ),
                                  _SpecRow(
                                    label: t.courierPaymentStatus,
                                    value: t.courierPaymentPaid,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const HelpScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.chat_outlined,
                                        size: 18,
                                      ),
                                      label: Text(t.courierChatWithSupport),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.textPrimary,
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Material(
                                  color: Colors.white,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: sellerPhone.isEmpty
                                        ? null
                                        : () => _call(
                                              context,
                                              t.sellerRoleGeneric.toLowerCase(),
                                              sellerPhone,
                                            ),
                                    child: const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(
                                        Icons.phone_outlined,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (canAct && !_actionBusy) ...[
                              const SizedBox(height: 16),
                              _ConfirmSlide(
                                key: ValueKey(current.status.apiValue),
                                label: _slideLabel(t, current.status),
                                onConfirmed: () =>
                                    _onSlideConfirmed(current),
                              ),
                            ],
                            if (_actionBusy) ...[
                              const SizedBox(height: 16),
                              const Center(child: CircularProgressIndicator()),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.style(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.style(
              fontSize: 12,
              color: AppColors.textPrimary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteProgressBar extends StatelessWidget {
  const _RouteProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.05, 1.0);

    return SizedBox(
      height: 36,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final markerX = (width - 28) * clamped;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 14,
                right: 14,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 14 + markerX,
                right: 14,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.textPrimary, width: 1.4),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Positioned(
                left: markerX,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.white,
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

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.style(
              fontSize: 11,
              color: AppColors.textPrimary.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: AppTypography.style(
                fontSize: 13,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.style(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmSlide extends StatefulWidget {
  const _ConfirmSlide({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  final String label;
  final VoidCallback onConfirmed;

  @override
  State<_ConfirmSlide> createState() => _ConfirmSlideState();
}

class _ConfirmSlideState extends State<_ConfirmSlide> {
  double _dx = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDx = constraints.maxWidth - 58;
        return Container(
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Positioned(
                left: 4 + _dx,
                child: GestureDetector(
                  onHorizontalDragUpdate: _done
                      ? null
                      : (details) {
                          setState(() {
                            _dx = (_dx + details.delta.dx).clamp(0, maxDx);
                          });
                        },
                  onHorizontalDragEnd: _done
                      ? null
                      : (_) {
                          if (_dx > maxDx * 0.72) {
                            setState(() {
                              _dx = maxDx;
                              _done = true;
                            });
                            widget.onConfirmed();
                          } else {
                            setState(() => _dx = 0);
                          }
                        },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
