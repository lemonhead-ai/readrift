import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  final String baseUrl = 'https://openlibrary.org';

  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.json?q=$query&limit=20'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['docs'] as List).map((json) => Book.fromJson({'docs': [json]})).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  Future<List<Book>> getRecommendations() async {
    // Use trending for recommendations
    final response = await http.get(Uri.parse('$baseUrl/trending/daily.json?limit=10'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final works = data['works'] as List;
      return works.map((work) => Book.fromJson(work)).toList();
    } else {
      throw Exception('Failed to get recommendations');
    }
  }

  Future<Book> getBookDetails(String olKey) async {
    final response = await http.get(Uri.parse('$baseUrl$olKey.json'));
    if (response.statusCode == 200) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get book details');
    }
  }
}