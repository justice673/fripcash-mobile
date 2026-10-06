import 'package:flutter/material.dart';
import 'package:frip_cash/screens/change_password_screen.dart';
import 'package:frip_cash/screens/courier_home_screen.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/screens/welcome_screen.dart';
import 'package:frip_cash/services/catalog_repository.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    await MockSession.instance.restore();

    await Future.wait([
      CatalogRepository.instance.ensureLoaded().then((_) {}, onError: (_) {}),
      ListingsRepository.instance
          .prefetchDiscovery()
          .then((_) {}, onError: (_) {}),
    ]);

    final elapsed = DateTime.now().difference(started);
    const minSplash = Duration(milliseconds: 1200);
    if (elapsed < minSplash) {
      await Future<void>.delayed(minSplash - elapsed);
    }
    if (!mounted) return;

    final Widget next;
    if (!MockSession.instance.isSignedIn) {
      next = const WelcomeScreen();
    } else if (MockSession.instance.isCourierSession) {
      next = MockSession.instance.mustChangePassword
          ? const ChangePasswordScreen(
              forced: true,
              replaceWithCourierHome: true,
            )
          : const CourierHomeScreen();
    } else {
      next = const MainShell();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
