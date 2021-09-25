import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersMethods {
  static Future<List<Users>> getFriendsList() async {
    List<Users> a = [];
    String cUid = Globals.cAuth.getUser!.uid;
    print("Fetching friends list for user $cUid");
    var cUsers = await Globals.usersRef
        .doc(cUid)
        .get()
        .then((value) => Users.fromMap(value.data()!))
        .catchError((e) {
      print(e);
    });
    if (cUsers.friends.isEmpty) return a;
    return await Globals.usersRef
        .where('uid', whereIn: cUsers.friends)
        .get()
        .then(
      (snap) {
        return snap.docs.map(
          (doc) {
            return Users.fromMap(doc.data());
          },
        ).toList();
      },
    ).catchError(
      (e) {
        print(e);
      },
    );
  }

  static void addUser(Users user) {
    Globals.usersRef
        .doc(user.uid)
        .set(
          Users.usersToMap(user),
        )
        .then(
          (value) => print("User ${user.name} added"),
        )
        .catchError(
          (e) => print(e),
        );
  }

  static Future<Users> getUserData(String uid) async {
    Users x;
    x = await Globals.usersRef
        .doc(uid)
        .get()
        .then((value) => Users.fromMap(value.data()!))
        .catchError(
      (e) {
        print(e);
      },
    );
    return x;
  }

  static Future<bool> userAddFriend({
    required String email,
    required BuildContext context,
  }) async {
    //Checking if provided email is empty;
    if (email.trim() == "") {
      SnackBar e = SnackBar(content: Text("Please enter email"));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(e);
      return false;
    }

    var a = await Globals.usersRef
        .where('email', isEqualTo: email)
        .get()
        .then((data) {
      return data.docs.map((doc) {
        return Users.fromMap(doc.data());
      });
    });

    if (a.isEmpty) {
      SnackBar e = SnackBar(content: Text("Email not found!"));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(e);
      return false;
    }

    //Setting User uids
    String uid1 = Globals.cAuth.getUser!.uid;
    String uid2 = a.first.uid;

    if (uid1 == uid2) {
      print("Same user can't chat");
      return true;
    }
    Users temp = await UsersMethods.getUserData(uid1);
    if (temp.friends.contains(uid2)) {
      print("Already friend with $uid2");
      return true;
    }

    // Creating chatroom
    Chatroom c = Chatroom(
      admins: [],
      chatroomId: "",
      grpName: a.first.name,
      otherName: Globals.cAuth.getUser!.displayName!,
      isGrp: false,
      members: [Globals.cAuth.getUser!.uid, a.first.uid],
    );
    DocumentReference createdChatroom =
        await Globals.chatroomRef.add(Chatroom.toMap(c));
    createdChatroom.set(
      {
        'chatroomId': createdChatroom.id,
      },
      SetOptions(merge: true),
    );

    // adding chatroom to both users

    Globals.usersRef.doc(uid1).set(
      {
        'friends': FieldValue.arrayUnion([uid2]),
        'chatrooms': FieldValue.arrayUnion([createdChatroom.id]),
      },
      SetOptions(merge: true),
    ).catchError(
      (e) {
        print(e);
      },
    );

    Globals.usersRef.doc(uid2).set(
      {
        'friends': FieldValue.arrayUnion([uid1]),
        'chatrooms': FieldValue.arrayUnion([createdChatroom.id]),
      },
      SetOptions(merge: true),
    ).catchError(
      (e) {
        print(e);
      },
    );
    return true;
  }
}

class ChatroomMethods {
  static Future<bool> updateChatroom({required Chatroom c}) async {
    Chatroom prevC = await getChatroom(chatroomId: c.chatroomId);
    await Globals.chatroomRef.doc(c.chatroomId).set({
      'admins': c.admins,
      'members': c.members,
    }, SetOptions(merge: true)).catchError((e) {
      print(e);
    });
    c.members.forEach((member) async {
      if (!prevC.members.contains(member)) {
        await Globals.usersRef.doc(member).set({
          'chatrooms': FieldValue.arrayUnion([member]),
        }, SetOptions(merge: true));
      }
    });
    prevC.members.forEach((member) async {
      if (!c.members.contains(member)) {
        await Globals.usersRef.doc(member).set({
          'chatrooms': FieldValue.arrayRemove([member]),
        }, SetOptions(merge: true));
      }
    });
    return true;
  }

  static Future<bool> addChatroom({
    required List<String> members,
    required BuildContext context,
    required grpName,
  }) async {
    String snack = "";
    if (members.length < 2) {
      snack = "Please add 2 or more members";
    } else if (grpName.trim() == "") {
      snack = "Please provide a group name";
    }
    if (snack != "") {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(snack)));
      return false;
    }
    Chatroom temp = Chatroom(
      admins: [members.first],
      chatroomId: "",
      grpName: grpName,
      members: members,
      otherName: "",
      isGrp: true,
      chats: [],
    );
    DocumentReference createdChatroom =
        await Globals.chatroomRef.add(Chatroom.toMap(temp)).catchError((e) {
      print(e);
    });
    String docId = createdChatroom.id;
    print(docId);
    await Globals.chatroomRef.doc(docId).set(
      {
        'chatroomId': docId,
      },
      SetOptions(merge: true),
    ).catchError((e) {
      print(e);
    });
    members.forEach((element) async {
      await Globals.usersRef.doc(element).set(
        {
          'chatrooms': FieldValue.arrayUnion([docId]),
        },
        SetOptions(merge: true),
      );
    });
    return true;
  }

  static void sendMessage(
      {required String text, required String chatroomId}) async {
    if (text.trim() == "") {
      print("Message empty");
      return;
    }
    Chat c = Chat(
      createdBy: Globals.cAuth.getUser!.displayName!,
      createdOn: Timestamp.now(),
      text: text,
    );
    await Globals.chatroomRef
        .doc(chatroomId)
        .collection('chats')
        .add(Chat.toMap(c))
        .catchError((e) {
      print(e);
    });
  }

  static String getChatroomName(Chatroom chtroom) {
    if (chtroom.isGrp) return chtroom.grpName;
    return chtroom.grpName == Globals.cAuth.getUser!.displayName
        ? chtroom.otherName
        : chtroom.grpName;
  }

  static Future<Chatroom> getChatroom({required String chatroomId}) async {
    print("Fetching chatroom for id $chatroomId");
    return await Globals.chatroomRef
        .doc(chatroomId)
        .get()
        .then((value) => Chatroom.fromMap(value.data()!))
        .catchError((e) {
      print(e);
    });
  }

  static Stream<Chatroom> streamChatroom({required String chatroomId}) {
    print("Starting stream of chatrooom for $chatroomId");
    return Globals.chatroomRef
        .doc(chatroomId)
        .snapshots()
        .map((snap) => Chatroom.fromMap(snap.data()!));
  }

  static Stream<List<Chat>> streamChats({required String chatroomId}) {
    print("Starting Stream of chats for $chatroomId");
    return Globals.chatroomRef
        .doc(chatroomId)
        .collection('chats')
        .orderBy('createdOn')
        .snapshots()
        .map(
      (snap) {
        return snap.docs.map(
          (doc) {
            return Chat.fromMap(doc.data());
          },
        ).toList();
      },
    );
  }

  static Future<List<Chatroom>> getChatroomList(
      {required List<String> chatroomIdList}) async {
    print("Fetching chatrooms for ids $chatroomIdList");

    List<Chatroom>? temp = await Globals.chatroomRef
        .where('chatroomId', whereIn: chatroomIdList)
        .get()
        .then(
      (docList) {
        return docList.docs.map(
          (doc) {
            return Chatroom.fromMap(doc.data());
          },
        ).toList();
      },
    );
    return temp!;
  }

  static Future<List<Users>> getChatroomMembers({required Chatroom c}) async {
    return Globals.usersRef.where('uid', whereIn: c.members).get().then(
      (snap) {
        return snap.docs.map((doc) => Users.fromMap(doc.data())).toList();
      },
    ).catchError(
      (e) {
        print(e);
      },
    );
  }
}
