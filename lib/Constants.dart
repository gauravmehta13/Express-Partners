import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

List<dynamic> cities = [
  "Bangalore",
  "Hyderabad",
  "Chennai",
  "Pune",
  "Mumbai",
  "NCR",
  "Dehradun",
  "Amritsar"
];

List<dynamic> mapByKey(String keyName, List<dynamic> input) {
  Map returnValue = Map();
  for (var currMap in input) {
    if (currMap.containsKey(keyName)) {
      var currKeyValue = currMap[keyName];
      if (!returnValue.containsKey(currKeyValue)) {
        returnValue[currKeyValue] = {currKeyValue: []};
      }
      returnValue[currKeyValue][currKeyValue].add(currMap);
    }
  }
  return returnValue.values.toList();
}

List? baseLocation = ["Pune"];

logEvent(String text) {
  // if (kIsWeb) {
  //   FirebaseAnalytics().logEvent(name: text, parameters: null);
  //   print("Logged Event");
  // }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
String? name;
String? rating;

const EdgeInsets padding10 = EdgeInsets.all(10);
const SizedBox box10 = SizedBox(
  height: 10,
);
const SizedBox box5 = SizedBox(
  height: 5,
);
const SizedBox box20 = SizedBox(
  height: 20,
);
const SizedBox box30 = SizedBox(
  height: 30,
);
const Color secondaryColor = Color(0xFFea6000);
const Color primaryColor = Color(0xFF0a2635);

const Color priceBarColor = Color(0xFFeceef8);
const Text priceConfirmText = Text("Review & Confirm");
const String priceValidator = "Required";

checkLogin(ctx) {
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    if (_auth.currentUser == null) {
      Modular.to.navigate('/join');
    }
  });
}

checkLogout(ctx) {
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    if (_auth.currentUser != null) {
      Modular.to.navigate('/');
    }
  });
}

themeData(context) {
  return ThemeData(
    appBarTheme: Theme.of(context)
        .appBarTheme
        .copyWith(brightness: Brightness.light, color: primaryColor),
    textTheme: GoogleFonts.montserratTextTheme(
      Theme.of(context).textTheme,
    ),
    selectedRowColor: primaryColor,
    primaryColor: primaryColor,
    accentColor: primaryColor,
    backgroundColor: primaryColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: primaryColor, // background
        onPrimary: Colors.white, // foreground
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
    ),
  );
}

displaySnackBar(text, ctx) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    ),
  );
}

launchWhatsApp() async {
  logEvent("Contact_Us");
  final link = WhatsAppUnilink(
    phoneNumber: '+918209145057',
    text: "Hey! I'm inquiring about the services provided by Goflexe",
  );
  await launch('$link');
}

Future<void> pricesCalculated(ctx) async {
  return showDialog<void>(
    context: ctx,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Text(
            'We have assisted in calculating the automated prices. Please confirm or edit the prices.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> correctPricing(ctx) async {
  return showDialog<void>(
    context: ctx,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.warning)],
        ),
        content: Text(
          'Are you sure this is the correct pricing?',
          style: TextStyle(fontSize: 13),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('YES'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class C {
  static const textfieldBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0.0));

  static const box10 = SizedBox(
    height: 10,
  );
  static const box20 = SizedBox(
    height: 20,
  );
  static const box30 = SizedBox(
    height: 30,
  );
  static const wbox10 = SizedBox(
    width: 10,
  );
  static const wbox20 = SizedBox(
    width: 20,
  );
  static const wbox30 = SizedBox(
    width: 30,
  );

  static const Color primaryColor = Color(0xFFea6001);
  static const Color secondaryColor = Color(0xFF0a2635);
}

class Palette {
  static const Color primaryColor = Color(0xFF473F97);
}

class Styles {
  static const buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  static const chartLabelsTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  static const tabTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );
}

class BezierPainter extends CustomPainter {
  const BezierPainter({
    this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color? color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color!;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
