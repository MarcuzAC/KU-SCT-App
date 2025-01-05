// ignore_for_file: implementation_imports, empty_catches

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign-In
  Future<UserCredential?> loginWithGoogle() async {
    try {
      // Trigger the Google Sign-In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  /// Email & Password Sign-Up
  Future<String> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Signup successful'; // Signup successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email is already in use';
      }
      return 'Signup failed: ${e.message}';
    }
  }

  /// Email & Password Sign-In
  Future<String> signin({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Sign-in successful';
    } on FirebaseAuthException catch (e) {
      return 'Login failed: ${e.message}';
    }
  }

  /// Sign-Out
  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {}
  }
}
