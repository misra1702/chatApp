import 'package:chat_app/screens/additionalScreen.dart';
import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:flutter/material.dart';

class EditAdmin extends StatefulWidget {
  const EditAdmin({Key? key}) : super(key: key);

  @override
  _EditAdminState createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
  String cUid = Globals.cAuth.getUser!.uid;
  List<String> invert = [];

  @override
  Widget build(BuildContext context) {
    print("Inside EditAdmin");
    Chatroom c = ModalRoute.of(context)?.settings.arguments as Chatroom;
    ThemeData thm = Theme.of(context);
    String cUid = Globals.cAuth.getUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.grpName),
        actions: [
          IconButton(
            onPressed: () {},
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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        Users u = users[index];
                        bool isAdmin = (c.admins.contains(u.uid) &&
                                !invert.contains(u.uid)) ||
                            (invert.contains(u.uid) &&
                                !c.admins.contains(u.uid));
                        if (u.uid == cUid) {
                          return Container(
                            height: 0,
                            width: 0,
                          );
                        }
                        return ListTile(
                          title: Text(
                            u.name,
                            style: thm.textTheme.headline5,
                          ),
                          trailing: isAdmin
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (invert.contains(u.uid))
                                        invert.remove(u.uid);
                                      else
                                        invert.add(u.uid);
                                    });
                                  },
                                  child: Text("Remove Admin"))
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (invert.contains(u.uid))
                                        invert.remove(u.uid);
                                      else
                                        invert.add(u.uid);
                                    });
                                  },
                                  child: Text("Add Admin")),
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
