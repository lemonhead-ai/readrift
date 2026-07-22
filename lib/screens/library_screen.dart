import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readrift/widgets/bouncy_tap.dart';
import 'package:readrift/widgets/custom_toast.dart';




class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  final AuthService _authService = AuthService();

  Future<void> _importLocalBook() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileName = result.files.single.name;

        final extension = fileName.split('.').last.toLowerCase();
        final bookId = "local_${DateTime.now().millisecondsSinceEpoch}";
        final title = fileName.replaceAll('.$extension', '');

        final dir = await getApplicationDocumentsDirectory();
        final localFile = File("${dir.path}/$bookId.$extension");
        await file.copy(localFile.path);

        final bookMetadata = {
          "bookId": bookId,
          "title": title,
          "author": "Local Import",
          "imagePath": "assets/default_book.png",
          "downloaded": true,
          "filePath": localFile.path,
          "fileType": extension,
          "progressPercent": 0.0,
          "currentPosition": "",
          "isCompleted": false,
        };

        await _authService.addBookToLibrary(user.uid, bookMetadata);

        if (!mounted) return;
        ToastService.showSuccess(context, "Imported '$title' successfully!");
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(context, "Failed to import book: $e");
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
            final screenWidth = MediaQuery.of(context).size.width;
            const bookCardWidth = 120.0;
            final crossAxisCount =
                (screenWidth / bookCardWidth).clamp(1, 4).floor();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _authService.getUserLibraryStream(authUser.uid),
              builder: (context, librarySnapshot) {
                if (librarySnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final libraryBooks = librarySnapshot.data?.docs
                        .map((doc) => doc.data())
                        .toList() ??
                    [];

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
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  onPressed: () {
                                    context.go('/');
                                  },
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                       icon: Icon(
                                         Icons.bookmark_border_rounded,
                                         color: Theme.of(context).colorScheme.onSurface,
                                       ),
                                      onPressed: () {
                                        context.go('/bookmarks');
                                      },
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
                                                ),
                                              )
                                            : Icon(
                                                Icons.person_rounded,
                                                color: Colors.grey[600],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Library",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.lightText
                                            : AppColors.darkText,
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_rounded, size: 28),
                                  onPressed: _importLocalBook,
                                  color: AppColors.accentOrange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "You have 📚 ${libraryBooks.length} books in your library",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.lightSecondaryText
                                        : AppColors.darkSecondaryText,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            libraryBooks.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(48.0),
                                      child: Text(
                                        "Your library is empty. Import files or search online!",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 0.65,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 24,
                                    ),
                                    itemCount: libraryBooks.length,
                                    itemBuilder: (context, index) {
                                      final book = libraryBooks[index];
                                      return _buildBookCard(context, book);
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
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> book) {
    final title = book['title'] ?? 'Unknown';
    final imagePath = book['imagePath'] ?? 'assets/welcome_illustration.png';
    final isCompleted = book['isCompleted'] ?? false;
    final downloaded = book['downloaded'] ?? false;

    Widget image;
    if (imagePath.startsWith('assets/')) {
      image = Image.asset(imagePath,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else {
      image = Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.book_rounded, size: 40, color: Colors.grey),
        ),
      );
    }

    return BouncyTap(
      onTap: () {
        if (downloaded && book['filePath'] != null) {
          context.push('/reader', extra: {
            'bookId': book['bookId'].toString(),
            'filePath': book['filePath'] as String,
            'bookTitle': title,
            'fileType': book['fileType'] ?? 'epub',
          });
        } else {
          ToastService.showInfo(
            context,
            "Please re-download this book from the Search tab to read.",
          );
        }
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image,
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
          if (!downloaded)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.6 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.cloud_download_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}