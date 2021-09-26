import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Constants.dart';
import 'Fade Route.dart';
import 'OnBoarding/Availability.dart';
import 'OnBoarding/Price.dart';
import 'Screens/Check%20revenue%20.dart';
import 'Screens/Order/My%20Orders.dart';
import 'Screens/Review%20screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void initState() {
    super.initState();
    logEvent("App_Drawer");
  }

  var userName = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      color: Colors.white,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => EditProfilePage()));
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Color(0xFF3f51b5)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _auth.currentUser?.phoneNumber != null
                                ? Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              (_auth.currentUser?.phoneNumber ??
                                                  ""),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      // Icon(
                                      //   Icons.edit,
                                      //   color: Colors.white,
                                      //   size: 13,
                                      // )
                                    ],
                                  )
                                : Container(
                                    child: Text("Login",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.white,
                                        )),
                                  ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              if (_auth.currentUser != null)
                Column(
                  children: [
                    ListTile(
                      dense: true, // minLeadingWidth: 25,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: Text("Home"),
                      leading: FaIcon(
                        FontAwesomeIcons.home,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      // minLeadingWidth: 25,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          FadeRoute(page: MyOrders()),
                        );
                      },
                      title: Text("My Orders"),
                      leading: FaIcon(
                        FontAwesomeIcons.shoppingCart,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => AllPrices(
                                  old: "true",
                                )));
                      },
                      title: Text("Pricing Details"),
                      // minLeadingWidth: 25,
                      leading: FaIcon(
                        FontAwesomeIcons.rupeeSign,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeRoute(
                              page: Availability(
                            edit: "edit",
                          )),
                        );
                      },
                      title: Text("Availability"),
                      // minLeadingWidth: 25,
                      leading: FaIcon(
                        FontAwesomeIcons.checkCircle,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeRoute(page: ReviewScreen(edit: "true")),
                        );
                      },
                      title: Text("User Information"),
                      // minLeadingWidth: 25,
                      leading: FaIcon(
                        FontAwesomeIcons.userFriends,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      // minLeadingWidth: 25,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          FadeRoute(page: CheckRevenue()),
                        );
                      },
                      title: Text("Calculate Earnings"),
                      leading: FaIcon(
                        FontAwesomeIcons.moneyBillAlt,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              Spacer(),
              ListTile(
                dense: true,
                onTap: () {},
                title: Text("Report a Complaint"),
                // minLeadingWidth: 25,
                leading: FaIcon(
                  FontAwesomeIcons.heartBroken,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
              ExpansionTile(
                title: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.mailBulk,
                      color: Colors.black87,
                      size: 18,
                    ),
                    SizedBox(
                      width: 35,
                    ),
                    Text(
                      "Contact Us",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.linkedin,
                            color: Color(0xFF0072b1),
                          ),
                          onPressed: () {}),
                      IconButton(
                        icon: Icon(
                          Icons.mail_outline,
                          color: Color(0xFFD44638),
                        ),
                        onPressed: () {
                          _sendMail();
                        },
                      ),
                      IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Color(0xFF00acee),
                          ),
                          onPressed: () {}),
                      IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.telegram,
                            color: Color(0xFF0088cc),
                          ),
                          onPressed: () {})
                    ],
                  )
                  // ListTile(
                  //   onTap: () {},
                  //   title: Text("E-Mail"),
                  // minLeadingWidth: 25,
                  //   leading: Icon(
                  //     Icons.mail_outline,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // ListTile(
                  //   onTap: () {},
                  //   title: Text("LinkedIn"),
                  // minLeadingWidth: 25,
                  //   leading: FaIcon(
                  //     FontAwesomeIcons.linkedin,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                ],
              ),
              Divider(),
              if (_auth.currentUser != null)
                ListTile(
                  dense: true,
                  onTap: () {
                    signOut();
                  },
                  title: Text("SignOut"),
                  leading: FaIcon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  signOut() {
    _auth.signOut().then((value) => Modular.to.pushReplacementNamed("/join"));
  }

//   Future getUser() async {
//     print("object");
//     if (_auth.currentUser != null) {
//       print("object1");
//       var cellNumber = _auth.currentUser.phoneNumber;
//       cellNumber =
//           _auth.currentUser.phoneNumber.substring(3, cellNumber.length);
//       debugPrint(cellNumber);
//       await _firestore
//           .collection('users')
//           .where('cellnumber', isEqualTo: cellNumber)
//           .get()
//           .then((result) {
//         if (result.docs.length > 0) {
//           setState(() {
//             userName = result.docs[0].data()['name'];
//           });
//         }
//       });
//     }
//   }
}

_sendMail() async {
  // Android and iOS
  const uri = 'mailto:contact@goflexe.com';
  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    throw 'Could not launch $uri';
  }
}
