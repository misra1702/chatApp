import 'package:chat_app/screens/additionalScreen.dart';
import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    print('Inside CreateGroupScreen');
    ThemeData thm = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Members",
          style: thm.textTheme.headline4,
        ),
      ),
      body: FutureBuilder(
        future: UsersMethods.getFriendsList(),
        builder: (context, AsyncSnapshot<List<Users>> snap) {
          if (snap.hasError) {
            return ErrorScreen();
          } else if (snap.connectionState == ConnectionState.done) {
            List<Users> frList = snap.data!;
            return CGSBody(frList: frList);
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class CGSBody extends StatefulWidget {
  const CGSBody({Key? key, required this.frList}) : super(key: key);
  final List<Users> frList;
  @override
  _CGSBodyState createState() => _CGSBodyState();
}

class _CGSBodyState extends State<CGSBody> {
  TextEditingController _grpName = TextEditingController();
  List<String> selected = [Globals.cAuth.getUser!.uid];
  @override
  void dispose() {
    super.dispose();
    _grpName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData thm = Theme.of(context);
    bool noFriends = widget.frList.isEmpty;
    Color selCol = Colors.lightBlue.shade400;
    Color nselCol = Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.text,
            controller: _grpName,
            decoration: InputDecoration(
              labelText: "Group Name",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: thm.accentColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: 10),
          noFriends
              ? Container(
                  color: Colors.blue,
                )
              : Expanded(
                  child: ListView(
                    children: widget.frList.map(
                      (fr) {
                        return ListTile(
                          tileColor:
                              selected.contains(fr.uid) ? selCol : nselCol,
                          title: Text(fr.name),
                          trailing: selected.contains(fr.uid)
                              ? Icon(Icons.done)
                              : null,
                          onTap: () {
                            setState(
                              () {
                                selected.remove(fr.uid);
                              },
                            );
                          },
                          onLongPress: () {
                            if (selected.contains(fr.uid)) return;
                            setState(
                              () {
                                selected.add(fr.uid);
                              },
                            );
                          },
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
          ElevatedButton(
            onPressed: () async {
              bool value = await ChatroomMethods.addChatroom(
                  members: selected, context: context, grpName: _grpName.text);
              if (value == true) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              child: Text("Create Group"),
            ),
          ),
        ],
      ),
    );
  }
}
