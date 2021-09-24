import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Users {
  String uid;
  String name;
  List<String> chatrooms;
  List<String> friends;
  String email;

  Users(
      {required this.uid,
      required this.name,
      required this.chatrooms,
      required this.email,
      required this.friends});

  static Users fromMap(Map<String, dynamic> data) {
    List<dynamic> tempCht = data['chatrooms'];
    List<dynamic> tempfri = data['friends'];
    List<String> cht = List<String>.from(tempCht);
    List<String> fri = List<String>.from(tempfri);

    return Users(
        uid: data['uid'],
        name: data['name'],
        chatrooms: cht,
        friends: fri,
        email: data['email']);
  }

  static Map<String, dynamic> usersToMap(Users user) {
    Map<String, dynamic> data = {};
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['chatrooms'] = user.chatrooms;
    data['email'] = user.email;
    data['friends'] = user.friends;
    return data;
  }
}

class Chatroom {
  String chatroomId;
  List<String> members;
  List<String> admins;
  List<Chat>? chats;
  bool isGrp = true;
  String grpName;
  String otherName;

  Chatroom(
      {required this.chatroomId,
      required this.members,
      required this.admins,
      this.chats,
      required this.grpName,
      required this.otherName,
      this.isGrp = true});

  static Chatroom fromMap(Map<String, dynamic> data) {
    List<dynamic> memTemp = data['members'];
    List<dynamic> adminTemp = data['admins'];

    List<String> mem = List<String>.from(memTemp);
    List<String> admin = List<String>.from(adminTemp);

    return Chatroom(
      chatroomId: data['chatroomId'],
      admins: admin,
      members: mem,
      grpName: data['grpName'],
      otherName: data['otherName'],
      isGrp: data['isGrp'],
    );
  }

  static Map<String, dynamic> toMap(Chatroom c) {
    Map<String, dynamic> data = {};

    data['chatroomId'] = c.chatroomId;
    data['admins'] = c.admins;
    data['members'] = c.members;
    data['otherName'] = c.otherName;
    data['grpName'] = c.grpName;
    data['isGrp'] = c.isGrp;

    return data;
  }
}

class Chat {
  Timestamp createdOn;
  String createdBy;
  String text;

  Chat({required this.createdOn, required this.createdBy, required this.text});

  static Chat fromMap(Map<String, dynamic> data) {

    return Chat(
      createdOn: data['createdOn'],
      createdBy: data['createdBy'],
      text: data['text'],
    );
  }

  static Map<String, dynamic> toMap(Chat c) {
    Map<String, dynamic> data = {};
    data['createdBy'] = c.createdBy;
    data['createdOn'] = c.createdOn;
    data['text'] = c.text;
    return data;
  }
}
