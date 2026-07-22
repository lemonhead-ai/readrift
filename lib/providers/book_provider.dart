import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> recommendations = [];
  List<Book> library = [];

  Future<void> fetchRecommendations() async {
    try {
      recommendations = await BookService().getRecommendations();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch recommendations: $e");
    }
  }
}
