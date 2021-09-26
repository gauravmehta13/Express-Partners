import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../Widgets/counter.dart';
import '../constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class CheckRevenue extends StatefulWidget {
  @override
  _CheckRevenueState createState() => _CheckRevenueState();
}

class _CheckRevenueState extends State<CheckRevenue> {
  bool outstation = false;
  double noOfLocalMovement = 0;
  double noOfOutstationMovement = 0;

  final _items = cities
      .map((extraItems) => MultiSelectItem<dynamic>(
            extraItems,
            extraItems,
          ))
      .toList();
  List<dynamic>? intercity = [];
  List<dynamic>? intracity = [];
  var isLoading = false;
  var loading = true;
  bool localShow = false;
  bool outstationShow = false;
  final formatCurrency =
      new NumberFormat.simpleCurrency(name: "", decimalDigits: 0);
  String? selectedPlace;
  bool priceCalculated = false;
  bool price = false;
  bool estimatorLoading = false;
  String? earnings;
  String? revenue;
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    getProgress();
  }

  getProgress() async {
    try {
      final response = await dio.get(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?tenantSet_id=PAM01&tenantUsecase=pam&type=packersAndMoversSP&id=${_auth.currentUser!.uid}',
      );
      Map<String, dynamic> map = json.decode(response.toString());
      print(map["resp"]);
      setState(() {
        intercity = map["resp"][0]["localCities"];
        intracity = map["resp"][0]["outstationCities"];
      });
      print(intercity);
      setState(() {
        loading = false;
      });
    } catch (e) {}
  }

  getEarnings() async {
    List intra = [];
    List inter = [];
    for (var i = 0; i < intracity!.length; i++) {
      intra.add({"city": intracity![i]});
    }

    for (var i = 0; i < intercity!.length; i++) {
      inter.add({"city": intercity![i]});
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
        displaySnackBar("Earnings Unavailable for this selection", context);
      }
      estimatorLoading = false;
      postData();
    });
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
          });
      print(response);
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "GoFlexe",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
          : SingleChildScrollView(
              child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  initialValue: intracity,
                                  buttonText: Text(
                                    "Select Cities where you locally Transport",
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  title: Text("Cities you Serve"),
                                  items: _items,
                                  onSelectionChanged: (values) {
                                    setState(() {
                                      intracity = values;
                                      localShow = true;
                                    });
                                  },
                                  onConfirm: (values) {
                                    setState(() {
                                      intracity = values;
                                      localShow = true;
                                    });
                                  },
                                  chipDisplay: MultiSelectChipDisplay(
                                    onTap: (dynamic value) {
                                      setState(() {
                                        intracity!.remove(value);
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
                                  initialValue: intercity,
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
                                        intercity!.remove(value);
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
                                                initialValue: noOfLocalMovement,
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
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600),
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
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                if (earnings != null)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFc1f0dc),
                                                borderRadius:
                                                    BorderRadius.circular(5),
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
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF2f7769),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFc1f0dc),
                                                borderRadius:
                                                    BorderRadius.circular(5),
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
                                                        ? "₹ ${formatCurrency.format(int.parse(revenue ?? 0 as String))} per annum"
                                                        : "",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF2f7769),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600),
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
                                      primary: Color(0xFFf9a825), // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: () async {
                                      getEarnings();
                                    },
                                    child: Text(
                                      "Calculate Earnings",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
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
                ],
              ),
            )),
    );
  }
}
