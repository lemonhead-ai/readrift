import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/screens/dock.dart';


class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  AccountSettingsScreenState createState() => AccountSettingsScreenState();
}

class AccountSettingsScreenState extends State<AccountSettingsScreen> {
  int _selectedIndex = 3;
  final AuthService _authService = AuthService();

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _togglePreference(String uid, String key, bool value) {
    _authService.updatePreference(uid, key, value);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _authService.getUserDataStream(user.uid),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() ?? {};
        final prefs = userData['preferences'] as Map<String, dynamic>? ?? {};
        
        final notificationsEnabled = prefs['notifications'] ?? true;
        final readingRemindersEnabled = prefs['reminders'] ?? true;

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
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
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                context.go('/profile');
                              },
                            ),
                            Text(
                              'Account Settings',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 48), // For balance
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile',
                              style:
                                  Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileSection(context, user),
                            const SizedBox(height: 32),
                            Text(
                              'Preferences',
                              style:
                                  Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                            const SizedBox(height: 16),
                            _buildPreferencesSection(
                              context, 
                              user.uid, 
                              notificationsEnabled, 
                              readingRemindersEnabled
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Account',
                              style:
                                  Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                            const SizedBox(height: 16),
                            _buildAccountSection(context, user.uid),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Dock(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onNavIconTapped,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProfileSection(BuildContext context, User user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? const Icon(Icons.person) : null,
            ),
            title: Text(
              user.displayName ?? 'User',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              user.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, String uid, bool notifications, bool reminders) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: notifications,
            onChanged: (val) => _togglePreference(uid, 'notifications', val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Reading Reminders'),
            subtitle: const Text('Get daily reading reminders'),
            value: reminders,
            onChanged: (val) => _togglePreference(uid, 'reminders', val),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, String uid) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/reset-password');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // In a real app, this would delete the user's data and account
                        final navigator = Navigator.of(dialogContext);
                        await _authService.signOut();
                        if (!dialogContext.mounted) return;
                        navigator.pop();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
