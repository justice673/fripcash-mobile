import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';

String authErrorMessage(Object error, {String fallback = 'Something went wrong'}) {
  if (error is DioException) {
    return authErrorMessage(ApiException.fromDio(error), fallback: fallback);
  }
  if (error is ApiException) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return 'Invalid phone or password';
      case 'TERMS_REQUIRED':
        return 'Please accept the terms';
      case 'WRONG_AUTH_SURFACE':
      case 'FORBIDDEN_AUDIENCE':
        return 'Wrong app for this account';
      case 'OTP_INVALID':
        return 'Invalid code';
      case 'OTP_EXPIRED':
        return 'Code expired — request a new one';
      case 'OTP_RATE_LIMITED':
        return 'Too many attempts — wait 60s';
      case 'OTP_MAX_ATTEMPTS':
        return 'Too many wrong codes — request a new one';
      case 'PRE_AUTH_EXPIRED':
        return 'Verification expired — sign in again';
      case 'COURIER_DISABLED':
        return 'Courier account disabled';
      case 'PHONE_NOT_VERIFIED':
        return 'Verify your phone before going online';
      case 'MUST_CHANGE_PASSWORD':
        return 'Change your password before going online';
      case 'PHONE_ALREADY_REGISTERED':
        return 'Phone already registered — sign in instead';
      case 'INTERNAL_SERVER_ERROR':
      case 'INTERNAL':
        final id = error.correlationId;
        if (id != null && id.isNotEmpty) {
          return 'Server error (ref: $id). Try signing in — account may already exist.';
        }
        return 'Server error. Try signing in — your account may already exist.';
      case 'BADRESPONSE':
        if (error.statusCode != null && error.statusCode! >= 500) {
          return 'Server error. Try signing in — your account may already exist.';
        }
        return error.message.isNotEmpty ? error.message : fallback;
      case 'VALIDATION_ERROR':
        final msg = error.message.toLowerCase();
        if (msg.contains('password') &&
            (msg.contains('too small') || msg.contains('>= 8'))) {
          return 'Password must be at least 8 characters';
        }
        // Prefer field-level details when Nest returns them.
        if (error.details != null && error.details!.isNotEmpty) {
          return error.message.isNotEmpty
              ? error.message
              : error.details!.join('\n');
        }
        return error.message.isNotEmpty
            ? error.message
            : 'Un ou plusieurs champs sont invalides.';
      case 'COURIER_UNAVAILABLE':
        return 'Go available to accept missions';
      case 'COURIER_NOT_VERIFIED':
        return 'Courier account not verified yet';
      case 'MISSION_NOT_IN_ZONE':
        return 'Mission is outside your zone';
      case 'MISSION_ALREADY_ASSIGNED':
        return 'Mission already taken';
      case 'NOT_MISSION_COURIER':
        return 'You are not assigned to this mission';
      case 'INVALID_MISSION_TRANSITION':
        return 'Invalid mission step';
      case 'NO_PEER_IN_ZONE':
        return 'No other courier in your zone';
      case 'TRANSFER_NOT_ALLOWED':
        return 'Transfer not allowed';
      case 'MISSION_CANCELLED':
        return 'Mission was cancelled';
      case 'STOCK_EXCEEDED':
        return error.message.isNotEmpty
            ? error.message
            : 'Not enough stock for this quantity';
      case 'LOGO_REQUIRED':
        return 'Shop logo is required';
      case 'CLOUDINARY_SIGN_INVALID':
      case 'CLOUDINARY_UPLOAD_FAILED':
        return error.message.isNotEmpty
            ? error.message
            : 'Logo upload failed — try another image';
      default:
        return error.message.isNotEmpty ? error.message : fallback;
    }
  }
  return error.toString();
}
