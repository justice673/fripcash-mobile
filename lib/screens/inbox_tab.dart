import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/chat_screen.dart';
import 'package:frip_cash/services/conversations_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class InboxTab extends StatefulWidget {
  const InboxTab({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ConversationsRepository.instance.refreshInbox().catchError((_) {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              t.messagesNav,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textPrimary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                icon: Icon(Icons.support_agent_outlined, size: 20),
                text: t.supportFripCash,
              ),
              Tab(
                icon: Icon(Icons.chat_bubble_outline, size: 20),
                text: t.sellers,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ConversationList(
                  tab: 'support',
                  emptyTitle: t.noSupportMessages,
                  emptySubtitle: t.noSupportMessagesSubtitle,
                  onExplore: widget.onExplore,
                  onOpenEmptySupport: () async {
                    try {
                      final thread =
                          await ConversationsRepository.instance.openSupport();
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(threadId: thread.id),
                        ),
                      );
                      ConversationsRepository.instance
                          .refreshInbox()
                          .catchError((_) {});
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                _ConversationList(
                  tab: 'sellers',
                  emptyTitle: t.noMessages,
                  emptySubtitle: t.noMessagesSubtitle,
                  onExplore: widget.onExplore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.tab,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onExplore,
    this.onOpenEmptySupport,
  });

  final String tab;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback? onExplore;
  final Future<void> Function()? onOpenEmptySupport;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = ConversationsRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final threads =
            tab == 'support' ? repo.supportThreads : repo.sellerThreads;

        if (repo.loadingInbox && threads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (threads.isEmpty) {
          return EmptyStateView(
            illustration: Image.asset(
              'assets/images/inbox/empty_inbox.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.mail_outline,
                  size: 96,
                  color: Colors.grey.shade300,
                );
              },
            ),
            title: emptyTitle,
            subtitle: emptySubtitle,
            actionLabel: tab == 'support' && onOpenEmptySupport != null
                ? t.askSupportQuestion
                : t.discoverItemsAction,
            onAction: tab == 'support' && onOpenEmptySupport != null
                ? () => onOpenEmptySupport!()
                : onExplore,
          );
        }

        return RefreshIndicator(
          onRefresh: () => repo.refreshInbox(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: threads.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, indent: 72, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              return _ConversationTile(thread: threads[index]);
            },
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatScreen(threadId: thread.id),
          ),
        );
        ConversationsRepository.instance.refreshInbox().catchError((_) {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: thread.isSupport || thread.imageUrl.isEmpty
                      ? null
                      : appImageProvider(thread.imageUrl),
                  onBackgroundImageError:
                      thread.isSupport || thread.imageUrl.isEmpty
                          ? null
                          : (error, stackTrace) {},
                  child: thread.isSupport
                      ? const Icon(
                          Icons.support_agent,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                if (thread.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${thread.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    thread.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}
