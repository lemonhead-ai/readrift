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
      switch (e.code) {
        case 'weak-password':
          return "Password is too weak. Please choose a stronger password.";
        case 'email-already-in-use':
          return "An account with this email already exists.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        default:
          return e.message ?? "Registration failed. Please try again.";
      }
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
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
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email address.";
        case 'wrong-password':
          return "Incorrect password. Please try again.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        case 'user-disabled':
          return "This account has been disabled.";
        case 'too-many-requests':
          return "Too many failed attempts. Please try again later.";
        default:
          return e.message ?? "Login failed. Please try again.";
      }
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email address.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        case 'too-many-requests':
          return "Too many reset attempts. Please try again later.";
        default:
          return e.message ?? "Failed to send reset email. Please try again.";
      }
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
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

  // Stream user's library from Firestore (Local implementation)
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserLibraryStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .snapshots();
  }

  // Add or update a book in user's Firestore library (Local implementation)
  Future<void> addBookToLibrary(
      String uid, Map<String, dynamic> bookMetadata) async {
    final bookId = bookMetadata['bookId'] as String;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .set(bookMetadata, SetOptions(merge: true));
  }

  // Update reading progress (Local implementation)
  Future<void> updateReadingProgress(
    String uid,
    String bookId,
    double progressPercent,
    String currentPosition,
  ) async {
    final isCompleted = progressPercent >= 0.99; // 99% or more is complete
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .update({
      'progressPercent': progressPercent,
      'currentPosition': currentPosition,
      'isCompleted': isCompleted,
    });
  }

  // Update book download status in Firestore (Local implementation)
  Future<void> updateDownloadStatus(
      String uid, String bookId, bool downloaded,
      {String? filePath}) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .update({
      'downloaded': downloaded,
      if (filePath != null) 'filePath': filePath,
    });
  }

  // --- Remote Branch (origin/master) Implementations ---
  Future<void> addBookToLibraryRemote(String uid, Book book) async {
    await _firestore.collection('users').doc(uid).collection('books').doc(book.id).set(book.toFirestore());
  }

  Stream<List<Book>> getUserLibraryStreamRemote(String uid) {
    return _firestore.collection('users').doc(uid).collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateBookProgressRemote(String uid, String bookId, double progress, bool isCompleted) async {
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

  // --- Annotation System (Highlights & Notes) ---
  Future<void> addAnnotation(String uid, String bookId, Map<String, dynamic> annotation) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .collection('annotations')
        .add({
          ...annotation,
          'uid': uid,
          'bookId': bookId,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAnnotationsStream(String uid, String bookId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .collection('annotations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllAnnotationsStream(String uid) {
    return _firestore
        .collectionGroup('annotations')
        .where('uid', isEqualTo: uid) // I need to make sure UID is stored in the annotation doc for collectionGroup queries to be safe and filtered
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteAnnotation(String uid, String bookId, String annotationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(bookId)
        .collection('annotations')
        .doc(annotationId)
        .delete();
  }

  // --- Streak & Engagement System ---
  Future<void> recordReadingSession(String uid, {int minutes = 1}) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final lastRead = data['lastReadDate'] != null 
          ? (data['lastReadDate'] as Timestamp).toDate() 
          : null;
      int currentStreak = data['streakCount'] ?? 0;
      int minutesToday = data['minutesReadToday'] ?? 0;
      int totalMinutes = data['totalMinutesRead'] ?? 0;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      totalMinutes += minutes;

      if (lastRead == null) {
        currentStreak = 1;
        minutesToday = minutes;
      } else {
        final lastReadDate = DateTime(lastRead.year, lastRead.month, lastRead.day);
        final difference = today.difference(lastReadDate).inDays;

        if (difference == 1) {
          // Consecutive day
          currentStreak++;
          minutesToday = minutes;
        } else if (difference > 1) {
          // Streak broken
          currentStreak = 1;
          minutesToday = minutes;
        } else {
          // Same day
          minutesToday += minutes;
        }
      }

      transaction.update(userRef, {
        'lastReadDate': FieldValue.serverTimestamp(),
        'streakCount': currentStreak,
        'minutesReadToday': minutesToday,
        'totalMinutesRead': totalMinutes,
      });
    });
  }

  Future<void> updateYearlyGoal(String uid, int goal) async {
    await _firestore.collection('users').doc(uid).update({
      'yearlyGoal': goal,
    });
  }

  // --- Notification System ---
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addNotification(String uid, Map<String, dynamic> notification) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
          ...notification,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
  }

  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String uid) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // --- User Preferences ---
  Future<void> updatePreference(String uid, String key, dynamic value) async {
    await _firestore.collection('users').doc(uid).update({
      'preferences.$key': value,
    });
  }
}

