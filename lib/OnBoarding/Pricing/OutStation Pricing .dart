import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Constants.dart';

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
  List<dynamic> prices = [];
  List<dynamic> basePrices = [];

  @override
  void initState() {
    super.initState();
    getProgress();
    logEvent("OutStation_Pricing");
  }

  getProgress() async {
    try {
      // final response = await dio.get(
      //     'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser.uid}');

      // Map<String, dynamic> map = json.decode(response.toString());
      if (widget.data['resp']['Items'] != null) {
        if (widget.data['resp']['Items'][0]['intercity'].length != 0 &&
            widget.data['resp']['Items'][0]['intercity'] != null) {
          var tempPrices = mapByKey("fromCity",
              widget.data['resp']['Items'][0]['intercity']["cities"]);

          for (var i = 0; i < tempPrices.length; i++) {
            if (baseLocation!.contains(tempPrices[i].keys.first)) {
              basePrices.add(tempPrices[i]);
            } else {
              prices.add(tempPrices[i]);
            }
          }
          //  prices.sort((a, b) => b['fromCity'].compareTo(a['fromCity']));

          setState(() {
            allPriceAdded = true;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  revertPrices() {
    List allPrices = [];
    // ?reverting the list
    for (var i = 0; i < basePrices.length; i++) {
      for (var j = 0; j < basePrices[i][basePrices[i].keys.first].length; j++) {
        allPrices.add(basePrices[i][basePrices[i].keys.first][j]);
      }
    }
    for (var i = 0; i < prices.length; i++) {
      for (var j = 0; j < prices[i][prices[i].keys.first].length; j++) {
        allPrices.add(prices[i][prices[i].keys.first][j]);
      }
    }
    return allPrices;
  }

  postOutstationPricing() async {
    logEvent('Filled_Intercity_Pricing');
    print(revertPrices());
    try {
      // if (priceChanged) {
      final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
        data: {
          "serviceProviderId": _auth.currentUser!.uid,
          "mobile": _auth.currentUser!.phoneNumber,
          "tenantUsecase": "pam",
          "tenantSet_id": "PAM01",
          "intercity": {"cities": revertPrices(), "completed": "true"}
        },
      );
      logEvent('Filled_Intercity_Pricing');
      print(response);
      print(response.statusCode);

      setState(() {
        allPriceAdded = true;
        sendingData = false;
        widget.update!(2);
      });
      displaySnackBar("Prices Added Successfully", context);
    } catch (e) {
      print(e);
      setState(() {
        sendingData = false;
      });
      displaySnackBar("Error, Please Try again later", context);
    }
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
                    Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ExpansionTile(
                          initiallyExpanded: true,
                          backgroundColor: priceBarColor,
                          collapsedBackgroundColor: priceBarColor,
                          title: Text(
                            "Base Location",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: basePrices.length,
                              itemBuilder: (context, a) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: ExpansionTile(
                                      initiallyExpanded: a == 0,
                                      collapsedBackgroundColor:
                                          primaryColor.withOpacity(0.05),
                                      title: Text(
                                        basePrices[a].keys.first,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      children: [
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: basePrices[a]
                                                    [basePrices[a].keys.first]
                                                .length,
                                            itemBuilder: (context, b) {
                                              var cityPrice = basePrices[a]
                                                  [basePrices[a].keys.first][b];
                                              return Column(
                                                children: [
                                                  Container(
                                                    color: priceBarColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(Icons
                                                            .arrow_forward_rounded),
                                                        C.wbox30,
                                                        Text(
                                                          cityPrice['toCity'] ??
                                                              "",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "oneBHKprice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "oneBHKprice"] = e;
                                                                  print(
                                                                      basePrices);
                                                                },
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5)),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "1 BHK Price",
                                                                  isDense: true,
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "twoBHKprice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "twoBHKprice"] = e;
                                                                  print(
                                                                      basePrices);
                                                                },
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5)),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "2 BHK Price",
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                  isDense: true,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "threeBHKprice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "threeBHKprice"] = e;
                                                                  print(
                                                                      basePrices);
                                                                },
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5)),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "3 BHK Price",
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                  isDense: true,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            }),
                                      ]),
                                );
                              },
                            ),
                          ]),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ExpansionTile(
                        collapsedBackgroundColor: primaryColor.withOpacity(0.1),
                        backgroundColor: primaryColor.withOpacity(0.1),
                        title: Text(
                          "Other Cities",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: prices.length,
                            itemBuilder: (context, a) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ExpansionTile(
                                    collapsedBackgroundColor:
                                        primaryColor.withOpacity(0.05),
                                    title: Text(
                                      prices[a].keys.first,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    children: [
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: prices[a]
                                                  [prices[a].keys.first]
                                              .length,
                                          itemBuilder: (context, b) {
                                            var cityPrice = prices[a]
                                                [prices[a].keys.first][b];
                                            return Column(
                                              children: [
                                                Container(
                                                  color: priceBarColor,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons
                                                          .arrow_forward_rounded),
                                                      C.wbox30,
                                                      Text(
                                                        cityPrice['toCity'] ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  cityPrice[
                                                                      "oneBHKprice"],
                                                              onChanged: (e) {
                                                                cityPrice[
                                                                    "oneBHKprice"] = e;
                                                                print(prices);
                                                              },
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5)),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .always,
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "1 BHK Price",
                                                                isDense: true,
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  cityPrice[
                                                                      "twoBHKprice"],
                                                              onChanged: (e) {
                                                                cityPrice[
                                                                    "twoBHKprice"] = e;
                                                                print(prices);
                                                              },
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5)),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .always,
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "2 BHK Price",
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                isDense: true,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  cityPrice[
                                                                      "threeBHKprice"],
                                                              onChanged: (e) {
                                                                cityPrice[
                                                                    "threeBHKprice"] = e;
                                                                print(prices);
                                                              },
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5)),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .always,
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "3 BHK Price",
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                isDense: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            );
                                          }),
                                    ]),
                              );
                            },
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
