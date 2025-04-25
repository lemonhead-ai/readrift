import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/screens/dock.dart';
import 'package:ReadRift/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isSearchFocused = false;
  int _selectedIndex = 1; // Search screen is index 1 in the Dock
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> localBooks = [
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

  // Simulated online book database
  final List<Map<String, dynamic>> onlineBooks = [
    {
      "title": "Pride and Prejudice",
      "author": "Jane Austen",
      "isFree": true,
      "downloadUrl": "https://example.com/pride_and_prejudice.pdf",
    },
    {
      "title": "To Kill a Mockingbird",
      "author": "Harper Lee",
      "isFree": false,
      "downloadUrl": null,
    },
    {
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "isFree": true,
      "downloadUrl": "https://example.com/the_great_gatsby.pdf",
    },
    {
      "title": "Dune",
      "author": "Frank Herbert",
      "isFree": false,
      "downloadUrl": null,
    },
  ];

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

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    searchResults = [];

    // Search local books
    final localMatches = localBooks.where((book) {
      return book["title"].toString().toLowerCase().contains(lowerQuery) ||
          book["author"].toString().toLowerCase().contains(lowerQuery);
    }).map((book) => {
      "title": book["title"],
      "author": book["author"],
      "isLocal": true,
      "isFree": false,
      "downloadUrl": null,
    }).toList();

    // Search online books
    final onlineMatches = onlineBooks.where((book) {
      return book["title"].toString().toLowerCase().contains(lowerQuery) ||
          book["author"].toString().toLowerCase().contains(lowerQuery);
    }).map((book) => {
      "title": book["title"],
      "author": book["author"],
      "isLocal": false,
      "isFree": book["isFree"],
      "downloadUrl": book["downloadUrl"],
    }).toList();

    // Combine results, prioritizing local matches
    searchResults = [...localMatches, ...onlineMatches];
  }

  void _downloadBook(Map<String, dynamic> book) {
    // Simulate downloading by adding the book to the local library
    setState(() {
      localBooks.add({
        "title": book["title"],
        "author": book["author"],
        "imagePath": "assets/default_book.png", // Placeholder for downloaded books
        "isCompleted": false,
      });
      searchResults[searchResults.indexOf(book)] = {
        ...book,
        "isLocal": true,
      };
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${book["title"]} downloaded successfully!")),
    );
  }

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
                    const SizedBox(height: 8),
                    Text(
                      "Search",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isSearching && searchResults.isEmpty)
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "No results found for '${_searchController.text}'",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightSecondaryText
                                : AppColors.darkSecondaryText,
                          ),
                        ),
                      ),
                    if (_isSearching && searchResults.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...searchResults.map((result) => _buildSearchResultItem(context, result)).toList(),
                        ],
                      ),
                    if (!_isSearchFocused && !_isSearching) ...[
                      Text(
                        "Recent Searches",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
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
                      const SizedBox(height: 24),
                      Text(
                        "Recommendations",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildRecommendationItem(context, "1984", "George Orwell"),
                            _buildRecommendationItem(context, "Atomic Habits", "James Clear"),
                            _buildRecommendationItem(context, "Harry Potter", "J.K. Rowling"),
                            _buildRecommendationItem(context, "Hooked", "Nir Eyal"),
                          ],
                        ),
                      ),
                    ],
                    if (!_isSearching && !_isSearchFocused)
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          "Search for books...",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightDockBackground.withValues(alpha: 0.3)
                      : AppColors.darkDockBackground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryText
                          : AppColors.darkSecondaryText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: "Search for books...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightSecondaryText
                                : AppColors.darkSecondaryText,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
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
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightSecondaryText
                              : AppColors.darkSecondaryText,
                        ),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (!_isSearchFocused)
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

  Widget _buildSearchChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightDockBackground.withValues(alpha: 0.1)
            : AppColors.darkDockBackground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightSecondaryText.withValues(alpha: 0.1)
              : AppColors.darkSecondaryText.withValues(alpha: 0.1),
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

  Widget _buildRecommendationItem(BuildContext context, String title, String author) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightDockBackground.withValues(alpha: 0.1)
            : AppColors.darkDockBackground.withValues(alpha: 0.1),
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

  Widget _buildSearchResultItem(BuildContext context, Map<String, dynamic> result) {
    final isLocal = result["isLocal"] as bool;
    final isFree = result["isFree"] as bool;
    final downloadUrl = result["downloadUrl"] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result["title"],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightText
                        : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "by ${result["author"]}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightSecondaryText
                        : AppColors.darkSecondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLocal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Available Locally",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isLocal && isFree && downloadUrl != null)
            ElevatedButton(
              onPressed: () => _downloadBook(result),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Download",
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