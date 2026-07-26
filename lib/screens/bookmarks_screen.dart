import 'package:readrift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:readrift/theme.dart';
import 'package:readrift/widgets/custom_toast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  BookmarksScreenState createState() => BookmarksScreenState();
}

class BookmarksScreenState extends State<BookmarksScreen> {
  final AuthService _authService = AuthService();

  Future<void> _removeBookmark(String bookId, String annotationId) async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    await _authService.deleteAnnotation(user.uid, bookId, annotationId);
    if (mounted) {
      ToastService.showSuccess(context, 'Bookmark has been removed');
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

    return Scaffold(
      extendBody: true,
      body: SafeArea(
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
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => context.go('/profile'),
                  ),
                  Text(
                    'Universe Sync',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _authService.getAllAnnotationsStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Your Universe is quiet',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text('Save highlights or notes while reading to sync them here.'),
                        ],
                      ),
                    );
                  }

                  final annotations = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: annotations.length,
                    itemBuilder: (context, index) {
                      final data = annotations[index].data();
                      final docId = annotations[index].id;
                      final bookId = data['bookId'] as String;
                      final date = data['createdAt'] != null 
                          ? DateFormat('MMM d, yyyy').format((data['createdAt'] as Timestamp).toDate())
                          : 'Just now';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            data['title'] ?? 'Untitled Highlight',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                data['text'] ?? '',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  if (data['page'] != null)
                                    Text("Page ${data['page']}", style: const TextStyle(color: AppColors.accentOrange, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeBookmark(bookId, docId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
