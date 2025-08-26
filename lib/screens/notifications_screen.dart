import 'package:readrift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();

  // Mock notifications data - in a real app, this would come from Firestore
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Book Available',
      'message':
          'The new book "Atomic Habits" is now available in your library.',
      'time': '2 hours ago',
      'isRead': false,
      'type': 'book_available',
    },
    {
      'id': '2',
      'title': 'Reading Goal Achieved',
      'message': 'Congratulations! You\'ve reached your daily reading goal.',
      'time': '5 hours ago',
      'isRead': false,
      'type': 'achievement',
    },
    {
      'id': '3',
      'title': 'Bookmark Added',
      'message': 'You\'ve added a bookmark in "1984" at page 45.',
      'time': '1 day ago',
      'isRead': true,
      'type': 'bookmark',
    },
    {
      'id': '4',
      'title': 'Subscription Update',
      'message': 'Your premium subscription will renew in 7 days.',
      'time': '2 days ago',
      'isRead': true,
      'type': 'subscription',
    },
  ];

  // Dock is handled globally via ShellRoute; no local navigation index needed here.

  void _markAsRead(String notificationId) {
    setState(() {
      final notification =
          _notifications.firstWhere((n) => n['id'] == notificationId);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
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
                          Icons.arrow_back,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
                        onPressed: _markAllAsRead,
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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        color: notification['isRead']
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
                            notification['title'],
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
                                notification['message'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['time'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                          trailing: !notification['isRead']
                              ? IconButton(
                                  icon: const Icon(Icons.check_circle_outline),
                                  onPressed: () =>
                                      _markAsRead(notification['id']),
                                )
                              : null,
                        ),
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
        return Icons.book;
      case 'achievement':
        return Icons.emoji_events;
      case 'bookmark':
        return Icons.bookmark;
      case 'subscription':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
