import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Screens/Order/notifications.dart';
import '../constants.dart';
import '../fade_route.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int notification = 0;
  void initState() {
    super.initState();
    firebaseOnMessage();
  }

  void onFirebaseOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(event.notification!.title);
    });
  }

  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      if (message != null) {
        final title = message.notification!.title;
        final body = message.notification!.body;
        setState(() {
          notification += notification;
        });
        // if (kIsWeb == true) {
        //   ScaffoldMessenger.of(context)
        //       .showSnackBar(SnackBar(content: Text("$title, $body")));
        //   showDialog(
        //       context: context,
        //       builder: (context) {
        //         return SimpleDialog(
        //           contentPadding: EdgeInsets.all(10),
        //           children: [Text(title), Text(body)],
        //         );
        //       });
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0.0,
      actions: <Widget>[
        IconButton(
          icon: Badge(
            showBadge: notification != 0,
            badgeContent: Text(
              notification != 0 ? notification.toString() : "",
              style: TextStyle(color: Colors.white),
            ),
            child: Icon(Icons.notifications_none),
          ),
          iconSize: 28.0,
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              FadeRoute(page: Notifications()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
