import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/courier_earnings_screen.dart';
import 'package:frip_cash/screens/courier_history_screen.dart';
import 'package:frip_cash/screens/courier_missions_screen.dart';
import 'package:frip_cash/screens/courier_profile_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:material_symbols_icons/symbols.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  int _currentIndex = 0;

  static const _navBarHeight = 64.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CourierRepository.instance.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final reservedBottom = _navBarHeight + bottomSafe;

    return ListenableBuilder(
      listenable: CourierRepository.instance,
      builder: (context, _) {
        final isAvailable = CourierRepository.instance.isAvailable;
        final showBanner = !isAvailable && _currentIndex != 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          extendBody: true,
          body: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: reservedBottom,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: Column(
                    children: [
                      if (showBanner)
                        Container(
                          width: double.infinity,
                          color: Colors.orange.shade50,
                          padding: EdgeInsets.fromLTRB(
                            16,
                            MediaQuery.paddingOf(context).top + 12,
                            16,
                            12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t.courierUnavailableBanner,
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: [
                            const CourierMissionsScreen(),
                            CourierEarningsScreen(
                              onOpenHistory: () {
                                setState(() => _currentIndex = 2);
                              },
                            ),
                            const CourierHistoryScreen(),
                            const CourierProfileScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CourierStickyNavBar(
                  currentIndex: _currentIndex,
                  bottomSafe: bottomSafe,
                  navBarHeight: _navBarHeight,
                  labels: [
                    t.missions,
                    t.earnings,
                    t.history,
                    t.profileNav,
                  ],
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    if (index == 1) {
                      CourierRepository.instance.refreshEarnings();
                      MockWalletService.instance
                          .syncForUser(MockSession.instance.user);
                    } else if (index == 2) {
                      CourierRepository.instance
                          .refreshMissions(filter: 'completed');
                    } else if (index == 0) {
                      CourierRepository.instance
                          .refreshMissions(filter: 'active');
                    } else if (index == 3) {
                      CourierRepository.instance.refreshProfile();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourierStickyNavBar extends StatelessWidget {
  const _CourierStickyNavBar({
    required this.currentIndex,
    required this.bottomSafe,
    required this.navBarHeight,
    required this.labels,
    required this.onTap,
  });

  final int currentIndex;
  final double bottomSafe;
  final double navBarHeight;
  final List<String> labels;
  final ValueChanged<int> onTap;

  static const _topRadius = 22.0;

  static final _icons = <IconData>[
    Symbols.local_shipping_rounded,
    Symbols.account_balance_wallet_rounded,
    Symbols.history_rounded,
    Symbols.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final barHeight = navBarHeight + bottomSafe;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_topRadius),
          topRight: Radius.circular(_topRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_topRadius),
          topRight: Radius.circular(_topRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_topRadius),
                topRight: Radius.circular(_topRadius),
              ),
              color: Colors.white.withValues(alpha: 0.94),
              border: Border(
                top: BorderSide(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSafe),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final slotWidth = constraints.maxWidth / 4;
                  const indicatorWidth = 18.0;
                  const indicatorHeight = 3.0;
                  final left = currentIndex * slotWidth +
                      (slotWidth - indicatorWidth) / 2;

                  return Stack(
                    children: [
                      Row(
                        children: List.generate(4, (index) {
                          final selected = currentIndex == index;
                          final color = selected
                              ? AppColors.primary
                              : AppColors.textPrimary;

                          return Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onTap(index),
                                splashColor:
                                    AppColors.primary.withValues(alpha: 0.12),
                                highlightColor:
                                    AppColors.primary.withValues(alpha: 0.06),
                                child: SizedBox(
                                  height: navBarHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppIcon(
                                        _icons[index],
                                        size: 24,
                                        color: color,
                                        filled: selected,
                                      ),
                                      SizedBox(
                                        height: 14,
                                        child: selected
                                            ? null
                                            : Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  labels[index],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: color,
                                                    letterSpacing: -0.1,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: left,
                        bottom: 10,
                        child: Container(
                          width: indicatorWidth,
                          height: indicatorHeight,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
