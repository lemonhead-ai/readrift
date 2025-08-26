import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:readrift/models/book.dart';
import 'package:readrift/services/book_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:readrift/screens/book_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController(viewportFraction: 0.6); // Reduced to show partial views

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authUser = authSnapshot.data;
        if (authUser == null) {
          return const Scaffold(
            body: Center(child: Text("No user logged in")),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _authService.getUserDataStream(authUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            final userData = snapshot.data!.data()!;
            final username = userData['username'] ?? "User";
            final photoUrl = authUser.photoURL;

            final today = DateTime.now();
            final formattedDate = DateFormat('MMMM, d\n yyyy').format(today);
            final dayOfWeek = DateFormat('EEE').format(today);

            return SafeArea(
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
                          Text(
                            dayOfWeek,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.orange,
                              fontSize: 60,
                              fontFamily: 'SFProRounded',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontFamily: 'SFProRounded',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "Hello, ",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: photoUrl != null
                                ? ClipOval(
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 35,
                                height: 35,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            " $username",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 34),
                      FutureBuilder<List<Book>>(
                        future: BookService().getRecommendations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final books = snapshot.data ?? [];
                          if (books.isEmpty) return const SizedBox();
                          return SizedBox(
                            height: 300, // Increased height to accommodate larger scale
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookReaderScreen(book: books[index]),
                                        ),
                                      );
                                    },
                                    child: _buildDynamicBookCard(books, books[index], index),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<Book?>(
                        future: _authService.getCurrentReading(authUser.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final currentBook = snapshot.data;
                          final libraryCount = 4; // Replace with actual count from stream
                          final freeTime = 45;
                          return Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: "You're currently reading "),
                                TextSpan(text: currentBook?.title ?? "None", style: const TextStyle(color: Colors.orange)),
                                const TextSpan(text: ". You have 📚 "),
                                TextSpan(text: "$libraryCount books ", style: const TextStyle(color: Colors.orange)),
                                const TextSpan(text: "in progress. You're free to read for 🕒 "),
                                TextSpan(text: "$freeTime mins", style: const TextStyle(color: Colors.orange)),
                                const TextSpan(text: " after 8 PM."),
                              ],
                            ),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "⌛ 5 Hours",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "📈 15% into Hooked", // Make dynamic
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Continue reading",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<Book?>(
                        future: _authService.getCurrentReading(authUser.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final currentBook = snapshot.data;
                          if (currentBook == null) return const Text("No current book");
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookReaderScreen(book: currentBook),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 200,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 50,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(180, 16, 16, 16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(34),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Reading now",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${(currentBook.progress * 100).toInt()}%",
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "- 5 hours left", // Make dynamic
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            borderRadius: BorderRadius.circular(20),
                                            value: currentBook.progress,
                                            backgroundColor: Colors.grey[300],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    bottom: 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        width: 160,
                                        height: 225,
                                        decoration: BoxDecoration(
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
                                        child: currentBook.coverUrl != null
                                            ? CachedNetworkImage(
                                          imageUrl: currentBook.coverUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.book),
                                        )
                                            : const Icon(Icons.book, size: 160),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDynamicBookCard(List<Book> books, Book book, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.hasPixels) {
          value = index - (_pageController.page ?? 0.0).clamp(0.0, books.length - 1);
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 2.0); // Scale factor
        }
        return Center(
          child: Transform.scale(
            scale: value == 0 ? 4.5 : value, // Increased center scale to 3x
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 300,
                height: 300, // Adjusted height for scaling
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white12,
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: book.coverUrl != null
                    ? CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.book),
                )
                    : const Icon(Icons.book, size: 120),
              ),
            ),
          ),
        );
      },
    );
  }
}