import 'package:chat_app/screens/additionalScreen.dart';
import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:flutter/material.dart';

class EditMembers extends StatefulWidget {
  const EditMembers({Key? key}) : super(key: key);

  @override
  _EditMembersState createState() => _EditMembersState();
}

class _EditMembersState extends State<EditMembers> {
  String cUid = Globals.cAuth.getUser!.uid;
  List<String> invert = [];

  @override
  Widget build(BuildContext context) {
    print("Inside EditMembers");
    Chatroom c = ModalRoute.of(context)?.settings.arguments as Chatroom;
    ThemeData thm = Theme.of(context);
    String cUid = Globals.cAuth.getUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.grpName),
        actions: [
          IconButton(
            onPressed: () async {
              List<String> temp = [];

              c.members.forEach((element) {
                bool isMember = (c.members.contains(element) &&
                        !invert.contains(element)) ||
                    (invert.contains(element) && !c.members.contains(element));
                if (isMember) temp.add(element);
              });
              c.members = temp;
              bool val = await ChatroomMethods.updateChatroom(c: c);
              if (val == true) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('/chatScreen'));
              }
            },
            icon: Icon(Icons.save),
          ),
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
              ],
            ),
            FutureBuilder(
              future: ChatroomMethods.getChatroomMembers(c: c),
              builder: (context, AsyncSnapshot<List<Users>> snap) {
                if (snap.connectionState == ConnectionState.done) {
                  List<Users> users = snap.data!;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        Users u = users[index];
                        bool isMember = (c.members.contains(u.uid) &&
                                !invert.contains(u.uid)) ||
                            (invert.contains(u.uid) &&
                                !c.members.contains(u.uid));
                        if (u.uid == cUid) {
                          return Container(
                            height: 0,
                            width: 0,
                          );
                        }
                        return isMember
                            ? ListTile(
                                title: Text(
                                  u.name,
                                  style: thm.textTheme.headline5,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (invert.contains(u.uid))
                                          invert.remove(u.uid);
                                        else
                                          invert.add(u.uid);
                                      });
                                    },
                                    icon: Icon(Icons.delete)))
                            : SizedBox.shrink();
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
