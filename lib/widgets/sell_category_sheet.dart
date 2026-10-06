import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/sell_category_tree.dart';
import 'package:frip_cash/theme/app_colors.dart';

/// Drill-down category picker in FripCash light styling.
Future<SellCategorySelection?> showSellCategorySheet(BuildContext context) {
  return showModalBottomSheet<SellCategorySelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SellCategorySheet(),
  );
}

class _SellCategorySheet extends StatefulWidget {
  const _SellCategorySheet();

  @override
  State<_SellCategorySheet> createState() => _SellCategorySheetState();
}

class _SellCategorySheetState extends State<_SellCategorySheet> {
  final List<SellCategoryNode> _stack = [];

  List<SellCategoryNode> get _currentChildren =>
      _stack.isEmpty ? sellCategoryTree : _stack.last.children;

  String _title(AppLocalizations t) =>
      _stack.isEmpty ? t.category : _stack.last.label;

  void _open(SellCategoryNode node) {
    if (node.isLeaf) {
      if (!node.mapsToListing) return;
      Navigator.of(context).pop(
        SellCategorySelection(
          path: [..._stack, node],
          listingCategoryId: node.listingCategoryId!,
          listingSubcategoryId: node.listingSubcategoryId,
        ),
      );
      return;
    }
    setState(() => _stack.add(node));
  }

  void _back() {
    if (_stack.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _stack.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _back,
                      icon: Icon(
                        _stack.isEmpty ? Icons.close : Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: _stack.isEmpty ? 24 : 18,
                      ),
                    ),
                  ),
                  Text(
                    _title(t),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: ListView.separated(
              itemCount: _currentChildren.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final node = _currentChildren[index];
                return InkWell(
                  onTap: () => _open(node),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            node.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (!node.isLeaf)
                          Icon(
                            Icons.chevron_right,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.45),
                            size: 22,
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
