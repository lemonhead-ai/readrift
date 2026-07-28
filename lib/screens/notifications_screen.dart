import 'package:readrift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:readrift/theme.dart';
import 'package:readrift/widgets/custom_toast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();

  void _markAsRead(String uid, String notificationId) {
    _authService.markNotificationAsRead(uid, notificationId);
    ToastService.showSuccess(context, 'Notification marked as read');
  }

  void _markAllAsRead(String uid) {
    _authService.markAllNotificationsAsRead(uid);
    ToastService.showSuccess(context, 'All notifications have been marked as read');
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          context.go('/profile');
                        },
                      ),
                      Text(
                        'Notifications',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () => _markAllAsRead(user.uid),
                        child: Text(
                          'Mark all as read',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.accentOrange,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _authService.getNotificationsStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      final notifications = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final doc = notifications[index];
                          final notification = doc.data();
                          final isRead = notification['isRead'] ?? false;
                          final timestamp = notification['timestamp'] as Timestamp?;
                          final timeStr = timestamp != null
                              ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                              : 'Just now';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            color: isRead
                                ? Theme.of(context).cardColor
                                : Theme.of(context)
                                    .cardColor
                                    .withValues(alpha: 0.8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getNotificationColor(notification['type']),
                                child: Icon(
                                  _getNotificationIcon(notification['type']),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                notification['title'] ?? 'Notification',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['message'] ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                              trailing: !isRead
                                  ? IconButton(
                                      icon: const Icon(Icons.check_circle_outline),
                                      onPressed: () =>
                                          _markAsRead(user.uid, doc.id),
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Dock is provided globally by ScaffoldWithDock in ShellRoute
        ],
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'book_available':
        return Colors.blue;
      case 'achievement':
        return Colors.green;
      case 'bookmark':
        return Colors.orange;
      case 'subscription':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'book_available':
        return Icons.auto_stories_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'bookmark':
        return Icons.bookmark_rounded;
      case 'subscription':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
