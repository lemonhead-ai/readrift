// lib/screens/book_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readrift/models/book.dart';

class BookReaderScreen extends StatelessWidget {
  final Book book;
  const BookReaderScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.downloadUrl == null) {
      return const Scaffold(body: Center(child: Text('No content available')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SfPdfViewer.network(
        book.downloadUrl!,
        onDocumentLoaded: (details) {
          // Track progress if needed
        },
      ),
    );
  }
}