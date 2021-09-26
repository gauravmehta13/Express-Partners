import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import 'Constants.dart';
import 'OnBoarding/Mandatory%20KYC.dart';
import 'OnBoarding/OnBoarding.dart';
import 'OnBoarding/SMS%20Onboarding.dart';
import 'Screens/BottomNavBar.dart';
import 'Screens/Order/Notifications.dart';
import 'Screens/Terms And Conditions.dart';
import 'noti/importNoti.dart';
import 'noti/notis/ab/abNoti.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ModularApp(module: AppModule(), child: MyApp()));
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = kIsWeb ? true : false;
  Noti noti = AppNoti();
  String home = _auth.currentUser == null ? "/join" : "/";
  @override
  void initState() {
    if (kIsWeb) {
      final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
      subscription.onData((event) async {
        if (event != null) {
          print("We have a user now");
          setState(() {
            home = "/";
          });
          subscription.cancel();
          setState(() {
            loading = false;
          });
          print(FirebaseAuth.instance.currentUser);
        } else {
          debugPrint("No user yet..");
          await Future.delayed(const Duration(seconds: 4));
          if (loading) {
            setState(() {
              home = "/join";
            });
            subscription.cancel();
            setState(() {
              loading = false;
            });
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
        ? Container(child: Center(child: CircularProgressIndicator()))
        : FeatureDiscovery(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Packers And Movers',
              theme: themeData(context),
              initialRoute:
                  //"/accept-order/1b922164-eb26-44d7-b655-a4207c230c24",
                  home,
            ),
          );
  }
}

// app_module.dart
class AppModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];
  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, __) => BottomNavScreen(),
    ),
    ChildRoute(
      '/tnc',
      child: (_, __) => TermsAndConditions(),
    ),
    ChildRoute(
      '/login',
      child: (_, __) => Onboarding(),
    ),
    ChildRoute('/onboarding',
        child: (_, args) => MandatoryKYC(
              data: args.data,
            )),
    ChildRoute('/join/:id',
        child: (_, args) => SMSOnboarding(
              id: args.params['id'],
            )),
    ChildRoute('/join', child: (_, args) => SMSOnboarding()),
    ChildRoute(
      '/accept-order/:id',
      child: (_, args) => Notifications(
        id: args.params['id'],
      ),
    ),
  ];
}
