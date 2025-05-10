import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Stream to listen to user data changes from Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Sign up with email and password
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
        // Update the user's display name
        await user.updateDisplayName(username);
        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Success, no error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success, no error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success, no error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // Upload profile photo to Firebase Storage and update user profile
  Future<String?> updateProfilePhoto(File photoFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return "No user is currently signed in.";
      }
      // Upload the photo to Firebase Storage
      String filePath =
          'profile_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref(filePath).putFile(photoFile);
      TaskSnapshot snapshot = await uploadTask;
      String photoUrl = await snapshot.ref.getDownloadURL();

      // Update the user's photoURL in Firebase Authentication
      await user.updatePhotoURL(photoUrl);
      await user.reload();

      // Update the photoURL in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoUrl,
      });

      return null; // Success, no error
    } catch (e) {
      return "Failed to update profile photo: $e";
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
