import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData thm = Theme.of(context);
    TextTheme txt = thm.textTheme;
    Size sz = MediaQuery.of(context).size;
    TextEditingController _email = TextEditingController();
    print("Inside Group Screen");
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats", style: Theme.of(context).textTheme.headline4),
        actions: [
          IconButton(
            onPressed: () {
              print("Sign Out button pressed");
              Globals.cAuth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: Icon(Icons.logout, size: 30),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).pushNamed('/userSettings');
          //   },
          //   icon: Icon(
          //     Icons.settings,
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  children: [
                    Card(
                      child: Container(
                        width: sz.width / 2.5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_box_rounded,
                                size: 30,
                              ),
                              Text("Add friend", style: txt.headline6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: TextField(
                                      controller: _email,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: thm.accentColor,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            bool val = await UsersMethods
                                                .userAddFriend(
                                                    email: _email.text,
                                                    context: context);
                                            if (val) {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: Text("Add"),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Card(
                      child: Container(
                        width: sz.width / 2.5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_add,
                                size: 30,
                              ),
                              Text("Add Group", style: txt.headline6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/createGroup');
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          StreamProvider<User?>(
            create: (context) {
              return Globals.cAuth.user;
            },
            initialData: null,
            builder: (context, snapshot) {
              return GroupScreenBody();
            },
          ),
        ],
      ),
    );
  }
}

class GroupScreenBody extends StatefulWidget {
  const GroupScreenBody({Key? key}) : super(key: key);

  @override
  _GroupScreenBodyState createState() => _GroupScreenBodyState();
}

class _GroupScreenBodyState extends State<GroupScreenBody> {
  Future<List<Chatroom>> func() async {
    Users u = await UsersMethods.getUserData(Globals.cAuth.getUser!.uid);
    List<Chatroom> a = [];
    if (u.chatrooms.isNotEmpty) {
      a = await ChatroomMethods.getChatroomList(chatroomIdList: u.chatrooms);
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    func();
    return FutureBuilder(
      future: func(),
      builder: (context, AsyncSnapshot<List<Chatroom>> snapshot) {
        ThemeData thm = Theme.of(context);
        if (snapshot.hasError) {
          return Container(
            child: Center(child: Text("Something went wrong!")),
          );
        } else if (snapshot.hasData) {
          List<Chatroom> data = snapshot.data!;
          if (data.length == 0) {
            return Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text("Click + to add friends and groups"),
              ),
            );
          }
          return Expanded(
            child: ListView(
              children: data.map(
                (e) {
                  return ListTile(
                    title: Text(
                      ChatroomMethods.getChatroomName(e),
                      style: thm.textTheme.headline5,
                    ),
                    leading: CircleAvatar(
                      child: Icon(
                        e.isGrp ? Icons.group : Icons.person,
                        color: thm.accentColor,
                        size: 30,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/chatScreen', arguments: e.chatroomId);
                    },
                  );
                },
              ).toList(),
            ),
          );
        }
        return Container(
          color: Theme.of(context).accentColor,
        );
      },
    );
  }
}
