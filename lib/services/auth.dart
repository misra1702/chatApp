import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() {
    return _auth.signOut();
  }

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  User? get getUser {
    return _auth.currentUser;
  }

  Future<UserCredential?> login(
      String email, String password, BuildContext context) async {
    UserCredential? a;
    String snack = '';
    try {
      a = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        snack = 'Invalid Email';
      } else if (e.code == 'user-not-found') {
        snack = 'User Not Found';
      } else if (e.code == 'wrong-password') {
        snack = 'Wrong Password';
      }
    }
    if (snack != '') {
      SnackBar e = SnackBar(content: Text(snack));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(e);
    }
    return a;
  }

  Future<UserCredential?> signUp(
      String name, String email, String password, BuildContext context) async {
    UserCredential? a;
    String snack = '';
    if (name.trim() == "") {
      snack = "Please provide a name";
      SnackBar e = SnackBar(content: Text(snack));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(e);
      return a;
    }
    try {
      a = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        snack = 'Invalid Email';
      } else if (e.code == 'email-already-in-use') {
        snack = 'Email already in use';
      } else if (e.code == 'weak-password') {
        snack = 'Weak Password';
      }
      if (snack != '') {
        SnackBar e = SnackBar(content: Text(snack));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(e);
      }
    }
    if (a != null) {
      await _auth.currentUser?.updateDisplayName(name);
      print("User created with name ${_auth.currentUser?.displayName}");
    }
    return a;
  }
}
