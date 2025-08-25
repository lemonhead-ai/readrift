// lib/security/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(username);
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> updateProfilePhoto(File photoFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return "No user is currently signed in.";
      }
      String filePath =
          'profile_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref(filePath).putFile(photoFile);
      TaskSnapshot snapshot = await uploadTask;
      String photoUrl = await snapshot.ref.getDownloadURL();

      await user.updatePhotoURL(photoUrl);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
      });

      return null;
    } catch (e) {
      return "Failed to update profile photo: $e";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> addBookToLibrary(String uid, Book book) async {
    await _firestore.collection('users').doc(uid).collection('books').doc(book.id).set(book.toFirestore());
  }

  Stream<List<Book>> getUserLibraryStream(String uid) {
    return _firestore.collection('users').doc(uid).collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateBookProgress(String uid, String bookId, double progress, bool isCompleted) async {
    await _firestore.collection('users').doc(uid).collection('books').doc(bookId).update({
      'progress': progress,
      'isCompleted': isCompleted,
    });
  }

  Future<Book?> getCurrentReading(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).collection('books')
        .where('isCompleted', isEqualTo: false).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return Book.fromFirestore(snapshot.docs.first);
    }
    return null;
  }
}