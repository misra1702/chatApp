import 'package:chat_app/screens/chatScreen.dart';
import 'package:chat_app/screens/createGroupScreen.dart';
import 'package:chat_app/screens/editAdmin.dart';
import 'package:chat_app/screens/groupInfo.dart';
import 'package:chat_app/screens/groupScreen.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/signup.dart';
import 'package:chat_app/screens/userSettings.dart';
import 'package:chat_app/services/globals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Colors.orange,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/grpScr': (context) => GroupScreen(),
        '/chatScreen': (context) => ChatScreen(),
        '/userSettings': (context) => UserSettings(),
        '/createGroup': (context) => CreateGroupScreen(),
        '/groupInfo': (context) => GroupInfo(),
        '/editAdmin': (context) => EditAdmin(),
      },
      home: func(),
    );
  }

  Widget func() {
    if (Globals.cAuth.getUser == null) {
      return LoginScreen();
    }
    return GroupScreen();
  }
}
