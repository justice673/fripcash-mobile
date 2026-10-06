import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_notifications.dart';
import 'package:frip_cash/screens/order_detail_screen.dart';
import 'package:frip_cash/services/mock_notification_service.dart';
import 'package:frip_cash/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.notificationsTitle,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: MockNotificationService.instance.markAllRead,
            child: Text(t.markAllRead),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: MockNotificationService.instance,
        builder: (context, _) {
          final items = MockNotificationService.instance.items;

          if (items.isEmpty) {
            return Center(
              child: Text(
                t.noNotifications,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = items[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final MockNotification notification;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          MockNotificationService.instance.markRead(notification.id);
          final orderId = notification.orderId;
          if (orderId != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OrderDetailScreen(orderId: orderId),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            isUnread ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.timeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
