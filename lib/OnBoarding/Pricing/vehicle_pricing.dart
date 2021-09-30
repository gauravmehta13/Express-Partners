import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class VehiclePricing extends StatefulWidget {
  final ValueChanged<int>? update;
  final data;
  VehiclePricing({this.update, this.data});
  @override
  _VehiclePricingState createState() => _VehiclePricingState();
}

class _VehiclePricingState extends State<VehiclePricing> {
  final formKey = GlobalKey<FormState>();
  List<dynamic> prices = [];
  List<dynamic> basePrices = [];
  bool loading = true;
  bool allPriceAdded = false;
  bool sendingData = false;
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getProgress();
    logEvent("Vehicle_Pricing");
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProgress() async {
    try {
      // final response = await dio.get(
      //     'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser.uid}');

      // Map<String, dynamic> map = json.decode(response.toString());
      print(widget.data['resp']['Items'][0]['vehicles']);
      if (widget.data['resp']['Items'] != null) {
        if (widget.data['resp']['Items'][0]['vehicles'].length != 0) {
          //  print(widget.data['resp']['Items'][0]['vehicles']['cities']);
          // setState(() {
          //   prices = widget.data['resp']['Items'][0]['vehicles']['cities'];
          //   prices.sort((a, b) => b['fromCity'].compareTo(a['fromCity']));
          // });
          var tempPrices = mapByKey("fromCity",
              widget.data['resp']['Items'][0]['vehicles']["cities"]);

          // for (var i = 0; i < tempPrices.length; i++) {
          //   if (baseLocation!.contains(tempPrices[i].keys.first)) {
          //     basePrices.add(tempPrices[i]);
          //   } else {
          //     prices.add(tempPrices[i]);
          //   }
          // }

          print(basePrices);

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

  postVehiclesData() async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
          data: {
            "serviceProviderId": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "vehicles": {"cities": revertPrices(), "completed": "true"}
          });
      print(response);
      print(response.statusCode);

      logEvent('Filled_Vehicle_Pricing');
      setState(() {
        allPriceAdded = true;
        sendingData = false;
        widget.update!(3);
      });
      displaySnackBar("Prices Added Successfully", context);
    } catch (e) {
      print(e);
      displaySnackBar("Error, Please Try again later", context);
      setState(() {
        sendingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
          key: _scaffoldKey,
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 70, child: Image.asset("assets/car.png")),
            SizedBox(
              height: 10,
            ),
            Text(
              "Vehicle Pricing",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              allPriceAdded
                  ? "We have assisted in calculating the automated prices. Please confirm or edit the prices."
                  : "Add pricing for a single route and we will assist in calculating the prices for remaining routes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600),
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
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                                itemCount: basePrices[a][
                                                        basePrices[a]
                                                            .keys
                                                            .first]
                                                    .length,
                                                itemBuilder: (context, b) {
                                                  var cityPrice = basePrices[a][
                                                      basePrices[a]
                                                          .keys
                                                          .first][b];
                                                  return Column(
                                                    children: [
                                                      Container(
                                                        color: priceBarColor,
                                                        padding: EdgeInsets
                                                            .symmetric(
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
                                                              cityPrice[
                                                                      'toCity'] ??
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
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Car movement cost"),
                                                              ],
                                                            ),
                                                            C.box10,
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "hatchBackPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "hatchBackPrice"] = e;
                                                                    print(cityPrice[
                                                                        "hatchBackPrice"]);
                                                                  },
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    labelText:
                                                                        "Hatchback Price",
                                                                    prefixText:
                                                                        "₹ ",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "sedanPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "sedanPrice"] = e;
                                                                    print(cityPrice[
                                                                        "sedanPrice"]);
                                                                  },
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "Sedan Price",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "SUVPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "SUVPrice"] = e;
                                                                    print(cityPrice[
                                                                        "SUVPrice"]);
                                                                  },
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "SUV Price",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Bike movement cost"),
                                                              ],
                                                            ),
                                                            C.box10,
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "hundredCCPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "hundredCCPrice"] = e;
                                                                    print(cityPrice[
                                                                        "hundredCCPrice"]);
                                                                  },
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    labelText:
                                                                        "Below 125cc",
                                                                    prefixText:
                                                                        "₹ ",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "oneTwentyFiveCCPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "oneTwentyFiveCCPrice"] = e;
                                                                    print(cityPrice[
                                                                        "oneTwentyFiveCCPrice"]);
                                                                  },
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "125-350cc",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                  initialValue:
                                                                      cityPrice[
                                                                          "fourHundredCCPrice"],
                                                                  onChanged:
                                                                      (e) {
                                                                    cityPrice[
                                                                        "fourHundredCCPrice"] = e;
                                                                    print(cityPrice[
                                                                        "fourHundredCCPrice"]);
                                                                  },
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF3f51b5),
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "Above 350cc",
                                                                    hintStyle: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                    isDense:
                                                                        true,
                                                                  ),
                                                                )),
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
                            collapsedBackgroundColor:
                                primaryColor.withOpacity(0.1),
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
                                                            cityPrice[
                                                                    'toCity'] ??
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 10),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "Car movement cost"),
                                                            ],
                                                          ),
                                                          C.box10,
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "hatchBackPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "hatchBackPrice"] = e;
                                                                  print(cityPrice[
                                                                      "hatchBackPrice"]);
                                                                },
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  labelText:
                                                                      "Hatchback Price",
                                                                  prefixText:
                                                                      "₹ ",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "sedanPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "sedanPrice"] = e;
                                                                  print(cityPrice[
                                                                      "sedanPrice"]);
                                                                },
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "Sedan Price",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                initialValue:
                                                                    cityPrice[
                                                                        "SUVPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "SUVPrice"] = e;
                                                                  print(cityPrice[
                                                                      "SUVPrice"]);
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "SUV Price",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "Bike movement cost"),
                                                            ],
                                                          ),
                                                          C.box10,
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                initialValue:
                                                                    cityPrice[
                                                                        "hundredCCPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "hundredCCPrice"] = e;
                                                                  print(cityPrice[
                                                                      "hundredCCPrice"]);
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  labelText:
                                                                      "Below 125cc",
                                                                  prefixText:
                                                                      "₹ ",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "oneTwentyFiveCCPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "oneTwentyFiveCCPrice"] = e;
                                                                  print(cityPrice[
                                                                      "oneTwentyFiveCCPrice"]);
                                                                },
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "125-350cc",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      TextFormField(
                                                                initialValue:
                                                                    cityPrice[
                                                                        "fourHundredCCPrice"],
                                                                onChanged: (e) {
                                                                  cityPrice[
                                                                      "fourHundredCCPrice"] = e;
                                                                  print(cityPrice[
                                                                      "fourHundredCCPrice"]);
                                                                },
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF3f51b5),
                                                                ),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: C
                                                                      .textfieldBorder,
                                                                  prefixText:
                                                                      "₹ ",
                                                                  labelText:
                                                                      "Above 350cc",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              10),
                                                                  isDense: true,
                                                                ),
                                                              )),
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
                                      postVehiclesData();
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
