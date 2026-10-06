import 'package:flutter/foundation.dart';

/// Client-side Orange Money stand-in until PSP keys are configured.
///
/// - Debug builds: on by default
/// - Release: off unless `--dart-define=SIMULATE_PAYMENTS=true`
/// - Force off in debug: `--dart-define=SIMULATE_PAYMENTS=false`
class PaymentSimulation {
  PaymentSimulation._();

  static bool get enabled {
    const defined = bool.fromEnvironment('SIMULATE_PAYMENTS');
    if (const bool.hasEnvironment('SIMULATE_PAYMENTS')) {
      return defined;
    }
    return kDebugMode;
  }
}
