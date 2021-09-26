import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../Constants.dart';
import '../../Fade Route.dart';
import 'My%20Orders.dart';
import 'accept%20more%20info.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Notifications extends StatefulWidget {
  final id;
  Notifications({this.id});
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  int notAvailable = 0;
  int problemInPricing = 1;
  int state = 2;
  Map? acceptanceData;
  var dio = Dio();
  Timer? timer;
  bool loading = true;

  void initState() {
    super.initState();
    checkLogin(context);
    fetchOrders();
    // final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
    // subscription.onData((event) async {
    //   if (event != null) {
    //     print("We have a user now");
    //     fetchOrders();
    //     print(FirebaseAuth.instance.currentUser);
    //     subscription.cancel();
    //   } else {
    //     print("No user yet..");
    //     await Future.delayed(Duration(seconds: 4));
    //     if (loading) {
    //       Modular.to.pushNamed('/login');
    //       setState(() {
    //         loading = false;
    //       });
    //       subscription.cancel();
    //     }
    //   }
    // });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   timer = new Timer(const Duration(seconds: 1), () {
    //     if (_auth.currentUser == null) {
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (BuildContext context) => Onboarding()));
    //     }
    //     fetchOrders();
    //   });
    // });
  }

  fetchOrders() async {
    try {
      var dio = Dio();
      var url =
          "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/customerorder/${widget.id}?tenantSet_id=PAM01&usecase=customerOrder";
      print(url);
      final response = await dio.get(url,
          options: Options(
            responseType: ResponseType.plain,
          ));

      var items = json.decode(response.toString());
      setState(() {
        acceptanceData = items["Item"];
      });
      print(acceptanceData);
      print(items);
      setState(() {
        loading = false;
      });
    } catch (e) {
      displaySnackBar("Please try Again Later");
      setState(() {
        loading = false;
      });
    }
  }

  acceptOrder() async {
    final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceorder',
        data: {
          "item": {
            "serviceProviderId": _auth.currentUser!.uid,
            "customerOrderId": widget.id,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
          }
        });
    print(response);
    print(response.statusCode);
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "GoFlexe",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: loading == true
          ? Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(0xFFf9a825)),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Notifications",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          Spacer(),
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "Mark as Read",
                                style: TextStyle(color: C.primaryColor),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            elevation: 1.5,
                            child: Container(
                                height: 250,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.truck,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'New Order Request',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              200,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      20),
                                                          child: AcceptMoreInfo(
                                                              details:
                                                                  acceptanceData));
                                                    });
                                                  });
                                            },
                                            child: Text(
                                              "More Info",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: C.primaryColor),
                                            ))
                                      ],
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          'Shift Type : ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        Text(
                                          acceptanceData!["shiftType"] ?? "NA",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.info,
                                          color: Colors.grey,
                                          size: 12,
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                    Spacer(),
                                    if (acceptanceData!["movementType"] ==
                                        "OutStation")
                                      Row(
                                        children: [
                                          Text(
                                            'From :  ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            acceptanceData!["pickupCity"] ??
                                                "NA",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                          Spacer(),
                                          Text(
                                            'To : ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            "Chennai",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(
                                            'Movement :  ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          Text(
                                            acceptanceData!["movementType"] ??
                                                "NA",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                          Spacer(),
                                          Text(
                                            'City :  ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          Text(
                                            acceptanceData!["pickupCity"] ??
                                                "NA",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          'Pickup :  ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        Text(
                                          acceptanceData!["shiftDate"] !=
                                                      null &&
                                                  acceptanceData![
                                                          "shiftDate"] !=
                                                      "null"
                                              ? new DateFormat("EEE, d MMMM")
                                                  .format(DateTime.parse(
                                                      acceptanceData![
                                                          "shiftDate"]))
                                                  .toString()
                                              : "NA",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        Spacer(),
                                        Text(
                                          'Drop :  ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        Text(
                                          acceptanceData!["dropDate"] != null &&
                                                  acceptanceData!["dropDate"] !=
                                                      "null"
                                              ? new DateFormat("EEE, d MMMM")
                                                  .format(DateTime.parse(
                                                      acceptanceData![
                                                          "dropDate"]))
                                                  .toString()
                                              : "NA",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       'Additional Services  ',
                                    //       style: TextStyle(
                                    //           fontSize: 14, color: Colors.grey[700]),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 2,
                                    //       child: ListView.builder(
                                    //           shrinkWrap: true,
                                    //           itemCount: widget
                                    //               .data["singleServices"].length,
                                    //           itemBuilder:
                                    //               (BuildContext context, int index) {
                                    //             return acceptanceData["singleServices"]
                                    //                         [index]["selected"] ==
                                    //                     true
                                    //                 ? Text(
                                    //                     "• ${acceptanceData["singleServices"][index]["label"] ?? ""}",
                                    //                     style: TextStyle(fontSize: 8),
                                    //                   )
                                    //                 : Container();
                                    //           }),
                                    //     ),
                                    //   ],
                                    // ),
                                    Row(
                                      children: [
                                        Text(
                                          "Additional Services  ",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                        Expanded(
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            itemCount: acceptanceData![
                                                    "singleServices"]
                                                .length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    mainAxisSpacing: 0,
                                                    crossAxisSpacing: 0,
                                                    childAspectRatio: 8 / 1,
                                                    crossAxisCount: 2),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return acceptanceData![
                                                          "singleServices"]
                                                      [index]["selected"]
                                                  ? Text(
                                                      "• ${acceptanceData!["singleServices"][index]["label"] ?? ""}",
                                                      style: TextStyle(
                                                          fontSize: 9),
                                                    )
                                                  : SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Row(children: [
                                      Text(
                                        'Total Amount :   ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700]),
                                      ),
                                      Text(
                                        'Rs. ${acceptanceData!["totalAmount"].toString()}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ]),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MaterialButton(
                                            color: Colors.green,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: BorderSide(
                                                    color: Colors.green)),
                                            onPressed: () async {
                                              int i = await acceptOrder();
                                              if (i == 200) {
                                                return showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                        return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  padding: EdgeInsets.only(
                                                                      left: 20,
                                                                      top: 65,
                                                                      right: 20,
                                                                      bottom:
                                                                          20),
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              45),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .maxFinite,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "Order Accepted Successfully",
                                                                          style: TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          "You can view the order details under My Orders",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        MaterialButton(
                                                                            color:
                                                                                C.primaryColor,
                                                                            textColor: Colors.white,
                                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                            child: Text("OK"),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                              Navigator.push(context, FadeRoute(page: MyOrders()));
                                                                            })
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  left: 20,
                                                                  right: 20,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    radius: 45,
                                                                    child: ClipRRect(
                                                                        child: Image.asset(
                                                                      "assets/approved.png",
                                                                      fit: BoxFit
                                                                          .fitHeight,
                                                                    )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ));
                                                      });
                                                    });
                                              }
                                            },
                                            child: Text("Accept",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: MaterialButton(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: BorderSide(
                                                    color:
                                                        Colors.orange[300]!)),
                                            onPressed: () {
                                              // return showDialog(
                                              //     barrierDismissible: false,
                                              //     context: context,
                                              //     builder:
                                              //         (BuildContext context) {
                                              //       return StatefulBuilder(
                                              //           builder: (context,
                                              //               setState) {
                                              //         return Dialog(
                                              //             shape:
                                              //                 RoundedRectangleBorder(
                                              //               borderRadius:
                                              //                   BorderRadius
                                              //                       .circular(
                                              //                           20),
                                              //             ),
                                              //             elevation: 0,
                                              //             backgroundColor:
                                              //                 Colors
                                              //                     .transparent,
                                              //             child: Stack(
                                              //               children: <Widget>[
                                              //                 Container(
                                              //                   padding: EdgeInsets
                                              //                       .only(
                                              //                           left:
                                              //                               20,
                                              //                           top: 65,
                                              //                           right:
                                              //                               20,
                                              //                           bottom:
                                              //                               20),
                                              //                   margin: EdgeInsets
                                              //                       .only(
                                              //                           top:
                                              //                               45),
                                              //                   decoration:
                                              //                       BoxDecoration(
                                              //                     shape: BoxShape
                                              //                         .rectangle,
                                              //                     color: Colors
                                              //                         .white,
                                              //                     borderRadius:
                                              //                         BorderRadius
                                              //                             .circular(
                                              //                                 10),
                                              //                   ),
                                              //                   child:
                                              //                       Container(
                                              //                     child: Column(
                                              //                       crossAxisAlignment:
                                              //                           CrossAxisAlignment
                                              //                               .center,
                                              //                       mainAxisSize:
                                              //                           MainAxisSize
                                              //                               .min,
                                              //                       children: [
                                              //                         Text(
                                              //                           "Why are you rejecting it?",
                                              //                           style: TextStyle(
                                              //                               fontSize:
                                              //                                   17,
                                              //                               fontWeight:
                                              //                                   FontWeight.w600),
                                              //                         ),
                                              //                         Divider(),
                                              //                         RadioListTile(
                                              //                           dense:
                                              //                               true,
                                              //                           value:
                                              //                               notAvailable,
                                              //                           groupValue:
                                              //                               state,
                                              //                           onChanged:
                                              //                               (dynamic e) {
                                              //                             setState(
                                              //                                 () {
                                              //                               state =
                                              //                                   0;
                                              //                             });
                                              //                           },
                                              //                           title:
                                              //                               Text(
                                              //                             "Not Available",
                                              //                           ),
                                              //                           subtitle:
                                              //                               Text("If your unavailable in this date, Please update your calendar"),
                                              //                         ),
                                              //                         Divider(),
                                              //                         RadioListTile(
                                              //                           dense:
                                              //                               true,
                                              //                           value:
                                              //                               problemInPricing,
                                              //                           groupValue:
                                              //                               state,
                                              //                           onChanged:
                                              //                               (dynamic e) {
                                              //                             setState(
                                              //                                 () {
                                              //                               state =
                                              //                                   1;
                                              //                             });
                                              //                           },
                                              //                           title: Text(
                                              //                               "Change in Price"),
                                              //                           subtitle:
                                              //                               Text("It is advisable to keep update price under pricing details."),
                                              //                         ),
                                              //                         if (state ==
                                              //                             1)
                                              //                           Padding(
                                              //                             padding: const EdgeInsets.symmetric(
                                              //                                 horizontal: 20,
                                              //                                 vertical: 10),
                                              //                             child:
                                              //                                 new TextFormField(
                                              //                               keyboardType:
                                              //                                   TextInputType.number,
                                              //                               decoration: new InputDecoration(
                                              //                                   isDense: true, // Added this
                                              //                                   contentPadding: EdgeInsets.all(15),
                                              //                                   focusedBorder: OutlineInputBorder(
                                              //                                     borderRadius: BorderRadius.all(Radius.circular(4)),
                                              //                                     borderSide: BorderSide(
                                              //                                       width: 1,
                                              //                                       color: Color(0xFF2821B5),
                                              //                                     ),
                                              //                                   ),
                                              //                                   labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                              //                                   labelText: "Update Price"),
                                              //                             ),
                                              //                           ),
                                              //                         Divider(),
                                              //                         SizedBox(
                                              //                           height:
                                              //                               10,
                                              //                         ),
                                              //                         state != 1
                                              //                             ? MaterialButton(
                                              //                                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              //                                 child: Text("Ok"),
                                              //                                 onPressed: () {
                                              //                                   Navigator.pop(context);
                                              //                                 })
                                              //                             : Row(
                                              //                                 children: [
                                              //                                   Expanded(
                                              //                                     child: MaterialButton(
                                              //                                       color: Colors.green,
                                              //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              //                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(color: Colors.green)),
                                              //                                       onPressed: () {
                                              //                                         Navigator.pop(context);
                                              //                                       },
                                              //                                       child: Text("Accept with New Price", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                              //                                     ),
                                              //                                   ),
                                              //                                 ],
                                              //                               )
                                              //                       ],
                                              //                     ),
                                              //                   ),
                                              //                 ),
                                              //                 Positioned(
                                              //                   left: 20,
                                              //                   right: 20,
                                              //                   child:
                                              //                       CircleAvatar(
                                              //                     backgroundColor:
                                              //                         Colors
                                              //                             .transparent,
                                              //                     radius: 45,
                                              //                     child: ClipRRect(
                                              //                         borderRadius: BorderRadius.all(Radius.circular(45)),
                                              //                         child: Image.asset(
                                              //                           "assets/reject.png",
                                              //                           fit: BoxFit
                                              //                               .fitHeight,
                                              //                         )),
                                              //                   ),
                                              //                 ),
                                              //               ],
                                              //             ));
                                              //       });
                                              //     });
                                            },
                                            color: Colors.orange[300],
                                            textColor: Colors.black,
                                            child: Text("Reject",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )),
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }

  displaySnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
