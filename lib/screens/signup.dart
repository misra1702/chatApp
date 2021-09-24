import 'package:chat_app/services/db.dart';
import 'package:chat_app/services/globals.dart';
import 'package:chat_app/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  bool isVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final thm = Theme.of(context);
    print("Inside Login Screen");
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: size.width / 0.5,
              child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            Container(
              width: size.width / 1.1,
              child: Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: size.width / 1.1,
              child: Text(
                "Create Account to Continue!",
                style: TextStyle(
                  color: thm.accentColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: size.height / 10),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _name,
                keyboardType: TextInputType.text,
                maxLength: 30,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText: "Name",
                  hintStyle: thm.textTheme.bodyText2?.copyWith(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText: "Email",
                  hintStyle: thm.textTheme.bodyText2?.copyWith(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !isVisible,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: "password",
                  hintStyle: thm.textTheme.bodyText2?.copyWith(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffix: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        isVisible == true
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 16,
                      ),
                    ),
                    onTap: () {
                      setState(
                        () {
                          isVisible ^= true;
                          print(isVisible);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height / 10),
            Container(
              width: size.width,
              padding: EdgeInsets.only(left: 30, right: 30),
              child: ElevatedButton(
                onPressed: () async {
                  UserCredential? a = await Globals.cAuth
                      .signUp(_name.text, _email.text, _password.text, context);
                  if (a == null) return;
                  User b = Globals.cAuth.getUser!;
                  UsersMethods.addUser(Users(
                      uid: b.uid,
                      name: b.displayName!,
                      chatrooms: [],
                      friends: [],
                      email: b.email!));
                  Navigator.of(context).pushReplacementNamed('/grpScr');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sign Up",
                    style: thm.textTheme.headline4,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  animationDuration: Duration(seconds: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
