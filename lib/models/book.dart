import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;  // Open Library key or Firestore ID
  final String title;
  final String author;
  final String? coverUrl;  // Dynamic cover from API
  final bool isCompleted;
  final bool isFree;
  final String? downloadUrl;  // Link to PDF if free
  final double progress;  // e.g., 0.15 for 15%
  final String? iaId;  // Internet Archive ID for borrowing/reading

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.isCompleted = false,
    this.isFree = false,
    this.downloadUrl,
    this.progress = 0.0,
    this.iaId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final doc = json['docs'] != null ? json['docs'][0] : json;  // Handle search results
    final authors = doc['author_name'] != null ? doc['author_name'][0] : 'Unknown';
    final coverId = doc['cover_i'];
    final coverUrl = coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg' : null;
    final iaId = doc['ia']?[0];  // First IA ID if available
    final isFree = doc['ebook_access'] == 'public' || iaId != null;

    return Book(
      id: doc['key'] ?? doc['id'],
      title: doc['title'] ?? 'Unknown Title',
      author: authors,
      coverUrl: coverUrl,
      isFree: isFree,
      iaId: iaId,
      downloadUrl: isFree && iaId != null ? 'https://archive.org/download/$iaId/$iaId.pdf' : null,
    );
  }

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'],
      author: data['author'],
      coverUrl: data['coverUrl'],
      isCompleted: data['isCompleted'] ?? false,
      isFree: data['isFree'] ?? false,
      downloadUrl: data['downloadUrl'],
      progress: data['progress'] ?? 0.0,
      iaId: data['iaId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'isCompleted': isCompleted,
      'isFree': isFree,
      'downloadUrl': downloadUrl,
      'progress': progress,
      'iaId': iaId,
    };
  }
}