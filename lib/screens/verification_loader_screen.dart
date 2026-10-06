import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

class VerificationLoaderScreen extends StatefulWidget {
  const VerificationLoaderScreen({
    super.key,
    required this.nextScreen,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget nextScreen;
  final Duration duration;

  static Future<void> push(
    BuildContext context, {
    required Widget nextScreen,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return VerificationLoaderScreen(
            nextScreen: nextScreen,
            duration: duration,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  State<VerificationLoaderScreen> createState() =>
      _VerificationLoaderScreenState();
}

class _VerificationLoaderScreenState extends State<VerificationLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();
    _navigationTimer = Timer(widget.duration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return widget.nextScreen;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 360),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 148,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      t.deviceVerification,
                      textAlign: TextAlign.center,
                      style: AppTypography.style(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.contentAvailableAfterVerification,
                      textAlign: TextAlign.center,
                      style: AppTypography.style(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.textPrimary.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
