/// Client-side anti-evasion filter (mock — spec A.6).
class ChatMessageGuard {
  ChatMessageGuard._();

  static final _patterns = <RegExp>[
    RegExp(r'\+?\d[\d\s\-.]{7,}\d'),
    RegExp(r'\S+@\S+\.\S+', caseSensitive: false),
    RegExp(r'whatsapp|wa\.me', caseSensitive: false),
    RegExp(r'telegram|t\.me', caseSensitive: false),
    RegExp(r'facebook|fb\.com|instagram|instagr\.am', caseSensitive: false),
    RegExp(r'https?://\S+', caseSensitive: false),
  ];

  static String? validate(String text, {required String emptyMessage, required String blockedMessage}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return emptyMessage;
    for (final pattern in _patterns) {
      if (pattern.hasMatch(trimmed)) return blockedMessage;
    }
    return null;
  }

  static String maskForPreview(String text) {
    var masked = text;
    for (final pattern in _patterns) {
      masked = masked.replaceAllMapped(pattern, (m) => '•' * m.group(0)!.length);
    }
    return masked;
  }
}
