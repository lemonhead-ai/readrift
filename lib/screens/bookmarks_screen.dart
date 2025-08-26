import 'package:readrift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  BookmarksScreenState createState() => BookmarksScreenState();
}

class BookmarksScreenState extends State<BookmarksScreen> {
  final AuthService _authService = AuthService();

  // Mock bookmarks data - in a real app, this would come from Firestore
  final List<Map<String, dynamic>> _bookmarks = [
    {
      'id': '1',
      'bookTitle': '1984',
      'author': 'George Orwell',
      'page': 45,
      'note': 'Important quote about surveillance',
      'date': '2 hours ago',
      'imagePath': 'assets/1984.png',
    },
    {
      'id': '2',
      'bookTitle': 'Atomic Habits',
      'author': 'James Clear',
      'page': 78,
      'note': 'Key concept about habit formation',
      'date': '1 day ago',
      'imagePath': 'assets/atomic_habits.png',
    },
    {
      'id': '3',
      'bookTitle': 'Hooked',
      'author': 'Nir Eyal',
      'page': 120,
      'note': 'Interesting point about user engagement',
      'date': '3 days ago',
      'imagePath': 'assets/hooked.png',
    },
  ];

  // Dock is handled globally via ShellRoute; no local navigation index needed here.

  void _removeBookmark(String bookmarkId) {
    setState(() {
      _bookmarks.removeWhere((bookmark) => bookmark['id'] == bookmarkId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark removed')),
    );
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
                        'Bookmarks',
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
                Expanded(
                  child: _bookmarks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No bookmarks yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add bookmarks while reading to save important pages',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _bookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = _bookmarks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    bookmark['imagePath'],
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  bookmark['bookTitle'],
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
                                      'Page ${bookmark['page']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.accentOrange,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bookmark['note'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bookmark['date'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _removeBookmark(bookmark['id']),
                                ),
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
}
