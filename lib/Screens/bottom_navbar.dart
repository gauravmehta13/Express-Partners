import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:express_partner/OnBoarding/mandatory_kyc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../Widgets/custom_appbar.dart';
import '../constants.dart';
import '../drawer.dart';
import 'home.dart';
import 'stats_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseMessaging messaging = FirebaseMessaging.instance;

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  var dio = Dio();
  @override
  void initState() {
    super.initState();

    getProgress();
  }

  getProgress() async {
    try {
      final response = await dio.get(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?tenantSet_id=PAM01&tenantUsecase=pam&type=packersAndMoversSP&id=${_auth.currentUser!.uid}&checkDoneKyc=true',
      );
      Map<String, dynamic> map = json.decode(response.toString());
      print(map["resp"]);
      if (map["resp"] != true) {
        onBoardingIncomplete(context);
      }
    } catch (e) {
      if (_auth.currentUser == null) {
        Modular.to.pushReplacementNamed("/join");
      } else {
        onBoardingIncomplete(context);
      }
    }
  }

  Future<void> onBoardingIncomplete(ctx) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: ctx,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: CupertinoAlertDialog(
            title: Text("Uh Oh!"),
            content: Text(
                'Your KYC details are incomplete, You will now be redirected to fill KYC and Pricing Details'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Get.to(() => MandatoryKYC());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final List _screens = [HomePage(), StatsScreen(), Scaffold(), Container()];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: CustomAppBar(),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          elevation: 0.0,
          items: [Icons.home, Icons.insert_chart, Icons.event_note, Icons.info]
              .asMap()
              .map((key, value) => MapEntry(
                    key,
                    BottomNavigationBarItem(
                      label: '',
                      icon: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: _currentIndex == key
                              ? primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Icon(value),
                      ),
                    ),
                  ))
              .values
              .toList(),
        ),
      ),
    );
  }
}
