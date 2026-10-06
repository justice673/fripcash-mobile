import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/services/conversations_repository.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/seller_type_localization.dart';
import 'package:frip_cash/widgets/chat/chat_emoji_picker.dart';
import 'package:frip_cash/widgets/chat/chat_system_card.dart';
import 'package:frip_cash/widgets/confirm_dialog.dart';
import 'package:frip_cash/widgets/dispute_dialog.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _error;
  bool _sending = false;
  late final AnimationController _shakeController;
  Timer? _pollTimer;

  static List<String> _supportFaq(AppLocalizations t) => [
        t.supportFaqOrderWhere,
        t.supportFaqPaymentIssue,
        t.supportFaqCommissionFees,
        t.supportFaqContactCourier,
      ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.addListener(() => setState(() {}));
    final repo = ConversationsRepository.instance;
    repo.markRead(widget.threadId);
    repo.loadMessages(widget.threadId).then((_) {
      if (mounted) _scrollToEnd();
    }).catchError((_) {});
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      ConversationsRepository.instance
          .loadMessages(widget.threadId, poll: true)
          .catchError((_) {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _selectFaq(String faq) {
    _controller.text = faq;
    _controller.selection = TextSelection.collapsed(offset: faq.length);
  }

  void _insertEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  Future<void> _send(ChatThread thread) async {
    final t = AppLocalizations.of(context)!;
    final text = _controller.text;
    final repo = ConversationsRepository.instance;
    final error = repo.validateMessage(
      text,
      isSupport: thread.isSupport,
      emptyMessage: t.chatEmptyMessage,
      blockedMessage: t.chatBlockedMessage,
    );

    if (error != null) {
      setState(() => _error = error);
      await _shakeController.forward(from: 0);
      return;
    }

    setState(() => _sending = true);
    try {
      await repo.sendMessage(
        thread.id,
        text,
        emptyMessage: t.chatEmptyMessage,
        blockedMessage: t.chatBlockedMessage,
      );
      _controller.clear();
      setState(() {
        _error = null;
        _sending = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    } on ApiException catch (e) {
      setState(() {
        _sending = false;
        _error = e.message;
      });
      await _shakeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _sending = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickMedia(ChatThread thread) async {
    final t = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined,
                      color: AppColors.primary),
                  title: Text(t.chatCamera),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                  title: Text(t.chatGallery),
                  onTap: () => Navigator.pop(ctx, 'gallery'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _sending = true);
    try {
      await ConversationsRepository.instance
          .sendImageFromXFile(thread.id, file);
      if (!mounted) return;
      setState(() => _sending = false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _confirmReceiptFromCard(
    ChatMessage message,
    String orderId,
  ) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: t.confirmReceiptDialogTitle,
      description: t.confirmReceiptDialogBody,
      confirmLabel: t.confirmReceiptYes,
      cancelLabel: t.confirmReceiptNotYet,
    );
    if (!confirmed || !mounted) return false;

    final result = await MockOrderService.instance.confirmReceipt(orderId);
    if (result.ok) {
      ConversationsRepository.instance.markCardConfirmed(widget.threadId, message.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.confirmReceiptSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.sage,
        ),
      );
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          switch (result.messageKey) {
            ConfirmReceiptMessage.disputeLocked =>
              t.confirmReceiptDisputeLocked,
            ConfirmReceiptMessage.alreadyConfirmed =>
              t.confirmReceiptAlreadyDone,
            ConfirmReceiptMessage.notReady => t.confirmReceiptNotReady,
            _ => t.confirmReceiptNotFound,
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }

  Future<bool> _openDisputeFromCard(String orderId) async {
    final t = AppLocalizations.of(context)!;
    final reason = await showOpenDisputeDialog(
      context: context,
      orderId: orderId,
    );
    if (reason == null || !mounted) return false;

    final ok = await MockOrderService.instance.openDispute(
      orderId,
      reason: reason,
      openedVia: 'chat',
    );
    if (!mounted) return false;

    if (ok) {
      // Defer chat mutation so we don't notify listeners mid-dialog teardown.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ConversationsRepository.instance
            .loadMessages(widget.threadId)
            .then((_) {
          if (mounted) _scrollToEnd();
        }).catchError((_) {});
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? t.disputeOpenedToast : t.disputeOpenFailed),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFFB91C1C) : AppColors.textPrimary,
      ),
    );
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ConversationsRepository.instance,
        MockOrderService.instance,
      ]),
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        final thread =
            ConversationsRepository.instance.threadById(widget.threadId);
        if (thread == null) {
          return Scaffold(
            body: Center(child: Text(t.conversationNotFound)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Row(
              children: [
                if (thread.isSupport)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: appImageProvider(thread.imageUrl),
                    onBackgroundImageError: (error, stackTrace) {},
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!thread.isSupport)
                        Text(
                          thread.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (!thread.isSupport && thread.productId != null)
                _ProductHeader(thread: thread),
              if (thread.messagingDisabled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade100,
                  child: Text(
                    t.messagingUnavailableForBrand,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              if (thread.isSupport)
                _SupportFaqChips(
                  faqs: _ChatScreenState._supportFaq(t),
                  onSelect: _selectFaq,
                ),
              Expanded(
                child: thread.messages.isEmpty
                    ? Center(
                        child: Text(
                          thread.isSupport
                              ? t.askSupportQuestion
                              : t.sendMessageToSeller,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: thread.messages.length,
                        itemBuilder: (context, index) {
                          final message = thread.messages[index];
                          if (message.kind == ChatMessageKind.card &&
                              message.card != null) {
                            return ChatSystemCard(
                              card: message.card!,
                              onConfirmReceipt: (orderId) =>
                                  _confirmReceiptFromCard(message, orderId),
                              onOpenDispute: _openDisputeFromCard,
                            );
                          }
                          if (message.kind == ChatMessageKind.image) {
                            return _ImageBubble(message: message);
                          }
                          return _MessageBubble(message: message);
                        },
                      ),
              ),
              if (!thread.messagingDisabled)
                _InputBar(
                  controller: _controller,
                  error: _error,
                  shakeAnimation: _shakeController,
                  onSend: () => _send(thread),
                  onChanged: () {
                    if (_error != null) setState(() => _error = null);
                  },
                  onEmoji: () => showChatEmojiPicker(
                    context: context,
                    onPick: _insertEmoji,
                  ),
                  onAttach: () => _pickMedia(thread),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeNetworkImage(
              url: thread.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              iconSize: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (thread.sellerType != null)
                  Text(
                    thread.sellerType!.localizedLabel(t),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportFaqChips extends StatelessWidget {
  const _SupportFaqChips({required this.faqs, required this.onSelect});

  final List<String> faqs;
  final void Function(String text) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final faq in faqs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(faq, style: const TextStyle(fontSize: 12)),
                onPressed: () => onSelect(faq),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isMine = message.isMine;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                color: isMine ? Colors.white : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.sentAtLabel.localizedDateLabel(t),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.75)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isMine = message.isMine;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: SafeNetworkImage(
                url: message.imageUrl ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Text(
                message.sentAtLabel.localizedDateLabel(t),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.error,
    required this.shakeAnimation,
    required this.onSend,
    required this.onChanged,
    required this.onEmoji,
    required this.onAttach,
  });

  final TextEditingController controller;
  final String? error;
  final AnimationController shakeAnimation;
  final VoidCallback onSend;
  final VoidCallback onChanged;
  final VoidCallback onEmoji;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final shake = shakeAnimation.value;
        final offset = shake == 0
            ? 0.0
            : (shake < 0.5 ? shake * 16 : (1 - shake) * 16) *
                (shake < 0.25 || (shake > 0.5 && shake < 0.75) ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          12,
          8 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: Text(
                  error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: onAttach,
                  icon: const Icon(Icons.photo_camera_outlined),
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  tooltip: t.chatCamera,
                ),
                IconButton(
                  onPressed: onEmoji,
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  tooltip: t.chatEmoji,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => onChanged(),
                    decoration: InputDecoration(
                      hintText: t.writeMessageHint,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: controller.text.trim().isEmpty ? null : onSend,
                  icon: const Icon(Icons.send, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
