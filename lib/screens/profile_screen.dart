import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/screens/dock.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false, // Allow content to extend to the bottom
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onPressed: () {
                            context.go('/');
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // Logout logic to be implemented later
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? Colors.black12
                                      : Colors.white12,
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Martin",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "You're rock! ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: "You've finished last book in 3 days 🔥",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildOptionTile(
                      context,
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      hasBadge: true,
                      badgeCount: 2,
                      onTap: () {},
                    ),
                    _buildOptionTile(
                      context,
                      icon: Icons.bookmark_border,
                      title: "Bookmarks",
                      onTap: () {},
                    ),
                    _buildOptionTile(
                      context,
                      icon: Icons.star_border,
                      title: "Subscription plan",
                      onTap: () {},
                    ),
                    _buildOptionTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: "Account settings",
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(context, "18 books\nyou have", Icons.book_outlined),
                        _buildStatItem(context, "158 h\nof reading", Icons.timer_outlined),
                        _buildStatItem(context, "5 books\ndone", Icons.check_circle_outline),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your bookshelf",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildBookshelfItem(context, "assets/1984.png"),
                          _buildBookshelfItem(context, "assets/atomic_habits.png"),
                          _buildBookshelfItem(context, "assets/harry_potter.png"),
                          _buildBookshelfItem(context, "assets/hooked.png"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), // Extra space to ensure content scrolls behind dock
                  ],
                ),
              ),
            ),
          ),
          // Position the Dock at the bottom
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

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        Color? titleColor,
        bool hasBadge = false,
        int badgeCount = 0,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: titleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: hasBadge
          ? Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildStatItem(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookshelfItem(BuildContext context, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}