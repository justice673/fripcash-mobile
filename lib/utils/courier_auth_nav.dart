import 'package:flutter/material.dart';
import 'package:frip_cash/api/auth_api.dart';
import 'package:frip_cash/screens/change_password_screen.dart';
import 'package:frip_cash/screens/courier_home_screen.dart';
import 'package:frip_cash/screens/courier_otp_screen.dart';
import 'package:frip_cash/screens/verification_loader_screen.dart';
import 'package:frip_cash/services/mock_session.dart';

/// Handle [CourierLoginResult] after [MockSession.loginCourier].
Future<void> navigateCourierLoginResult(
  BuildContext context,
  CourierLoginResult result,
) async {
  if (!context.mounted) return;
  if (result is CourierPhoneVerificationRequired) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourierOtpScreen(
          preAuthToken: result.preAuthToken,
          phoneMasked: result.phoneMasked,
          otpLength: result.otpLength,
          otpAlreadySent: result.otpSent,
        ),
      ),
    );
    return;
  }
  if (MockSession.instance.mustChangePassword) {
    VerificationLoaderScreen.push(
      context,
      nextScreen: const ChangePasswordScreen(
        forced: true,
        replaceWithCourierHome: true,
      ),
    );
    return;
  }
  VerificationLoaderScreen.push(
    context,
    nextScreen: const CourierHomeScreen(),
  );
}
