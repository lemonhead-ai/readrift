import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';

class BookService {
  final String baseUrl = 'https://openlibrary.org';

  Future<List<Book>> searchBooks(String query, [BuildContext? context]) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search.json?q=$query&limit=20'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['docs'] as List).map((json) => Book.fromJson({'docs': [json]})).toList();
      } else {
        if (context != null) {
          ToastService.showError(context, 'Sorry, we couldn\'t search for books right now. Please try again.');
        }
        return [];
      }
    } catch (e) {
      if (context != null) {
        ToastService.showError(context, 'Please check your internet connection and try again.');
      }
      return [];
    }
  }

  Future<List<Book>> getRecommendations([BuildContext? context]) async {
    try {
      // Use trending for recommendations
      final response = await http.get(Uri.parse('$baseUrl/trending/daily.json?limit=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final works = data['works'] as List;
        return works.map((work) => Book.fromJson(work)).toList();
      } else {
        if (context != null) {
          ToastService.showWarning(context, 'We couldn\'t load recommendations right now');
        }
        return [];
      }
    } catch (e) {
      if (context != null) {
        ToastService.showWarning(context, 'Unable to load recommendations at the moment');
      }
      return [];
    }
  }

  Future<Book?> getBookDetails(String olKey, [BuildContext? context]) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$olKey.json'));
      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        if (context != null) {
          ToastService.showError(context, 'Sorry, we couldn\'t load the book details');
        }
        return null;
      }
    } catch (e) {
        if (context != null) {
          ToastService.showError(context, 'Please check your connection and try again');
        }
        return null;
      }
  }
}