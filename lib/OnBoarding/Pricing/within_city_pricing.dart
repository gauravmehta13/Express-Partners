import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Widgets/item_list.dart';
import '../../constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class WithinCityPricing extends StatefulWidget {
  final data;
  final ValueChanged<int>? update;
  WithinCityPricing({this.update, this.data});
  @override
  _WithinCityPricingState createState() => _WithinCityPricingState();
}

class _WithinCityPricingState extends State<WithinCityPricing> {
  final formKey = GlobalKey<FormState>();
  var dio = Dio();
  List<dynamic>? withinCity = [];
  TextEditingController one = TextEditingController();
  TextEditingController two = TextEditingController();
  TextEditingController three = TextEditingController();
  List<TextEditingController> withinoneBhkPrice = [];
  List<TextEditingController> withintwoBhkPrice = [];
  List<TextEditingController> withinthreeBhkPrice = [];
  bool sendingData = false;

  postWithinCityData() async {
    Map<String, dynamic> data = {
      "localPricing": {
        "1bhk": one.text,
        "2bhk": two.text,
        "3bhk": three.text,
      },
    };
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var database = await firebaseFirestore
        .collection("vendors")
        .doc(_auth.currentUser!.uid)
        .update(data)
        .then((value) => widget.update!(1))
        .onError((error, stackTrace) {
      displaySnackBar("error, please try again later", context);
      log(error.toString());
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          box10,
          SizedBox(height: 70, child: Image.asset("assets/within.png")),
          box10,
          Text(
            "Within City Pricing",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text(
            "Add pricing for a single city and we will assist in calculating the rest of the prices.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          box20,
          loading
              ? Container(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    ItemList(),
                    box20,
                    Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            width: double.infinity,
                            color: priceBarColor,
                            child: const Text(
                              "Price per 50 Kms",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3f51b5)),
                                        controller: one,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                            border: C.textfieldBorder,
                                            isDense: true, // Added this
                                            prefixText: "₹ ",
                                            labelText: "1 BHK Price",
                                            helperStyle: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                            ),
                                            helperMaxLines: 2,
                                            labelStyle:
                                                TextStyle(fontSize: 13)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return priceValidator;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3f51b5)),
                                        controller: two,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: C.textfieldBorder,
                                            isDense: true, // Added this
                                            prefixText: "₹ ",
                                            helperStyle: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                            ),
                                            labelText: "2 BHK Price",
                                            labelStyle:
                                                TextStyle(fontSize: 13)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return priceValidator;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3f51b5)),
                                        controller: three,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            border: C.textfieldBorder,
                                            isDense: true, // Added this
                                            prefixText: "₹ ",
                                            helperStyle: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                            ),
                                            labelText: "3 BHK Price",
                                            labelStyle:
                                                TextStyle(fontSize: 13)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return priceValidator;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (sendingData == true)
                      CircularProgressIndicator()
                    else
                      Container(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 20),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFf9a825), // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                setState(() {
                                  sendingData = true;
                                });
                                postWithinCityData();
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )),
                  ],
                )
        ],
      ),
    );
  }
}
