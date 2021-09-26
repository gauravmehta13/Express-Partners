import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  TextEditingController one = new TextEditingController();
  TextEditingController two = new TextEditingController();
  TextEditingController three = new TextEditingController();
  List<TextEditingController> withinoneBhkPrice = [];
  List<TextEditingController> withintwoBhkPrice = [];
  List<TextEditingController> withinthreeBhkPrice = [];
  Map? priceTips;
  FocusNode? oneBHKNode;
  FocusNode? twoBHKNode;
  FocusNode? threeBHKNode;
  bool priceChanged = false;

  @override
  void initState() {
    super.initState();
    getProgress();
    getFocusNodes();
    logEvent("Within_City_Pricing");
  }

  getProgress() async {
    try {
      // final response = await dio.get(
      //     'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser.uid}');

      // Map<String, dynamic> map = json.decode(response.toString());
      if (widget.data['resp']['Items'] != null) {
        if (widget.data['resp']['Items'][0]['intracity'].length != 0) {
          withinCity = widget.data['resp']['Items'][0]['intracity']["cities"];
          for (var i = 0; i < withinCity!.length; i++) {
            withinoneBhkPrice.add(TextEditingController());
            withintwoBhkPrice.add(TextEditingController());
            withinthreeBhkPrice.add(TextEditingController());
          }
          for (var i = 0; i < withinCity!.length; i++) {
            withinoneBhkPrice[i].text =
                withinCity![i]['oneBHKprice'].toString();
            withintwoBhkPrice[i].text =
                withinCity![i]['twoBHKprice'].toString();
            withinthreeBhkPrice[i].text =
                withinCity![i]['threeBHKprice'].toString();
          }
          setState(() {
            allPriceAdded = true;
            loading = false;
          });
          pricesCalculated(context);
        } else {
          await getPriceTips();
          setState(() {
            loading = false;
          });
        }
        print(widget.data['resp']['Items'][0]['intracity']);
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    oneBHKNode!.dispose();
    twoBHKNode!.dispose();
    threeBHKNode!.dispose();
    super.dispose();
  }

  getPriceTips() async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
          data: {
            "tenantSet_id": "PAM01",
            "tenantUsecase": "pam",
            "useCase": "tip",
            "type": "intracity",
          });
      print(response);
      Map<String, dynamic> map = json.decode(response.toString());
      print(map);
      print(map["resp"].length);

      for (var i = 0; i < map["resp"].length; i++) {
        if (map["resp"][i]["city"] == "Banglore") {
          setState(() {
            priceTips = map["resp"][i];
          });
        }
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  postWithinCityData() async {
    try {
      // if (priceChanged) {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
          data: {
            "serviceProviderId": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "intracity": {"cities": withinCity, "completed": "true"}
          });
      print(response);
      print(response.statusCode);
      //  }
      logEvent('Filled_Intracity_Pricing');
      setState(() {
        widget.update!(1);
        allPriceAdded = true;
        sendingData = false;
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

  getOtherPrices() async {
    final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
        data: {
          "tenantSet_id": "PAM01",
          "tenantUsecase": "pam",
          "useCase": "suggestion",
          "type": "intracity",
          "city": "Banglore",
          "oneBHKprice": one.text,
          "twoBHKprice": two.text,
          "threeBHKprice": three.text
        });

    Map<String, dynamic>? map = json.decode(response.toString());
    print(map);
    setState(() {
      withinCity = map!['resp'];
    });

    for (var i = 0; i < withinCity!.length; i++) {
      withinoneBhkPrice.add(TextEditingController());
      withintwoBhkPrice.add(TextEditingController());
      withinthreeBhkPrice.add(TextEditingController());
    }
    for (var i = 0; i < withinCity!.length; i++) {
      withinoneBhkPrice[i].text = withinCity![i]['oneBHKprice'].toString();
      withintwoBhkPrice[i].text = withinCity![i]['twoBHKprice'].toString();
      withinthreeBhkPrice[i].text = withinCity![i]['threeBHKprice'].toString();
    }

    setState(() {
      firstPriceAdded = true;
      showAllPrice = true;
      loading = false;
    });
    pricesCalculated(context);
  }

  bool showAllPrice = false;
  bool sendingData = false;
  bool firstPriceAdded = false;
  bool allPriceAdded = false;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 70, child: Image.asset("assets/within.png")),
            SizedBox(
              height: 10,
            ),
            Text(
              "Within City Pricing",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              allPriceAdded
                  ? "We have assisted in calculating the automated prices. Please confirm or edit the prices."
                  : "Add pricing for a single city and we will assist in calculating the rest of the prices.",
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
                : !allPriceAdded
                    ? Column(
                        children: [
                          ItemList(),
                          C.box20,
                          if (showAllPrice == false)
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    width: double.infinity,
                                    color: priceBarColor,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "City",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "Banglore",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
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
                                              child: new TextFormField(
                                                textInputAction:
                                                    TextInputAction.next,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF3f51b5)),
                                                controller: one,
                                                focusNode: oneBHKNode,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: new InputDecoration(
                                                    border: C.textfieldBorder,
                                                    isDense: true, // Added this
                                                    prefixText: "₹ ",
                                                    labelText: "1 BHK Price",
                                                    helperText: priceTips !=
                                                            null
                                                        ? "Tip : Rs. ${priceTips!["oneBHKTip"]}"
                                                        : "Tip : Not Available",
                                                    helperStyle: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.green,
                                                    ),
                                                    helperMaxLines: 2,
                                                    labelStyle: TextStyle(
                                                        fontSize: 13)),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
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
                                              child: new TextFormField(
                                                focusNode: twoBHKNode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF3f51b5)),
                                                controller: two,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: new InputDecoration(
                                                    border: C.textfieldBorder,
                                                    isDense: true, // Added this
                                                    prefixText: "₹ ",
                                                    helperText: priceTips !=
                                                            null
                                                        ? "Tip : Rs. ${priceTips!["twoBHKTip"]}"
                                                        : "Tip : Not Available",
                                                    helperStyle: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.green,
                                                    ),
                                                    labelText: "2 BHK Price",
                                                    labelStyle: TextStyle(
                                                        fontSize: 13)),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
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
                                              child: new TextFormField(
                                                focusNode: threeBHKNode,
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF3f51b5)),
                                                controller: three,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: new InputDecoration(
                                                    border: C.textfieldBorder,
                                                    isDense: true, // Added this
                                                    prefixText: "₹ ",
                                                    helperText: priceTips !=
                                                            null
                                                        ? "Tip : Rs. ${priceTips!["threeBHKTip"]}"
                                                        : "Tip : Not Available",
                                                    helperStyle: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.green,
                                                    ),
                                                    labelText: "3 BHK Price",
                                                    labelStyle: TextStyle(
                                                        fontSize: 13)),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
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
                          if (firstPriceAdded == false)
                            ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    getOtherPrices();
                                  }
                                },
                                child: Text("Calculate for Other Cities")),
                          if (showAllPrice == true)
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: withinCity!.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Container(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 5),
                                              width: double.infinity,
                                              color: priceBarColor,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "City",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${withinCity![index]['city']}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  if (index != 0)
                                                    if (withinCity![index]
                                                                ["percent"]
                                                            .toString() !=
                                                        "null")
                                                      Row(
                                                        children: [
                                                          withinCity![index][
                                                                      "increase"] ==
                                                                  true
                                                              ? Icon(
                                                                  Icons
                                                                      .arrow_upward,
                                                                  size: 12,
                                                                  color: Colors
                                                                      .green)
                                                              : Icon(
                                                                  Icons
                                                                      .arrow_downward,
                                                                  size: 12,
                                                                  color: Colors
                                                                      .red),
                                                          Text(
                                                            "${withinCity![index]["percent"].toString()} %",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: withinCity![index]
                                                                            [
                                                                            "increase"] ==
                                                                        true
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          )
                                                        ],
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
                                                        child: TextFormField(
                                                          controller:
                                                              withinoneBhkPrice[
                                                                  index],
                                                          onChanged: (e) {
                                                            setState(() {
                                                              withinCity![index]
                                                                  [
                                                                  'oneBHKprice'] = e;
                                                            });
                                                            print(withinCity![
                                                                    index][
                                                                'oneBHKprice']);
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
                                                            prefixText: "₹ ",
                                                            labelText:
                                                                "1 BHK Price",
                                                            isDense: true,
                                                            labelStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                          onChanged: (e) {
                                                            setState(() {
                                                              withinCity![index]
                                                                  [
                                                                  'twoBHKprice'] = e;
                                                            });
                                                            print(withinCity![
                                                                    index][
                                                                'twoBHKprice']);
                                                          },
                                                          controller:
                                                              withintwoBhkPrice[
                                                                  index],
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
                                                            prefixText: "₹ ",
                                                            labelText:
                                                                "2 BHK Price",
                                                            labelStyle:
                                                                TextStyle(
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
                                                        child: TextFormField(
                                                          onChanged: (e) {
                                                            setState(() {
                                                              withinCity![index]
                                                                  [
                                                                  'threeBHKprice'] = e;
                                                            });
                                                            print(withinCity![
                                                                    index][
                                                                'threeBHKprice']);
                                                          },
                                                          controller:
                                                              withinthreeBhkPrice[
                                                                  index],
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
                                                            prefixText: "₹ ",
                                                            labelText:
                                                                "3 BHK Price",
                                                            labelStyle:
                                                                TextStyle(
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
                                          ])),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            ),
                          if (showAllPrice == true)
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
                                        primary:
                                            Color(0xFFf9a825), // background
                                        onPrimary: Colors.white, // foreground
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          sendingData = true;
                                        });
                                        postWithinCityData();
                                      },
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )),
                          // ElevatedButton(
                          //     onPressed: () {
                          //       postWithinCityData();
                          //     },
                          //     child: priceConfirmText),
                        ],
                      )
                    : Column(
                        children: [
                          ItemList(),
                          C.box20,
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: withinCity!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: index == 0,
                                      collapsedBackgroundColor: priceBarColor,
                                      title: Container(
                                          child: Row(
                                        children: [
                                          Text(
                                            "${withinCity![index]['city']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Spacer(),
                                          if (index != 0)
                                            if (withinCity![index]["percent"]
                                                    .toString() !=
                                                "null")
                                              Row(
                                                children: [
                                                  withinCity![index]
                                                              ["increase"] ==
                                                          true
                                                      ? Icon(Icons.arrow_upward,
                                                          size: 12,
                                                          color: Colors.green)
                                                      : Icon(
                                                          Icons.arrow_downward,
                                                          size: 12,
                                                          color: Colors.red),
                                                  Text(
                                                    "${withinCity![index]["percent"].toString()} %",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: withinCity![
                                                                        index][
                                                                    "increase"] ==
                                                                true
                                                            ? Colors.green
                                                            : Colors.red),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  )
                                                ],
                                              ),
                                        ],
                                      )),
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  onChanged: (e) {
                                                    setState(() {
                                                      priceChanged = true;
                                                      withinCity![index]
                                                          ['oneBHKprice'] = e;
                                                    });
                                                    print(withinCity![index]
                                                        ['oneBHKprice']);
                                                  },
                                                  controller:
                                                      withinoneBhkPrice[index],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF3f51b5)),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: C.textfieldBorder,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    prefixText: "₹ ",
                                                    labelText: "1 BHK Price",
                                                    isDense: true,
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  onChanged: (e) {
                                                    setState(() {
                                                      priceChanged = true;
                                                      withinCity![index]
                                                          ['twoBHKprice'] = e;
                                                    });
                                                    print(withinCity![index]
                                                        ['twoBHKprice']);
                                                  },
                                                  controller:
                                                      withintwoBhkPrice[index],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF3f51b5)),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: C.textfieldBorder,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    prefixText: "₹ ",
                                                    labelText: "2 BHK Price",
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  onChanged: (e) {
                                                    setState(() {
                                                      priceChanged = true;
                                                      withinCity![index]
                                                          ['threeBHKprice'] = e;
                                                    });
                                                    print(withinCity![index]
                                                        ['threeBHKprice']);
                                                  },
                                                  controller:
                                                      withinthreeBhkPrice[
                                                          index],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF3f51b5)),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: C.textfieldBorder,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    prefixText: "₹ ",
                                                    labelText: "3 BHK Price",
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  box5,
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
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
                          // ElevatedButton(
                          //     onPressed: () {
                          //       postWithinCityData();
                          //     },
                          //     child: Text("Save")),
                        ],
                      )
          ],
        ),
      ),
    );
  }

  getFocusNodes() {
    oneBHKNode = FocusNode();
    twoBHKNode = FocusNode();
    threeBHKNode = FocusNode();
    oneBHKNode!.addListener(() {
      if (priceTips != null) if (!oneBHKNode!.hasFocus) {
        setState(() {
          if (int.parse(one.text) >=
                  (priceTips!["oneBHKTip"] + (0.5 * priceTips!["oneBHKTip"])) ||
              int.parse(one.text) <=
                  (priceTips!["oneBHKTip"] - (0.5 * priceTips!["oneBHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    twoBHKNode!.addListener(() {
      if (priceTips != null) if (!twoBHKNode!.hasFocus) {
        setState(() {
          if (int.parse(two.text) >=
                  (priceTips!["twoBHKTip"] + (0.5 * priceTips!["twoBHKTip"])) ||
              int.parse(two.text) <=
                  (priceTips!["twoBHKTip"] - (0.5 * priceTips!["twoBHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    threeBHKNode!.addListener(() {
      if (priceTips != null) if (!threeBHKNode!.hasFocus) {
        setState(() {
          if (int.parse(three.text) >=
                  (priceTips!["threeBHKTip"] +
                      (0.5 * priceTips!["threeBHKTip"])) ||
              int.parse(three.text) <=
                  (priceTips!["threeBHKTip"] -
                      (0.5 * priceTips!["threeBHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
  }
}
