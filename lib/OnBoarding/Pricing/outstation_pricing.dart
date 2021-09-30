import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class OutStationPricing extends StatefulWidget {
  final data;
  final ValueChanged<int>? update;
  OutStationPricing({this.update, this.data});
  @override
  _OutStationPricingState createState() => _OutStationPricingState();
}

class _OutStationPricingState extends State<OutStationPricing> {
  final formKey = GlobalKey<FormState>();
  bool loading = true;
  bool allPriceAdded = false;
  var dio = Dio();
  bool sendingData = false;

  @override
  void initState() {
    super.initState();
  }

  postOutstationPricing() async {
    Map<String, dynamic> data = {
      // "outStationPricing": {
      //   "1bhk": one.text,
      //   "2bhk": two.text,
      //   "3bhk": three.text,
      // },
    };
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var database = await firebaseFirestore
        .collection("vendors")
        .doc(_auth.currentUser!.uid)
        .update(data)
        .then((value) => widget.update!(2))
        .onError((error, stackTrace) {
      displaySnackBar("error, please try again later", context);
    
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
          child: Column(children: [
        SizedBox(
          height: 10,
        ),
        SizedBox(height: 70, child: Image.asset("assets/outstation.png")),
        SizedBox(
          height: 10,
        ),
        Text(
          "OutStation Pricing",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        Text(
          allPriceAdded
              ? "We have assisted in calculating the automated prices. Please confirm or edit the prices."
              : "Add pricing for a single route and we will assist in calculating the prices for remaining routes.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 20,
        ),
        loading
            ? Container(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text("price per 500km ")
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: cityPrice["oneBHKprice"],
                                  onChanged: (e) {
                                    cityPrice["oneBHKprice"] = e;
                                    print(basePrices);
                                  },
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF3f51b5)),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: C.textfieldBorder,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    prefixText: "₹ ",
                                    labelText: "1 BHK Price",
                                    isDense: true,
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: cityPrice["twoBHKprice"],
                                  onChanged: (e) {
                                    cityPrice["twoBHKprice"] = e;
                                    print(basePrices);
                                  },
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF3f51b5)),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: C.textfieldBorder,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    prefixText: "₹ ",
                                    labelText: "2 BHK Price",
                                    labelStyle: TextStyle(color: Colors.black),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: cityPrice["threeBHKprice"],
                                  onChanged: (e) {
                                    cityPrice["threeBHKprice"] = e;
                                    print(basePrices);
                                  },
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF3f51b5)),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: C.textfieldBorder,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    prefixText: "₹ ",
                                    labelText: "3 BHK Price",
                                    labelStyle: TextStyle(color: Colors.black),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        ],
                      ),
                    ),
                    C.box20,
                    sendingData
                        ? Center(child: CircularProgressIndicator())
                        : Container(
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
                                  postOutstationPricing();
                                },
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            )),
                  ],
                ),
              )
      ])),
    );
  }
}
