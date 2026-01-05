import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  AuthProvider() {
    user = _auth.currentUser;
  }

  // Login with email & password
  Future<String?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = credential.user;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign up with email & password
  Future<String?> signup(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = credential.user;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}
