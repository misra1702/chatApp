import 'package:chat_app/screens/additionalScreen.dart';
import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({Key? key}) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  String cUid = Globals.cAuth.getUser!.uid;

  @override
  Widget build(BuildContext context) {
    print("Inside GroupInfo");
    Chatroom c = ModalRoute.of(context)?.settings.arguments as Chatroom;
    ThemeData thm = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ChatroomMethods.getChatroomName(c)),
        actions: [
          PopupMenuButton(
            child: Icon(Icons.edit),
            onCanceled: () {},
            onSelected: (int val) {
              if (val == 0) {
                Navigator.of(context).pushNamed('/editAdmin',arguments: c);
              } else if (val == 1) {
                Navigator.of(context).pushNamed('/editMembers',arguments: c);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("Edit admin list"),
                  value: 0,
                ),
                PopupMenuItem(child: Text("Add or remove members"), value: 1),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    "Members",
                    style:
                        thm.textTheme.headline4?.copyWith(color: Colors.blue),
                  ),
                ),
                Container(
                  child: Text("${c.members.length} Participants"),
                ),
              ],
            ),
            FutureBuilder(
              future: ChatroomMethods.getChatroomMembers(c: c),
              builder: (context, AsyncSnapshot<List<Users>> snap) {
                if (snap.connectionState == ConnectionState.done) {
                  List<Users> users = snap.data!;
                  print(users.length);
                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        Users u = users[index];
                        return ListTile(
                          title: Text(
                            u.name,
                            style: thm.textTheme.headline5,
                          ),
                          trailing: c.admins.contains(u.uid)
                              ? Text("Admin")
                              : Container(width: 0),
                          onLongPress: () {
                            if (c.admins.contains(cUid)) {}
                          },
                        );
                      },
                    ),
                  );
                }
                return LoadingScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
