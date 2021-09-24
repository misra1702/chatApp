import 'package:chat_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Globals {
  static final cAuth = AuthService();
  static final usersRef = FirebaseFirestore.instance.collection('users');
  static final chatroomRef = FirebaseFirestore.instance.collection('chatrooms');
  static final dbRef = FirebaseFirestore.instance;

  static String timeBeautify({required int value}) {
    if (value / 10 >= 1) return value.toString();
    return '0' + value.toString();
  }
}
