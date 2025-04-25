import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/screens/dock.dart';
import 'package:ReadRift/theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 2; // Library screen is index 2 in the Dock

  // Sample book data
  final List<Map<String, dynamic>> books = const [
    {
      "title": "1984",
      "author": "George Orwell",
      "imagePath": "assets/1984.png",
      "isCompleted": false,
    },
    {
      "title": "Atomic Habits",
      "author": "James Clear",
      "imagePath": "assets/atomic_habits.png",
      "isCompleted": true,
    },
    {
      "title": "Harry Potter and the Philosopher's Stone",
      "author": "J.K. Rowling",
      "imagePath": "assets/harry_potter.png",
      "isCompleted": false,
    },
    {
      "title": "Hooked",
      "author": "Nir Eyal",
      "imagePath": "assets/hooked.png",
      "isCompleted": true,
    },
    {
      "title": "Rich Dad Poor Dad",
      "author": "Robert Kiyosaki",
      "imagePath": "assets/rich_dad.png",
      "isCompleted": false,
    },
    {
      "title": "The Subtle Art of Not Giving a F*ck",
      "author": "Mark Manson",
      "imagePath": "assets/subtle_art.png",
      "isCompleted": false,
    },
    {
      "title": "The Alchemist",
      "author": "Paulo Coelho",
      "imagePath": "assets/the_alchemist.png",
      "isCompleted": true,
    },
  ];

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate crossAxisCount based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    const bookCardWidth = 120.0; // Approximate width of each book card
    final crossAxisCount = (screenWidth / bookCardWidth).clamp(1, 4).floor();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
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
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                          onPressed: () {
                            context.go('/');
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.bookmark_border,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                              onPressed: () {
                                // TODO: Implement bookmarks navigation
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.account_circle_outlined,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightText
                                    : AppColors.darkText,
                              ),
                              onPressed: () {
                                context.go('/profile');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Library",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightSecondaryText
                                  : AppColors.darkSecondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${books.length} books",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightSecondaryText
                                    : AppColors.darkSecondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.6, // Adjust to fit book cover proportions
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _buildBookCard(
                          context,
                          book["title"],
                          book["author"],
                          book["imagePath"],
                          book["isCompleted"],
                        );
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
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

  Widget _buildBookCard(
      BuildContext context, String title, String author, String imagePath, bool isCompleted) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Done",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}