// lib/screens/search_screen.dart
import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readrift/models/book.dart';
import 'package:readrift/services/book_service.dart';
import 'package:readrift/screens/book_reader_screen.dart';  // Import if adding

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isSearchFocused = false;
  List<Book> searchResults = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
      if (value.isEmpty) {
        searchResults = [];
      } else {
        _performSearch(value);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      searchResults = [];
      _searchFocusNode.unfocus();
    });
  }

  void _performSearch(String query) async {
    final authUser = _authService.currentUser;
    if (authUser == null) return;

    searchResults = [];

    final library = await _authService.getUserLibraryStream(authUser.uid).first;
    final localMatches = library.where((book) =>
    book.title.toLowerCase().contains(query.toLowerCase()) ||
        book.author.toLowerCase().contains(query.toLowerCase())
    ).toList();

    final onlineMatches = await BookService().searchBooks(query);

    setState(() {
      searchResults = [...localMatches, ...onlineMatches];
    });
  }

  void _downloadBook(Book book) async {
    final authUser = _authService.currentUser;
    if (authUser == null) return;

    await _authService.addBookToLibrary(authUser.uid, book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${book.title} added to library!")),
    );
    _performSearch(_searchController.text);  // Refresh results
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

            final photoUrl = authUser.photoURL;

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
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).brightness ==
                                  Brightness.light
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                            onPressed: () {
                              context.go('/');
                            },
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                    Brightness.light
                                    ? AppColors.lightDockBackground
                                    .withAlpha((0.3 * 255).toInt())
                                    : AppColors.darkDockBackground
                                    .withAlpha((0.3 * 255).toInt()),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withAlpha(0x19),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(0x19),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? AppColors.lightSecondaryText
                                        : AppColors.darkSecondaryText,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      decoration: InputDecoration(
                                        hintText: "Search for books...",
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .brightness ==
                                              Brightness.light
                                              ? AppColors
                                              .lightSecondaryText
                                              : AppColors
                                              .darkSecondaryText,
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: Theme.of(context)
                                            .brightness ==
                                            Brightness.light
                                            ? AppColors.lightText
                                            : AppColors.darkText,
                                      ),
                                      onChanged: _onSearchChanged,
                                    ),
                                  ),
                                  if (_isSearching)
                                    IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Theme.of(context)
                                            .brightness ==
                                            Brightness.light
                                            ? AppColors.lightSecondaryText
                                            : AppColors.darkSecondaryText,
                                      ),
                                      onPressed: _clearSearch,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.go('/profile');
                            },
                            icon: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: photoUrl != null
                                  ? ClipOval(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder:
                                      (context, error, stackTrace) {
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_isSearching && searchResults.isEmpty)
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            "No results found for '${_searchController.text}'",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              color: Theme.of(context).brightness ==
                                  Brightness.light
                                  ? AppColors.lightSecondaryText
                                  : AppColors.darkSecondaryText,
                            ),
                          ),
                        ),
                      if (_isSearching && searchResults.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...searchResults.map((book) =>
                                _buildSearchResultItem(context, book)),
                          ],
                        ),
                      if (!_isSearchFocused && !_isSearching) ...[
                        Text(
                          "Recent Searches",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).brightness ==
                                Brightness.light
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildSearchChip(context, "George Orwell"),
                              _buildSearchChip(context, "James Clear"),
                              _buildSearchChip(context, "J.K. Rowling"),
                              _buildSearchChip(context, "Nir Eyal"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Recommendations",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).brightness ==
                                Brightness.light
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<Book>>(
                          future: BookService().getRecommendations(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final recs = snapshot.data ?? [];
                            return SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recs.length,
                                itemBuilder: (context, index) {
                                  final book = recs[index];
                                  return _buildRecommendationItem(context, book.title, book.author);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      if (!_isSearching && !_isSearchFocused)
                        Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            "Search for books...",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              color: Theme.of(context).brightness ==
                                  Brightness.light
                                  ? AppColors.lightSecondaryText
                                  : AppColors.darkSecondaryText,
                            ),
                          ),
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

  Widget _buildSearchChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightDockBackground.withAlpha((0.1 * 255).toInt())
            : AppColors.darkDockBackground.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightSecondaryText.withAlpha(0x4D)
              : AppColors.darkSecondaryText.withAlpha(0x4D),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightText
              : AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
      BuildContext context, String title, String author) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightDockBackground.withAlpha((0.1 * 255).toInt())
            : AppColors.darkDockBackground.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightText
                  : AppColors.darkText,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            "by $author",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightSecondaryText
                  : AppColors.darkSecondaryText,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(
      BuildContext context, Book book) {
    final isLocal = searchResults.indexOf(book) < searchResults.length / 2;  // Approximate, or check against library
    final isFree = book.isFree;
    final downloadUrl = book.downloadUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isLocal || isFree) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookReaderScreen(book: book),
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightText
                          : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "by ${book.author}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryText
                          : AppColors.darkSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isLocal)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Available",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isLocal && isFree && downloadUrl != null)
            ElevatedButton(
              onPressed: () => _downloadBook(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "GET",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          if (!isLocal && !isFree)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Paid",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}