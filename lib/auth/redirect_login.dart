import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:express_partner/OnBoarding/mandatory_kyc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Screens/tnc.dart';
import '../constants.dart';
import '../fade_route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var focusNode = FocusNode();

class RedirectLogin extends StatefulWidget {
  final List? intracity;
  final List? intercity;
  final data;

  RedirectLogin({this.data, this.intercity, this.intracity});

  @override
  _RedirectLoginState createState() => _RedirectLoginState();
}

class _RedirectLoginState extends State<RedirectLogin> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  ConfirmationResult? confirmationResult;
  var isLoading = false;
  var loading = false;
  var isResend = false;
  var isRegister = true;
  var isOTPScreen = false;
  var verificationCode = '';

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      _auth.signOut();
    }
    if (widget.data != null) mobileNumber.text = widget.data["Phone"];
  }

  @override
  void dispose() {
    super.dispose();
  }

  clearCaptcha() {
    if (kIsWeb) {
      print("Clearing Captcha");
      RecaptchaVerifier().clear();
    }
  }

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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    login ? "Login" : "Get associated with Goflexe",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (login == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contact Person Name*",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        new TextFormField(
                          controller: name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (!login && (text == null || text.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          decoration: new InputDecoration(
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF2821B5),
                              ),
                            ),
                            border: new OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: Colors.grey[200]!)),
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
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  new TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      if (text.length < 10) {
                        return 'Must be of 10 digits';
                      }
                      return null;
                    },
                    autofocus: login,
                    maxLength: 10,
                    controller: mobileNumber,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      prefixText: "+91  ",
                      counterText: "",
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF2821B5),
                        ),
                      ),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.grey[200]!)),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
              if (!otp)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      login = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Already a User?",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
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
                ),
              box20,
              if (otp == true && isLoading == false)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter OTP*",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: PinCodeTextField(
                        focusNode: focusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty && otp) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        autoDisposeControllers: false,
                        enablePinAutofill: true,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(5),
                          inactiveFillColor: Colors.white,
                          inactiveColor: Colors.grey,
                          fieldHeight: 50,
                          fieldWidth: 50,
                        ),
                        enableActiveFill: false,
                        cursorColor: Colors.black,
                        animationDuration: Duration(milliseconds: 300),
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        boxShadows: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                        onCompleted: (v) {
                          confirmOtp();
                        },
                        // onTap: () {
                        //   print("Pressed");
                        // },
                        onChanged: (value) {
                          print(value);
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
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
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFf9a825), // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            confirmOtp();
                          }
                        },
                        child: Text(
                          login ? "Login" : "SignUp",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )
              else if (isLoading == true)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Theme.of(context).primaryColor,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Color(0xFFf9a825)),
                          )
                        ].where((c) => c != null).toList(),
                      )
                    ])
              else
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFf9a825), // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          otp = true;
                        });
                        await Login();
                      }
                    },
                    child: Text(
                      "Send OTP",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              box5,
              if (!otp)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      FadeRoute(page: TermsAndConditions()),
                    );
                  },
                  child: Container(
                    width: double.maxFinite,
                    child: Center(
                        child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                          text:
                              'By Continuing, I confirm that i have read the ',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          children: [
                            new TextSpan(
                              text: 'Cancellation Policy, ',
                              style: TextStyle(color: C.primaryColor),
                            ),
                            new TextSpan(
                              text: 'User Agreement, ',
                              style: TextStyle(color: C.primaryColor),
                            ),
                            new TextSpan(
                              text: 'Terms Of Service ',
                              style: TextStyle(color: C.primaryColor),
                            ),
                            new TextSpan(
                              text: 'and ',
                            ),
                            new TextSpan(
                              text: 'Privacy Policy ',
                              style: TextStyle(color: primaryColor),
                            ),
                            new TextSpan(
                              text: 'of GoFlexe.',
                            ),
                          ]),
                    )),
                  ),
                )
            ],
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
          FocusScope.of(context).requestFocus(focusNode);
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
                  Get.to(() => MandatoryKYC(
                        data: widget.data,
                      ));
                  // Modular.to.pushReplacementNamed('/onboarding',
                  //     arguments: );
                } else {
                  Get.to(() => MandatoryKYC(
                        data: widget.data,
                      ));
                  // var kyc = await getProgress();
                  // setState(() {
                  //   isLoading = false;
                  //   isResend = false;
                  // });
                  // if (kyc == true) {
                  //   Modular.to.pushReplacementNamed('/');
                  // } else {
                  //   Modular.to.pushReplacementNamed('/onboarding',
                  //       arguments: widget.data);
                  // }
                }
              }

              setState(() {
                isLoading = false;
                isResend = false;
              });
            });
          },
          verificationFailed: (FirebaseAuthException error) {
            displaySnackBar(error.toString(), context);
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
            FocusScope.of(context).requestFocus(focusNode);
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
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    print(_auth.currentUser!.uid);

    Map<String, dynamic> data = {
      "uid": _auth.currentUser!.uid,
      "mobile": _auth.currentUser!.phoneNumber,
      'name': name.text,
      "email": _auth.currentUser!.email
    };

    var database = firebaseFirestore
        .collection("accounts")
        .doc(_auth.currentUser!.uid)
        .set(data);
    return database;
  }

  confirmOtp() async {
    try {
      clearCaptcha();
      setState(() {
        isResend = false;
        isLoading = true;
      });

      print(kIsWeb);
      if (kIsWeb == true) {
        print("web");
        UserCredential userCredential =
            await confirmationResult!.confirm(otpController.text).then(
                // ignore: missing_return
                (user) async {
          if (user != null) {
            if (user.additionalUserInfo!.isNewUser == true) {
              await postData();
              widget.data != null ? logEvent('SMS_login') : logEvent("Login");
              setState(() {
                isLoading = false;
                isResend = false;
              });
              Get.to(() => MandatoryKYC(
                    data: widget.data,
                  ));
            } else {
              setState(() {
                isLoading = false;
                isResend = false;
              });
              Get.to(() => MandatoryKYC(
                    data: widget.data,
                  ));
              // if (kyc == true) {
              //   widget.data != null
              //       ? logEvent('SMS_login')
              //       : logEvent("Login");
              //   Modular.to.pushReplacementNamed('/');
              // } else {
              //   widget.data != null
              //       ? logEvent('SMS_login')
              //       : logEvent("Login");
              //   Modular.to.pushReplacementNamed('/onboarding',
              //       arguments: widget.data);
              // }
            }
          }
          setState(() {
            isLoading = false;
            isResend = false;
          });
          return user;
        });
      }
      if (kIsWeb == false) {
        print("app");
        await _auth
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: verificationCode,
                smsCode: otpController.text.toString()))
            .then((user) async {
          // ignore: unnecessary_null_comparison
          if (user != null) if (user.additionalUserInfo!.isNewUser == true) {
            await postData();
            widget.data != null ? logEvent('SMS_login') : logEvent("Login");
            setState(() {
              isLoading = false;
              isResend = false;
            });
            Get.to(() => MandatoryKYC(
                  data: widget.data,
                ));
          } else {
            // var kyc = await getProgress();
            // setState(() {
            //   isLoading = false;
            //   isResend = false;
            // });
            // if (kyc == true) {
            //   widget.data != null ? logEvent('SMS_login') : logEvent("Login");
            //      Get.to(()=> MandatoryKYC(
            //   data: widget.data,
            // ));
            // } else {
            //   widget.data != null ? logEvent('SMS_login') : logEvent("Login");
            //   Get.to(()=> MandatoryKYC(
            //   data: widget.data,
            // ));
            // }
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
      displaySnackBar("Error, Try Again Later..!!", context);
    }
  }
}
