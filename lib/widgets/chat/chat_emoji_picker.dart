import 'package:flutter/material.dart';
import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/theme/app_colors.dart';

Future<void> showChatEmojiPicker({
  required BuildContext context,
  required void Function(String emoji) onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Emoji',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (final emoji in chatEmojiPicker)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onPick(emoji);
                      },
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
