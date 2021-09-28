import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'OnBoarding/mandatory_kyc.dart';
import 'OnBoarding/onboarding.dart';
import 'OnBoarding/sms_onboarding.dart';
import 'Screens/Order/notifications.dart';
import 'Screens/bottom_navbar.dart';
import 'constants.dart';
import 'noti/importNoti.dart';
import 'noti/notis/ab/abNoti.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = kIsWeb ? true : false;
  Noti noti = AppNoti();
  @override
  void initState() {
    if (kIsWeb) {
      final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
      subscription.onData((event) async {
        if (event != null) {
          debugPrint("We have a user now");
          setState(() {
            // home = "/";
          });
          subscription.cancel();
          setState(() {});
          debugPrint(FirebaseAuth.instance.currentUser!.uid);
        } else {
          debugPrint("No user yet..");
          await Future.delayed(const Duration(seconds: 4));
          if (loading) {
            setState(() {
              // home = "/join";
            });
            subscription.cancel();
            setState(() {});
          }
        }
      });
    }
    super.initState();
    Future(noti.init);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Packers And Movers',
            defaultTransition: Transition.fadeIn,
            theme: themeData(context),
            getPages: [
              GetPage(name: "/", page: () => BottomNavScreen()),
              GetPage(name: "/login", page: () => Onboarding()),
              GetPage(name: "/onboarding", page: () => const MandatoryKYC()),
              GetPage(name: "/accept-order", page: () => Notifications())
            ],
            home:
                _auth.currentUser == null ? SMSOnboarding() : BottomNavScreen(),
          );
  }
}
