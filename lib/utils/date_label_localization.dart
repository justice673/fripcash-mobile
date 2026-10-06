import 'package:frip_cash/l10n/app_localizations.dart';

extension DateLabelLocalization on String {
  String localizedDateLabel(AppLocalizations t) {
    final value = trim();
    final lower = value.toLowerCase();

    if (lower == "aujourd'hui" || lower == 'aujourdhui' || lower == 'today') {
      return t.timeToday;
    }
    if (lower == 'hier' || lower == 'yesterday') {
      return t.timeYesterday;
    }
    if (lower == "à l'instant" || lower == "a l'instant" || lower == 'just now') {
      return t.notifJustNow;
    }

    final frHours = RegExp(r"il y a (\d+)\s*h").firstMatch(lower);
    if (frHours != null) {
      return t.notifHoursAgo(int.parse(frHours.group(1)!));
    }
    final enHours = RegExp(r"(\d+)\s*h ago").firstMatch(lower);
    if (enHours != null) {
      return t.notifHoursAgo(int.parse(enHours.group(1)!));
    }

    final frDays = RegExp(r'il y a (\d+)\s*jours?').firstMatch(lower);
    if (frDays != null) {
      return t.timeDaysAgo(int.parse(frDays.group(1)!));
    }
    final enDays = RegExp(r'(\d+)\s*days? ago').firstMatch(lower);
    if (enDays != null) {
      return t.timeDaysAgo(int.parse(enDays.group(1)!));
    }

    final frWeeks = RegExp(r'il y a (\d+)\s*semaines?').firstMatch(lower);
    if (frWeeks != null) {
      return t.timeWeeksAgo(int.parse(frWeeks.group(1)!));
    }
    final enWeeks = RegExp(r'(\d+)\s*weeks? ago').firstMatch(lower);
    if (enWeeks != null) {
      return t.timeWeeksAgo(int.parse(enWeeks.group(1)!));
    }

    return value;
  }
}

bool isTodayDateLabel(String value) {
  final lower = value.trim().toLowerCase();
  return lower == "aujourd'hui" || lower == 'aujourdhui' || lower == 'today';
}
