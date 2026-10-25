import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/empty_state_view.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = Provider.of<StudentProvider>(context);
    final notifications = student.notifications.isNotEmpty
        ? student.notifications
        : [
            NotificationModel(
              id: 'NOTIF001',
              message: 'Your marks for Assignment 2 have been published (Score: 92%).',
              time: '1 hour ago',
              isRead: false,
              icon: '📝',
            ),
            NotificationModel(
              id: 'NOTIF002',
              message: 'Reminder: Database Systems Quiz closes tomorrow at 11:59 PM.',
              time: '5 hours ago',
              isRead: false,
              icon: '⏰',
            ),
            NotificationModel(
              id: 'NOTIF003',
              message: 'New lecture summary notes added for Communication Systems.',
              time: 'Yesterday',
              isRead: true,
              icon: '📚',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await student.markAllNotifsRead();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read.')),
                );
              }
            },
            child: Text(
              'Mark all read',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brand500),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateView(
              title: 'No notifications',
              message: 'You are all caught up on academic updates.',
              icon: Icons.notifications_none_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, idx) {
                final n = notifications[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: n.isRead ? null : (isDark ? AppColors.brand500.withValues(alpha: 0.12) : AppColors.brand50),
                  child: ListTile(
                    leading: Text(n.icon ?? '📌', style: const TextStyle(fontSize: 20)),
                    title: Text(
                      n.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                        color: isDark ? AppColors.darkInk900 : AppColors.lightInk900,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        n.time,
                        style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkInk500 : AppColors.lightInk500),
                      ),
                    ),
                    trailing: n.isRead
                        ? null
                        : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.brand500, shape: BoxShape.circle)),
                    onTap: () => student.markNotifRead(n.id),
                  ),
                );
              },
            ),
    );
  }
}
