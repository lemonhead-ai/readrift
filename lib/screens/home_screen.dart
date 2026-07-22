import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:readrift/widgets/book_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';
import 'package:readrift/widgets/bouncy_tap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  String _getRemainingReadingTime() {
    return "5 hrs";
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

            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            Row(
                              children: [
                                Text(
                                  formattedDate,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'SFProRounded',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
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
                            BouncyTap(
                              onTap: () => context.go('/profile'),
                              child: Container(
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
                            ),
                            Text(
                              " $username",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.orange,
                                  ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _authService.getUserLibraryStream(authUser.uid),
                          builder: (context, librarySnapshot) {
                            if (librarySnapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(color: AppColors.accentOrange),
                                ),
                              );
                            }

                            final libraryBooks = librarySnapshot.data?.docs
                                    .map((doc) => doc.data())
                                    .toList() ??
                                [];

                            final carouselBooks = libraryBooks.map((book) {
                              return BookItem(
                                bookId: book['bookId'].toString(),
                                title: book['title'] ?? 'Unknown',
                                author: book['author'] ?? 'Unknown',
                                imagePath: book['imagePath'] ?? 'assets/default_book.png',
                                filePath: book['filePath'] as String?,
                                fileType: book['fileType'] ?? 'epub',
                                downloaded: book['downloaded'] ?? false,
                              );
                            }).toList();

                            // Find in-progress books
                            final inProgressBooks = libraryBooks
                                .where((book) =>
                                    (book['progressPercent'] ?? 0.0) > 0.0 &&
                                    (book['progressPercent'] ?? 0.0) < 0.99)
                                .toList();

                            // Choose active book
                            Map<String, dynamic>? activeBook;
                            if (inProgressBooks.isNotEmpty) {
                              inProgressBooks.sort((a, b) =>
                                  (b['progressPercent'] ?? 0.0)
                                      .compareTo(a['progressPercent'] ?? 0.0));
                              activeBook = inProgressBooks.first;
                            } else if (libraryBooks.isNotEmpty) {
                              final downloaded = libraryBooks
                                  .where((b) => b['downloaded'] == true)
                                  .toList();
                              if (downloaded.isNotEmpty) {
                                  activeBook = downloaded.first;
                              }
                            }

                            final activeBookTitle = activeBook != null
                                ? activeBook['title']
                                : 'a book';
                            final activeBookAuthor = activeBook != null
                                ? activeBook['author']
                                : '';
                            final activeBookImage = activeBook != null
                                ? activeBook['imagePath']
                                : 'assets/welcome_illustration.png';
                            final progressPercent = activeBook != null
                                ? ((activeBook['progressPercent'] ?? 0.0) *
                                        100)
                                    .round()
                                : 0;
                            final progressValue = activeBook != null
                                ? (activeBook['progressPercent'] ?? 0.0)
                                    .toDouble()
                                : 0.0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BookCarousel(
                                  title: 'Shelf',
                                  books: carouselBooks,
                                  onViewAll: () {
                                    context.go('/library');
                                  },
                                  onBookTapped: (bookItem) {
                                    if (bookItem.downloaded &&
                                        bookItem.filePath != null) {
                                      context.push('/reader', extra: {
                                        'bookId': bookItem.bookId,
                                        'filePath': bookItem.filePath!,
                                        'bookTitle': bookItem.title,
                                        'fileType': bookItem.fileType,
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please re-download this book from the Search tab to read.")),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: activeBook != null
                                            ? "You're currently reading "
                                            : "Start your journey by reading ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: activeBookTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                      ),
                                      TextSpan(
                                        text: ". You have 📚 ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            "${inProgressBooks.length} books ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                      ),
                                      TextSpan(
                                        text:
                                            "in progress. You're free to read for 🕒 ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: _getRemainingReadingTime(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      "⌛ ${libraryBooks.length} books in Library",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(width: 16),
                                    if (activeBook != null)
                                      Text(
                                        "📈 $progressPercent% into $activeBookTitle",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  activeBook != null
                                      ? "Continue reading"
                                      : "Featured book",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (activeBook != null &&
                                        activeBook['downloaded'] == true) {
                                      context.push('/reader', extra: {
                                        'bookId': activeBook['bookId']
                                            .toString(),
                                        'filePath':
                                            activeBook['filePath'] as String,
                                        'bookTitle':
                                            activeBook['title'] as String,
                                        'fileType':
                                            activeBook['fileType'] ?? 'epub',
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "No downloaded book to read. Go to Search to find books.")),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 225,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 50,
                                          bottom: 0,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.fromLTRB(
                                                    180, 16, 16, 16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[300]
                                                  : Colors.grey[800],
                                              borderRadius:
                                                  BorderRadius.circular(34),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  activeBook != null
                                                      ? "Reading now"
                                                      : "Tap to select",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "$progressPercent%",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  activeBook != null
                                                      ? activeBookAuthor
                                                      : "Search tab",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(height: 8),
                                                LinearProgressIndicator(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                  value: progressValue,
                                                  backgroundColor:
                                                      Colors.grey[400],
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
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
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: Container(
                                              width: 160,
                                              height: 225,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Colors.black12
                                                        : Colors.white12,
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: activeBookImage
                                                      .startsWith('assets/')
                                                  ? Image.asset(
                                                      activeBookImage,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      activeBookImage,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        color:
                                                            Colors.grey[300],
                                                        child: const Icon(
                                                            Icons
                                                                .book_rounded,
                                                            size: 50,
                                                            color:
                                                                Colors.grey),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}