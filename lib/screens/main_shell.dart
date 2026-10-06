import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/browse_tab.dart';
import 'package:frip_cash/screens/courier_login_screen.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/screens/favorites_tab.dart';
import 'package:frip_cash/screens/home_tab.dart';
import 'package:frip_cash/screens/inbox_tab.dart';
import 'package:frip_cash/screens/profile_tab.dart';
import 'package:frip_cash/screens/sell_hub_screen.dart';
import 'package:frip_cash/screens/seller_dashboard_screen.dart';
import 'package:frip_cash/services/conversations_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/tutorial/app_product_tour.dart';
import 'package:frip_cash/tutorial/app_tutorial_keys.dart';
import 'package:frip_cash/utils/seller_access.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  static const _navBarHeight = 64.0;
  static const _addButtonSize = 44.0;

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FavoritesTab(
          onExplore: () {
            Navigator.of(context).pop();
            setState(() => _currentIndex = 0);
          },
        ),
      ),
    );
  }

  void _openSellFlow() {
    if (!hasSellerAccess) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const BecomeSellerScreen(),
        ),
      );
      return;
    }
    if (isSellerVerificationPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.sellerVerificationPendingBody,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreateListingScreen(),
      ),
    );
  }

  void _openSellHub() {
    setState(() => _currentIndex = 2);
  }

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(onFavoritesTap: _openFavorites),
      const BrowseTab(),
      const SellHubScreen(),
      InboxTab(onExplore: () => setState(() => _currentIndex = 0)),
      _ProfileOrBoutiqueTab(
        onFavoritesTap: _openFavorites,
        onExplore: () => setState(() => _currentIndex = 1),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ConversationsRepository.instance.refreshUnread().catchError((_) {});
      if (MockSession.instance.user.role == UserRole.livreur ||
          MockSession.instance.isCourierSession) {
        await MockSession.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const CourierLoginScreen(),
          ),
          (_) => false,
        );
        return;
      }
      AppProductTour.showIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final reservedBottom = _navBarHeight + bottomSafe;

    return ListenableBuilder(
      listenable: Listenable.merge([
        ConversationsRepository.instance,
        MockSession.instance,
      ]),
      builder: (context, _) {
        final unread = ConversationsRepository.instance.totalUnread;
        final seller = hasSellerAccess;

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              // Keep tab content above the floating nav so last cards aren't clipped.
              // CustomScrollView does not apply MediaQuery bottom padding on its own.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: reservedBottom,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _tabs,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _StickyBottomNavBar(
                  currentIndex: _currentIndex,
                  unreadCount: unread,
                  bottomSafe: bottomSafe,
                  navBarHeight: _navBarHeight,
                  addButtonSize: _addButtonSize,
                  labels: [
                    t.homeNav,
                    t.browseNav,
                    t.sellNav,
                    t.messagesNav,
                    seller ? t.shopTabBoutique : t.profileNav,
                  ],
                  boutiqueMode: seller,
                  onTap: (index) {
                    if (index == 2) {
                      _openSellFlow();
                      return;
                    }
                    setState(() => _currentIndex = index);
                  },
                  onSellLongPress: _openSellHub,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileOrBoutiqueTab extends StatelessWidget {
  const _ProfileOrBoutiqueTab({
    required this.onFavoritesTap,
    required this.onExplore,
  });

  final VoidCallback onFavoritesTap;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockSession.instance,
      builder: (context, _) {
        if (hasSellerAccess) {
          return const SellerDashboardScreen();
        }
        return ProfileTab(
          onFavoritesTap: onFavoritesTap,
          onExplore: onExplore,
        );
      },
    );
  }
}

class _StickyBottomNavBar extends StatelessWidget {
  const _StickyBottomNavBar({
    required this.currentIndex,
    required this.unreadCount,
    required this.bottomSafe,
    required this.navBarHeight,
    required this.addButtonSize,
    required this.labels,
    required this.onTap,
    this.onSellLongPress,
    this.boutiqueMode = false,
  });

  final int currentIndex;
  final int unreadCount;
  final double bottomSafe;
  final double navBarHeight;
  final double addButtonSize;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final VoidCallback? onSellLongPress;
  final bool boutiqueMode;

  static const _topRadius = 22.0;

  static final _keys = [
    AppTutorialKeys.navHome,
    AppTutorialKeys.navBrowse,
    AppTutorialKeys.navSell,
    AppTutorialKeys.navMessages,
    AppTutorialKeys.navProfile,
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
                  final slotWidth = constraints.maxWidth / 5;
                  const indicatorWidth = 18.0;
                  const indicatorHeight = 3.0;
                  final showIndicator = currentIndex != 2;
                  // Sell (+) opens a modal form; keep indicator off that slot.
                  final left = currentIndex * slotWidth +
                      (slotWidth - indicatorWidth) / 2;

                  return Stack(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          if (index == 2) {
                            return Expanded(
                              child: Center(
                                child: _AddNavButton(
                                  targetKey: _keys[2],
                                  size: addButtonSize,
                                  selected: currentIndex == 2,
                                  onTap: () => onTap(2),
                                  onLongPress: onSellLongPress,
                                ),
                              ),
                            );
                          }
                          return Expanded(
                            child: _GlassNavItem(
                              targetKey: _keys[index],
                              icon: index == 4 && boutiqueMode
                                  ? _NavIcon.shop
                                  : _NavIcon.values[index],
                              label: labels[index],
                              selected: currentIndex == index,
                              badgeCount: index == 3 && unreadCount > 0
                                  ? unreadCount
                                  : null,
                              onTap: () => onTap(index),
                            ),
                          );
                        }),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: left,
                        bottom: 10,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: showIndicator ? 1 : 0,
                          child: Container(
                            width: indicatorWidth,
                            height: indicatorHeight,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
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

class _AddNavButton extends StatelessWidget {
  const _AddNavButton({
    required this.size,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.targetKey,
  });

  final double size;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final GlobalKey? targetKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        key: targetKey,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.primaryDark : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AppIcon(
          AppIcons.add,
          color: Colors.white,
          size: 26,
          filled: true,
        ),
      ),
    );
  }
}

enum _NavIcon { home, browse, sell, inbox, you, shop }

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.targetKey,
  });

  final _NavIcon icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final GlobalKey? targetKey;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.primary.withValues(alpha: 0.06),
        child: SizedBox(
          key: targetKey,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  _BottomNavIcon(
                    icon: icon,
                    color: color,
                    selected: selected,
                  ),
                  if (badgeCount != null)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          badgeCount! > 9 ? '9+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 14,
                child: selected
                    ? null
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.icon,
    required this.color,
    required this.selected,
  });

  final _NavIcon icon;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return switch (icon) {
      _NavIcon.home => AppIcon(
          AppIcons.home,
          size: 24,
          color: color,
          filled: selected,
        ),
      _NavIcon.browse => AppIcon(
          AppIcons.browse,
          size: 24,
          color: color,
          filled: selected,
        ),
      _NavIcon.sell => AppIcon(
          AppIcons.add,
          size: 26,
          color: color,
          filled: selected,
        ),
      _NavIcon.inbox => AppIcon(
          AppIcons.inbox,
          size: 22,
          color: color,
          filled: selected,
        ),
      _NavIcon.you => AppIcon(
          AppIcons.profile,
          size: 24,
          color: color,
          filled: selected,
        ),
      _NavIcon.shop => AppIcon(
          AppIcons.cart,
          size: 24,
          color: color,
          filled: selected,
        ),
    };
  }
}
