import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/services/mock_listing_draft_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/sell_empty_illustrations.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _listAnItem() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const CreateListingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: MockListingDraftService.instance,
      builder: (context, _) {
        final ready = MockListingDraftService.instance.readyToPost;
        final incomplete = MockListingDraftService.instance.incomplete;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              t.draftsTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            bottom: TabBar(
              controller: _tabs,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textPrimary.withValues(alpha: 0.4),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              tabs: [
                Tab(text: t.draftsReadyToPost),
                Tab(text: t.draftsIncomplete),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _DraftsTabBody(
                drafts: ready,
                emptySubtitle: t.draftsEmptyReadySubtitle,
                onListAnItem: _listAnItem,
              ),
              _DraftsTabBody(
                drafts: incomplete,
                emptySubtitle: t.draftsEmptyIncompleteSubtitle,
                onListAnItem: _listAnItem,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraftsTabBody extends StatelessWidget {
  const _DraftsTabBody({
    required this.drafts,
    required this.emptySubtitle,
    required this.onListAnItem,
  });

  final List<ListingDraft> drafts;
  final String emptySubtitle;
  final VoidCallback onListAnItem;

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return _DraftsEmptyState(
        subtitle: emptySubtitle,
        onListAnItem: onListAnItem,
      );
    }

    final t = AppLocalizations.of(context)!;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: drafts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final title = draft.title.trim().isEmpty ? '—' : draft.title.trim();
        return Material(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => CreateListingScreen(draft: draft),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: draft.photos.isEmpty
                        ? Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.textPrimary.withValues(alpha: 0.35),
                            ),
                          )
                        : SafeNetworkImage(
                            url: draft.photos.first,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            iconSize: 28,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          draft.isReadyToPost
                              ? t.draftsReadyToPost
                              : t.draftsIncomplete,
                          style: TextStyle(
                            fontSize: 13,
                            color: draft.isReadyToPost
                                ? AppColors.primary
                                : AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textPrimary.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DraftsEmptyState extends StatelessWidget {
  const _DraftsEmptyState({
    required this.subtitle,
    required this.onListAnItem,
  });

  final String subtitle;
  final VoidCallback onListAnItem;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SellEmptyIllustrations.drafts,
            const SizedBox(height: 20),
            Text(
              t.draftsEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onListAnItem,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  t.listAnItem,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
