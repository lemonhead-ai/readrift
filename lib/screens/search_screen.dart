// lib/screens/search_screen.dart
import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:readrift/widgets/skeleton_loader.dart';



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
  List<dynamic> searchResults = [];
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<String> _downloadedBookIds = [];
  Map<String, String> _downloadedBookPaths = {};

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _syncDownloadedBooks();
  }

  Future<void> _syncDownloadedBooks() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .get();

    final List<String> downloadedIds = [];
    final Map<String, String> paths = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['downloaded'] == true && data['filePath'] != null) {
        final filePath = data['filePath'] as String;
        if (await File(filePath).exists()) {
          downloadedIds.add(data['bookId'].toString());
          paths[data['bookId'].toString()] = filePath;
        } else {
          // File missing from storage, update state
          await _authService.updateDownloadStatus(user.uid, data['bookId'].toString(), false);
        }
      }
    }

    if (mounted) {
      setState(() {
        _downloadedBookIds = downloadedIds;
        _downloadedBookPaths = paths;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        searchResults = [];
      });
    } else {
      _performSearch(value);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      searchResults = [];
      _searchFocusNode.unfocus();
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final url = Uri.parse(
          'https://gutendex.com/books/?search=${Uri.encodeComponent(query)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];

        setState(() {
          searchResults = results.map((book) {
            final bookId = book['id'].toString();
            final formats = book['formats'] as Map<String, dynamic>? ?? {};

            String? epubUrl;
            String? pdfUrl;

            formats.forEach((key, value) {
              if (key.toString().contains('epub')) {
                epubUrl = value.toString();
              } else if (key.toString().contains('pdf')) {
                pdfUrl = value.toString();
              }
            });

            epubUrl ??= formats['application/epub+zip']?.toString();
            pdfUrl ??= formats['application/pdf']?.toString();

            final coverUrl = formats['image/jpeg']?.toString() ??
                'assets/default_book.png';

            final title = book['title'] ?? 'Unknown Title';
            final authorsList = book['authors'] as List? ?? [];
            final author = authorsList.isNotEmpty
                ? (authorsList[0]['name'] ?? 'Unknown Author')
                : 'Unknown Author';

            final isLocal = _downloadedBookIds.contains(bookId);

            return {
              "bookId": bookId,
              "title": title,
              "author": author,
              "imagePath": coverUrl,
              "isLocal": isLocal,
              "isFree": true,
              "downloadUrl": epubUrl ?? pdfUrl,
              "fileType": epubUrl != null ? 'epub' : 'pdf',
              "filePath": isLocal ? _downloadedBookPaths[bookId] : null,
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadBook(Map<String, dynamic> book) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final downloadUrl = book['downloadUrl'] as String?;
    if (downloadUrl == null) {
      ToastService.showWarning(context, "No download link available for this book.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dir = await getApplicationDocumentsDirectory();
        final fileType = book['fileType'] as String? ?? 'epub';
        final fileName = "${book['bookId']}.$fileType";
        final file = File("${dir.path}/$fileName");

        await file.writeAsBytes(bytes);

        final bookMetadata = {
          "bookId": book['bookId'],
          "title": book['title'],
          "author": book['author'],
          "imagePath": book['imagePath'],
          "downloaded": true,
          "filePath": file.path,
          "fileType": fileType,
          "progressPercent": 0.0,
          "currentPosition": "",
          "isCompleted": false,
        };

        await _authService.addBookToLibrary(user.uid, bookMetadata);

        await _syncDownloadedBooks(); // Sync locally

        if (!mounted) return;
        ToastService.showSuccess(context, "${book["title"]} downloaded successfully!");
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(context, "Failed to download book: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

            return Scaffold(
              body: SafeArea(
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
                              onPressed: () {
                                context.go('/');
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                                                ? AppColors.lightSecondaryText
                                                : AppColors.darkSecondaryText,
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
                                          errorBuilder: (context, error,
                                              stackTrace) {
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
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: List.generate(
                                5,
                                (index) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      SkeletonLoader(width: 80, height: 120),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SkeletonLoader(width: 200, height: 20),
                                            SizedBox(height: 8),
                                            SkeletonLoader(width: 120, height: 16),
                                            SizedBox(height: 16),
                                            SkeletonLoader(width: 80, height: 32),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!_isLoading && _isSearching && searchResults.isEmpty)
                          Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
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
                          ),
                        if (!_isLoading && _isSearching && searchResults.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...searchResults.map((result) =>
                                  _buildSearchResultItem(context, result)),
                            ],
                          ),
                        if (!_isSearchFocused && !_isSearching) ...[
                          Text(
                            "Categories",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.lightText
                                      : AppColors.darkText,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildCategoryChip(context, "Fiction", Icons.auto_stories_rounded),
                              _buildCategoryChip(context, "Science", Icons.science_rounded),
                              _buildCategoryChip(context, "History", Icons.history_edu_rounded),
                              _buildCategoryChip(context, "Mystery", Icons.search_rounded),
                              _buildCategoryChip(context, "Philosophy", Icons.psychology_rounded),
                              _buildCategoryChip(context, "Poetry", Icons.feather_rounded),
                            ],
                          ),
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 24),
                          Text(
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
                        ],
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

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon) {
    return BouncyTap(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentOrange.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentOrange.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.accentOrange),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildSearchResultItem(
      BuildContext context, Map<String, dynamic> result) {
    final isLocal = result['isLocal'] as bool? ?? false;
    final isFree = result['isFree'] as bool? ?? true;
    final downloadUrl = result['downloadUrl'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightText
                            : AppColors.darkText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "by ${result['author'] ?? 'Unknown'}",
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
                      "Available Offline",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLocal)
            ElevatedButton(
              onPressed: () {
                final localPath = result['filePath'] ??
                    _downloadedBookPaths[result['bookId'].toString()];
                if (localPath != null) {
                  context.push('/reader', extra: {
                    'bookId': result['bookId'].toString(),
                    'filePath': localPath,
                    'bookTitle': result['title'],
                    'fileType': result['fileType'] ?? 'epub',
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "READ",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
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
                "GET",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          if (!isFree)
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