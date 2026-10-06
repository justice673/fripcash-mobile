import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';

class ConditionOption {
  const ConditionOption({
    required this.id,
    required this.titleOf,
    required this.subtitleOf,
  });

  final String id;
  final String Function(AppLocalizations t) titleOf;
  final String Function(AppLocalizations t) subtitleOf;
}

final sellConditionOptions = <ConditionOption>[
  ConditionOption(
    id: 'newWithTag',
    titleOf: (t) => t.sellConditionBrandNew,
    subtitleOf: (t) => t.sellConditionBrandNewDesc,
  ),
  ConditionOption(
    id: 'newWithoutTag',
    titleOf: (t) => t.sellConditionLikeNew,
    subtitleOf: (t) => t.sellConditionLikeNewDesc,
  ),
  ConditionOption(
    id: 'veryGood',
    titleOf: (t) => t.sellConditionExcellent,
    subtitleOf: (t) => t.sellConditionExcellentDesc,
  ),
  ConditionOption(
    id: 'good',
    titleOf: (t) => t.sellConditionGoodUsed,
    subtitleOf: (t) => t.sellConditionGoodUsedDesc,
  ),
  ConditionOption(
    id: 'satisfactory',
    titleOf: (t) => t.sellConditionFair,
    subtitleOf: (t) => t.sellConditionFairDesc,
  ),
];

String sellConditionTitle(String id, AppLocalizations t) {
  for (final option in sellConditionOptions) {
    if (option.id == id) return option.titleOf(t);
  }
  return t.sellConditionExcellent;
}

Future<String?> showConditionSheet(
  BuildContext context, {
  String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConditionSheet(selectedId: selectedId),
  );
}

class _ConditionSheet extends StatefulWidget {
  const _ConditionSheet({this.selectedId});

  final String? selectedId;

  @override
  State<_ConditionSheet> createState() => _ConditionSheetState();
}

class _ConditionSheetState extends State<_ConditionSheet> {
  late String? _selected = widget.selectedId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.condition,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: ListView.separated(
              itemCount: sellConditionOptions.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final option = sellConditionOptions[index];
                final selected = _selected == option.id;
                return InkWell(
                  onTap: () {
                    setState(() => _selected = option.id);
                    Navigator.of(context).pop(option.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.titleOf(t),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option.subtitleOf(t),
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
