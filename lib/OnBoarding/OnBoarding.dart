import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Widgets/counter.dart';
import '../constants.dart';
import '../drawer.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  ConfirmationResult? confirmationResult;
  var isLoading = false;
  var loading = false;
  var isResend = false;
  var isRegister = true;
  var isOTPScreen = false;
  var verificationCode = '';
  bool localShow = false;
  bool outstationShow = false;
  final formatCurrency =
      new NumberFormat.simpleCurrency(name: "", decimalDigits: 0);
  String? selectedPlace;
  TabController? _controller;
  late Timer timer;

  void initState() {
    super.initState();
    checkLogout(context);
    // final subscription = FirebaseAuth.instance.idTokenChanges().listen(null);
    // subscription.onData((event) async {
    //   if (event != null) {
    //     print("We have a user now");
    //     await Modular.to.navigate('/');
    //     subscription.cancel();
    //     setState(() {
    //       loading = false;
    //     });
    //     print(FirebaseAuth.instance.currentUser);
    //   } else {
    //     print("No user yet..");
    //     await Future.delayed(Duration(seconds: 4));
    //     if (loading) {
    //       subscription.cancel();
    //       setState(() {
    //         loading = false;
    //       });
    //     }
    //   }
    // });
    _controller = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  clearCaptcha() {
    if (kIsWeb) {
      print("Clearing Captcha");
      RecaptchaVerifier().clear();
    }
  }

  bool outstation = false;
  double noOfLocalMovement = 0;
  double noOfOutstationMovement = 0;
  static List<dynamic> _cities = [
    "Banglore",
    "Hyderabad",
    "Chennai",
  ];
  final _items = _cities
      .map((extraItems) => MultiSelectItem<dynamic>(
            extraItems,
            extraItems,
          ))
      .toList();
  List<dynamic> intercity = [];
  List<dynamic> intracity = [];

  var mobileNumber = new TextEditingController();
  var otpController = new TextEditingController();
  var name = new TextEditingController();
  bool priceCalculated = false;
  bool login = false;
  bool signup = false;
  bool price = false;
  bool otp = false;
  bool estimatorLoading = false;
  String? earnings;
  String? revenue;
  var dio = Dio();

  getEarnings() async {
    List intra = [];
    List inter = [];
    for (var i = 0; i < intracity.length; i++) {
      intra.add({"city": intracity[i]});
    }

    for (var i = 0; i < intercity.length; i++) {
      inter.add({"city": intercity[i]});
    }
    Map data = {
      "type": "totalEstimation",
      "tenantUsecase": "pam",
      "tenantSet_id": "PAM01",
      "useCase": "suggestion",
      "intracity": intra,
      "intercity": inter,
      "cntIntracity": noOfLocalMovement,
      "cntIntercity": noOfOutstationMovement
    };

    final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
        data: data);
    print(data);
    print(response);
    Map<String, dynamic>? map = json.decode(response.toString());
    setState(() {
      if (map!["resp"]['earning'] != null) {
        priceCalculated = true;
        earnings = map["resp"]['earning'].toString();
        revenue = map["resp"]['revenue'].toString();
      } else {
        priceCalculated = false;
      }
      estimatorLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: signup == true
            ? Container()
            : FloatingActionButton(
                onPressed: () {
                  launchWhatsApp();
                },
                backgroundColor: Color(0xFF25D366),
                child: FaIcon(FontAwesomeIcons.whatsapp),
              ),
        drawer: MyDrawer(),
        appBar: AppBar(
          elevation: 1,
          title: Text(
            "GoFlexe",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          // bottom: TabBar(
          //   controller: _controller,
          //   tabs: [
          //     Tab(
          //       text: "Packers & Movers",
          //     ),
          //   ],
          // ),
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
            : SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(children: [
                    Image.network(
                        "https://st4.depositphotos.com/1000975/20115/i/600/depositphotos_201150220-stock-photo-professional-movers-doing-home-relocation.jpg"),
                    Column(
                      children: [
                        Spacer(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: signup == false
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Check how much can you earn?",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MultiSelectBottomSheetField(
                                          initialChildSize: 0.4,
                                          listType: MultiSelectListType.CHIP,
                                          searchable: true,
                                          buttonText: Text(
                                            "Select Cities where you locally Transport",
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          title: Text("Cities you Serve"),
                                          items: _items,
                                          onConfirm: (values) {
                                            setState(() {
                                              intracity = values;
                                              localShow = true;
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(
                                            onTap: (dynamic value) {
                                              setState(() {
                                                intracity.remove(value);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MultiSelectBottomSheetField(
                                          initialChildSize: 0.4,
                                          listType: MultiSelectListType.CHIP,
                                          searchable: true,
                                          buttonText: Text(
                                            "Select Outstation Cities you Transport",
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          title: Text("Outstation Cities"),
                                          // initialValue: _cities,
                                          items: _items,
                                          onConfirm: (values) {
                                            setState(() {
                                              price = true;
                                              outstationShow = true;
                                              intercity = values;
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(
                                            onTap: (dynamic value) {
                                              setState(() {
                                                intercity.remove(value);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (localShow == true)
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Counter(
                                                        initialValue:
                                                            noOfLocalMovement,
                                                        minValue: 0,
                                                        maxValue: 10,
                                                        step: 1,
                                                        decimalPlaces: 0,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            noOfLocalMovement =
                                                                value as double;
                                                          });
                                                        }),
                                                    Text(
                                                      "Local Movements per week",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (outstationShow == true)
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Counter(
                                                        initialValue:
                                                            noOfOutstationMovement,
                                                        minValue: 0,
                                                        maxValue: 10,
                                                        step: 1,
                                                        decimalPlaces: 0,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            noOfOutstationMovement =
                                                                value as double;
                                                          });
                                                          getEarnings();
                                                        }),
                                                    Text(
                                                      "Outstation Movements per week",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        if (priceCalculated)
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 10, 10),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFc1f0dc),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text("Earnings"),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Center(
                                                              child: Text(
                                                            earnings != null
                                                                ? "₹ ${formatCurrency.format(int.parse(earnings ?? 0 as String))} per annum"
                                                                : "",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF2f7769),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 10, 10),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFc1f0dc),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text("Revenue"),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Center(
                                                              child: Text(
                                                            earnings != null
                                                                ? "₹ ${formatCurrency.format(int.parse(revenue as String))} per annum"
                                                                : "",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF2f7769),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(
                                                  0xFFf9a825), // background
                                              onPrimary:
                                                  Colors.white, // foreground
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                signup = true;
                                              });
                                            },
                                            child: Text(
                                              "Get Associated with Goflexe",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              signup = true;
                                              login = true;
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Already a User?",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                "Login",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF3f51b5)),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                icon: Icon(Icons.arrow_back),
                                                onPressed: () {
                                                  setState(() {
                                                    login = false;
                                                    signup = false;
                                                    otp = false;
                                                    priceCalculated = false;
                                                  });
                                                }),
                                            Text(
                                              login == false
                                                  ? "Get associated with Goflexe"
                                                  : "Login",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (login == false)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Contact Person Name*",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                  new TextFormField(
                                                    controller: name,
                                                    decoration:
                                                        new InputDecoration(
                                                      isDense:
                                                          true, // Added this
                                                      contentPadding:
                                                          EdgeInsets.all(15),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4)),
                                                        borderSide: BorderSide(
                                                          width: 1,
                                                          color:
                                                              Color(0xFF2821B5),
                                                        ),
                                                      ),
                                                      border: new OutlineInputBorder(
                                                          borderSide:
                                                              new BorderSide(
                                                                  color: Colors
                                                                          .grey[
                                                                      200]!)),
                                                      hintText: 'Name',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                            Text(
                                              "Enter Mobile Number*",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            new TextFormField(
                                              autofocus: login,
                                              controller: mobileNumber,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: new InputDecoration(
                                                prefixText: "+91  ",
                                                isDense: true, // Added this
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Color(0xFF2821B5),
                                                  ),
                                                ),
                                                border: new OutlineInputBorder(
                                                    borderSide: new BorderSide(
                                                        color:
                                                            Colors.grey[200]!)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                        if (otp == true && isLoading == false)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Enter OTP*",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0),
                                                child: PinCodeTextField(
                                                  appContext: context,
                                                  pastedTextStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  length: 6,
                                                  autoDisposeControllers: false,
                                                  enablePinAutofill: true,
                                                  animationType:
                                                      AnimationType.fade,
                                                  pinTheme: PinTheme(
                                                    shape: PinCodeFieldShape
                                                        .underline,
                                                    borderWidth: 2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    inactiveFillColor:
                                                        Colors.white,
                                                    inactiveColor: Colors.grey,
                                                    fieldHeight: 50,
                                                    fieldWidth: 50,
                                                  ),
                                                  enableActiveFill: false,
                                                  cursorColor: Colors.black,
                                                  animationDuration: Duration(
                                                      milliseconds: 300),
                                                  controller: otpController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  boxShadows: [
                                                    BoxShadow(
                                                      offset: Offset(0, 1),
                                                      color: Colors.black12,
                                                      blurRadius: 10,
                                                    )
                                                  ],
                                                  onCompleted: (v) {
                                                    print("Completed");
                                                  },
                                                  // onTap: () {
                                                  //   print("Pressed");
                                                  // },
                                                  onChanged: (value) {
                                                    print(value);
                                                  },
                                                  beforeTextPaste: (text) {
                                                    print(
                                                        "Allowing to paste $text");
                                                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                                    return true;
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: double.maxFinite,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Color(
                                                        0xFFf9a825), // background
                                                    onPrimary: Colors
                                                        .white, // foreground
                                                  ),
                                                  onPressed: () async {
                                                    // If the form is valid, we want to show a loading Snackbar
                                                    // If the form is valid, we want to do firebase signup...
                                                    try {
                                                      clearCaptcha();
                                                      setState(() {
                                                        isResend = false;
                                                        isLoading = true;
                                                      });
                                                      print("ok2");
                                                      print(kIsWeb);
                                                      if (kIsWeb == true) {
                                                        print("web");
                                                        UserCredential
                                                            userCredential =
                                                            await confirmationResult!
                                                                .confirm(
                                                                    otpController
                                                                        .text)
                                                                // ignore: missing_return
                                                                .then(
                                                                    // ignore: missing_return
                                                                    (user) async {
                                                                  if (user !=
                                                                      null) {
                                                                    if (user.additionalUserInfo!
                                                                            .isNewUser ==
                                                                        true) {
                                                                      await postData();
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                        isResend =
                                                                            false;
                                                                      });
                                                                      Modular.to
                                                                          .navigate(
                                                                              '/onboarding');
                                                                    } else {
                                                                      var kyc =
                                                                          await getProgress();
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                        isResend =
                                                                            false;
                                                                      });
                                                                      if (kyc ==
                                                                          true) {
                                                                        Modular
                                                                            .to
                                                                            .navigate('/');
                                                                      } else {
                                                                        Modular
                                                                            .to
                                                                            .navigate('/onboarding');
                                                                      }
                                                                    }
                                                                  }
                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                    isResend =
                                                                        false;
                                                                  });
                                                                } as FutureOr<
                                                                            UserCredential>
                                                                        Function(UserCredential));
                                                      }
                                                      if (kIsWeb == false) {
                                                        print("app");

                                                        print("appTry");
                                                        await _auth
                                                            .signInWithCredential(PhoneAuthProvider.credential(
                                                                verificationId:
                                                                    verificationCode,
                                                                smsCode:
                                                                    otpController
                                                                        .text
                                                                        .toString()))
                                                            .then((user) async {
                                                          if (user !=
                                                              null) if (user
                                                                  .additionalUserInfo!
                                                                  .isNewUser ==
                                                              true) {
                                                            await postData();
                                                            setState(() {
                                                              isLoading = false;
                                                              isResend = false;
                                                            });
                                                            Modular.to.navigate(
                                                                '/onboarding');
                                                          } else {
                                                            var kyc =
                                                                await getProgress();
                                                            setState(() {
                                                              isLoading = false;
                                                              isResend = false;
                                                            });
                                                            if (kyc == true) {
                                                              Modular.to
                                                                  .navigate(
                                                                      '/');
                                                            } else {
                                                              Modular.to.navigate(
                                                                  '/onboarding');
                                                            }
                                                          }
                                                        }).catchError((error) {
                                                          print(error);
                                                          setState(() {
                                                            isLoading = false;
                                                            isResend = true;
                                                          });
                                                        });
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      }
                                                    } catch (e) {
                                                      print(e);
                                                      isLoading = false;
                                                      displaySnackBar(
                                                          "Error, Try Again Later..!!",
                                                          context);
                                                    }
                                                  },
                                                  child: Text(
                                                    login == false
                                                        ? "SignUp"
                                                        : "Sign In",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        else if (isLoading == true)
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    CircularProgressIndicator(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      valueColor:
                                                          new AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Color(
                                                                  0xFFf9a825)),
                                                    )
                                                  ]
                                                      .where((c) => c != null)
                                                      .toList(),
                                                )
                                              ])
                                        else
                                          SizedBox(
                                            height: 50,
                                            width: double.maxFinite,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Color(
                                                    0xFFf9a825), // background
                                                onPrimary:
                                                    Colors.white, // foreground
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  otp = true;
                                                });
                                                await Login();
                                              },
                                              child: Text(
                                                "Send OTP",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        if (signup == true && login == false)
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Center(
                                                  child: new RichText(
                                                textAlign: TextAlign.center,
                                                text: new TextSpan(
                                                    text:
                                                        'By Continuing, I confirm that i have read the ',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12),
                                                    children: [
                                                      new TextSpan(
                                                        text:
                                                            'Cancellation Policy, ',
                                                        style: TextStyle(
                                                            color:
                                                                C.primaryColor),
                                                        recognizer: new TapGestureRecognizer()
                                                          ..onTap = () => print(
                                                              'Tap Here onTap'),
                                                      ),
                                                      new TextSpan(
                                                        text:
                                                            'User Agreement, ',
                                                        style: TextStyle(
                                                            color:
                                                                C.primaryColor),
                                                        recognizer: new TapGestureRecognizer()
                                                          ..onTap = () => print(
                                                              'Tap Here onTap'),
                                                      ),
                                                      new TextSpan(
                                                        text:
                                                            'Terms Of Service ',
                                                        style: TextStyle(
                                                            color:
                                                                C.primaryColor),
                                                        recognizer: new TapGestureRecognizer()
                                                          ..onTap = () => print(
                                                              'Tap Here onTap'),
                                                      ),
                                                      new TextSpan(
                                                        text: 'and ',
                                                        recognizer: new TapGestureRecognizer()
                                                          ..onTap = () => print(
                                                              'Tap Here onTap'),
                                                      ),
                                                      new TextSpan(
                                                        text: 'Privacy Policy ',
                                                        style: TextStyle(
                                                            color:
                                                                C.primaryColor),
                                                        recognizer: new TapGestureRecognizer()
                                                          ..onTap = () => print(
                                                              'Tap Here onTap'),
                                                      ),
                                                      new TextSpan(
                                                        text: 'of GoFlexe.',
                                                      ),
                                                    ]),
                                              ))
                                            ],
                                          )
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future Login() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (kIsWeb == true) {
        confirmationResult = await _auth.signInWithPhoneNumber(
          '+91 ' + mobileNumber.text.toString(),
          // RecaptchaVerifier()
        );
        setState(() {
          confirmationResult = confirmationResult;
          isLoading = false;
        });
      } else {
        var phoneNumber = '+91 ' + mobileNumber.text.trim();
        //ok, we have a valid user, now lets do otp verification
        var verifyPhoneNumber = _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (phoneAuthCredential) {
            //auto code complete (not manually)
            _auth.signInWithCredential(phoneAuthCredential).then((user) async {
              if (user != null) {
                if (user.additionalUserInfo!.isNewUser == true) {
                  await postData();
                  setState(() {
                    isLoading = false;
                    isResend = false;
                  });
                  Modular.to.navigate('/onboarding');
                } else {
                  var kyc = await getProgress();
                  setState(() {
                    isLoading = false;
                    isResend = false;
                  });
                  if (kyc == true) {
                    Modular.to.navigate('/');
                  } else {
                    Modular.to.navigate('/onboarding');
                  }
                }
              }
              ;
              setState(() {
                isLoading = false;
                isResend = false;
              });
            });
          },
          verificationFailed: (FirebaseAuthException error) {
            displaySnackBar(error, context);
            setState(() {
              isLoading = false;
              otp = false;
            });
          },
          codeSent: (verificationId, [forceResendingToken]) {
            setState(() {
              isLoading = false;
              verificationCode = verificationId;
              isOTPScreen = true;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              isLoading = false;
              verificationCode = verificationId;
            });
          },
          timeout: Duration(seconds: 60),
        );
        await verifyPhoneNumber;
      }
    } catch (e) {
      print(e);
      setState(() {
        otp = false;
        loading = false;
      });
      displaySnackBar("Error, Try Again Later..!!", context);
    }
  }

  postData() async {
    print(_auth.currentUser!.uid);
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
          data: {
            "type": "packersAndMoversSP",
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "localCities": intracity,
            "outstationCities": intracity,
            "id": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            'name': name.text
          });
      print(response);
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  getProgress() async {
    try {
      final response = await dio.get(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?tenantSet_id=PAM01&tenantUsecase=pam&type=packersAndMoversSP&id=${_auth.currentUser!.uid}&checkDoneKyc=true',
      );
      Map<String, dynamic> map = json.decode(response.toString());
      print(map["resp"]);
      return map["resp"];
    } catch (e) {
      print(e);
    }
  }
}
