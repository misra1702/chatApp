import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Chatroom temp = Chatroom(
      chatroomId: "12", members: [], admins: [], grpName: "", otherName: "");

  @override
  Widget build(BuildContext context) {
    String chatroomId = ModalRoute.of(context)?.settings.arguments as String;
    print("Inside chatScreen $chatroomId");
    return MultiProvider(
      providers: [
        StreamProvider<List<Chat>>(
          create: (context) {
            return ChatroomMethods.streamChats(chatroomId: chatroomId);
          },
          initialData: [],
        ),
        StreamProvider<Chatroom>(
          create: (context) =>
              ChatroomMethods.streamChatroom(chatroomId: chatroomId),
          initialData: temp,
        ),
      ],
      child: ChatScreenBody(),
    );
  }
}

class ChatScreenBody extends StatefulWidget {
  const ChatScreenBody({Key? key}) : super(key: key);

  @override
  _ChatScreenBodyState createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<ChatScreenBody> {
  @override
  Widget build(BuildContext context) {
    Chatroom chtroom = Provider.of<Chatroom>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ChatroomMethods.getChatroomName(chtroom)),
        actions: [
          chtroom.isGrp
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/groupInfo', arguments: chtroom);
                  },
                  icon: Icon(Icons.info_outline),
                )
              : Container(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Messages(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SendButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  SendButton({Key? key}) : super(key: key);
  final TextEditingController _txt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData thm = Theme.of(context);
    String chatroomId = Provider.of<Chatroom>(context).chatroomId;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _txt,
            maxLines: 6,
            minLines: 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: thm.accentColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: thm.accentColor),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            ChatroomMethods.sendMessage(
                text: _txt.text.trim(), chatroomId: chatroomId);
            _txt.clear();
          },
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData thm = Theme.of(context);
    List<Chat> chats = Provider.of<List<Chat>>(context);
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        Chat c = chats[index];
        DateTime t = c.createdOn.toDate();
        String createdTime = Globals.timeBeautify(value: t.hour) +
            ":" +
            Globals.timeBeautify(value: t.minute);
        bool isSender = (c.createdBy == Globals.cAuth.getUser!.displayName);
        return Container(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: size.width * 5 / 6),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: isSender
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue,
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade800,
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  "~" + c.createdBy,
                  style: thm.textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
                Text(
                  c.text,
                  style: thm.textTheme.bodyText1?.copyWith(fontSize: 17),
                ),
                Text(
                  createdTime,
                  style: thm.textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
