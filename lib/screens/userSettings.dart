import 'package:chat_app/services/globals.dart';
import 'package:flutter/material.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    ThemeData thm = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Settings", style: thm.textTheme.headline4),
        ),
        body: UserSettingsBody(),
      ),
    );
  }
}

class UserSettingsBody extends StatefulWidget {
  const UserSettingsBody({Key? key}) : super(key: key);

  @override
  _UserSettingsBodyState createState() => _UserSettingsBodyState();
}

class _UserSettingsBodyState extends State<UserSettingsBody> {
  @override
  Widget build(BuildContext context) {
    ThemeData thm = Theme.of(context);
    return Column(
      children: [
        Text(
          Globals.cAuth.getUser!.displayName!,
          style: thm.textTheme.headline2?.copyWith(color: thm.accentColor),
        ),
      ],
    );
  }
}
