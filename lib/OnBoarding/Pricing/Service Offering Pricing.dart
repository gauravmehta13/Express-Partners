import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Constants.dart';
import '../../Fade Route.dart';
import '../../Screens/BottomNavBar.dart';
import '../Availability.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ServiceOfferingPricing extends StatefulWidget {
  final data;
  final old;
  final ValueChanged<int>? update;
  ServiceOfferingPricing({this.update, this.old, this.data});
  @override
  _ServiceOfferingPricingState createState() => _ServiceOfferingPricingState();
}

class _ServiceOfferingPricingState extends State<ServiceOfferingPricing> {
  final formKey = GlobalKey<FormState>();
  var dio = Dio();
  List<dynamic>? prices;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController insuranceController = new TextEditingController();
  TextEditingController oneBHKwarehouse = new TextEditingController();
  TextEditingController twoBHKwarehouse = new TextEditingController();
  TextEditingController threeBHKwarehouse = new TextEditingController();
  TextEditingController oneBHKPremiumPackaging = new TextEditingController();
  TextEditingController twoBHKPremiumPackaging = new TextEditingController();
  TextEditingController threeBHKPremiumPackaging = new TextEditingController();
  TextEditingController oneBHKLift = new TextEditingController();
  TextEditingController twoBHKLift = new TextEditingController();
  TextEditingController threeBHKLift = new TextEditingController();
  TextEditingController oneBHKUnpacking = new TextEditingController();
  TextEditingController twoBHKUnpacking = new TextEditingController();
  TextEditingController threeBHKUnpacking = new TextEditingController();
  List<TextEditingController> oneBHKwarehouseList = [];
  List<TextEditingController> twoBHKwarehouseList = [];
  List<TextEditingController> threeBHKwarehouseList = [];
  List<TextEditingController> oneBHKPremiumPackagingList = [];
  List<TextEditingController> twoBHKPremiumPackagingList = [];
  List<TextEditingController> threeBHKPremiumPackagingList = [];
  List<TextEditingController> oneBHKLiftList = [];
  List<TextEditingController> twoBHKLiftList = [];
  List<TextEditingController> threeBHKLiftList = [];
  List<TextEditingController> oneBHKUnpackingList = [];
  List<TextEditingController> twoBHKUnpackingList = [];
  List<TextEditingController> threeBHKUnpackingList = [];
  FocusNode? warehouse1BHK;
  FocusNode? warehouse2BHK;
  FocusNode? warehouse3BHK;
  FocusNode? unpacking1BHK;
  FocusNode? unpacking2BHK;
  FocusNode? unpacking3BHK;
  FocusNode? premium1BHK;
  FocusNode? premium2BHK;
  FocusNode? premium3BHK;
  FocusNode? lift1BHK;
  FocusNode? lift2BHK;
  FocusNode? lift3BHK;

  @override
  void initState() {
    super.initState();
    getProgress();
    getFocusNodes();
    logEvent("Offerings_Pricing");
  }

  bool sendingData = false;
  bool loading = true;
  bool allPriceAdded = false;
  bool showAllPrice = false;
  bool firstPriceAdded = false;
  String location = "";
  bool? warehouse = false;
  bool? freeStorage = true;
  bool additionalChargesSelection = false;
  bool? premiumPackaging = false;
  bool? unpacking = false;
  bool? insurance = false;
  Map? priceTips;
  bool priceChanged = false;

  getProgress() async {
    try {
      // final response = await dio.get(
      //     'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser.uid}');

      // Map<String, dynamic> map = json.decode(response.toString());
      print(widget.data['resp']['Items'][0]['offerings']);
      if (widget.data['resp']['Items'] != null) {
        if (widget.data['resp']['Items'][0]['offerings'].length != 0) {
          setState(() {
            prices = widget.data['resp']['Items'][0]['offerings']["cities"];
          });
          if (widget.data['resp']['Items'][0]['offerings']["insurance"] !=
              null) {
            setState(() {
              insuranceController.text =
                  widget.data['resp']['Items'][0]['offerings']["insurance"];
              insurance = true;
            });
          }

          for (var i = 0; i < prices!.length; i++) {
            oneBHKwarehouseList.add(TextEditingController());
            oneBHKLiftList.add(TextEditingController());
            oneBHKPremiumPackagingList.add(TextEditingController());
            oneBHKUnpackingList.add(TextEditingController());
            twoBHKwarehouseList.add(TextEditingController());
            twoBHKLiftList.add(TextEditingController());
            twoBHKPremiumPackagingList.add(TextEditingController());
            twoBHKUnpackingList.add(TextEditingController());
            threeBHKwarehouseList.add(TextEditingController());
            threeBHKLiftList.add(TextEditingController());
            threeBHKPremiumPackagingList.add(TextEditingController());
            threeBHKUnpackingList.add(TextEditingController());
          }
          for (var i = 0; i < prices!.length; i++) {
            oneBHKwarehouseList[i].text =
                prices![i]["warehouse1BHK"].toString();
            oneBHKPremiumPackagingList[i].text =
                prices![i]["premium1BHK"].toString();
            oneBHKUnpackingList[i].text =
                prices![i]["unpacking1BHK"].toString();
            oneBHKLiftList[i].text = prices![i]["lift1BHK"].toString();
            twoBHKwarehouseList[i].text =
                prices![i]["warehouse2BHK"].toString();
            twoBHKPremiumPackagingList[i].text =
                prices![i]["premium2BHK"].toString();
            twoBHKUnpackingList[i].text =
                prices![i]["unpacking2BHK"].toString();
            twoBHKLiftList[i].text = prices![i]["lift2BHK"].toString();
            threeBHKwarehouseList[i].text =
                prices![i]["warehouse3BHK"].toString();
            threeBHKPremiumPackagingList[i].text =
                prices![i]["premium3BHK"].toString();
            threeBHKUnpackingList[i].text =
                prices![i]["unpacking3BHK"].toString();
            threeBHKLiftList[i].text = prices![i]["lift3BHK"].toString();
          }

          setState(() {
            allPriceAdded = true;
            loading = false;
          });
        } else {
          await getPriceTips();
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

  getPriceTips() async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
          data: {
            "tenantSet_id": "PAM01",
            "tenantUsecase": "pam",
            "useCase": "tip",
            "type": "offerings",
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
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  postOfferingsData() async {
    try {
      // if (priceChanged) {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
          data: {
            "serviceProviderId": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "offerings": {
              "cities": prices,
              "warehouse": warehouse,
              "free15DaysStorage": !warehouse! ? false : freeStorage,
              "premiumPackaging": premiumPackaging,
              "unpacking": unpacking,
              "insuranceSelected": insurance,
              "insurance": insuranceController.text,
              "completed": "true"
            }
          });
      print(response);
      print(response.statusCode);
      // }
      logEvent('Filled_Offerings_Pricing');

      displaySnackBar("Prices Added Successfully", context);
      setState(() {
        allPriceAdded = true;
        sendingData = false;
      });

      if (widget.old != null) {
        Navigator.push(
          context,
          FadeRoute(page: BottomNavScreen()),
        );
      } else {
        Navigator.push(
          context,
          FadeRoute(page: Availability()),
        );
      }
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
          "type": "offerings",
          "city": "Banglore",
          "warehouse1BHK": oneBHKwarehouse.text,
          "warehouse2BHK": twoBHKwarehouse.text,
          "warehouse3BHK": threeBHKwarehouse.text,
          "lift1BHK": oneBHKLift.text,
          "premium1BHK": oneBHKPremiumPackaging.text,
          "unpacking1BHK": oneBHKUnpacking.text,
          "lift2BHK": twoBHKLift.text,
          "premium2BHK": twoBHKPremiumPackaging.text,
          "unpacking2BHK": twoBHKUnpacking.text,
          "lift3BHK": threeBHKLift.text,
          "premium3BHK": threeBHKPremiumPackaging.text,
          "unpacking3BHK": threeBHKUnpacking.text,
        });

    Map<String, dynamic>? map = json.decode(response.toString());
    print(map);
    setState(() {
      prices = map!['resp'];
    });

    for (var i = 0; i < prices!.length; i++) {
      oneBHKwarehouseList.add(TextEditingController());
      oneBHKLiftList.add(TextEditingController());
      oneBHKPremiumPackagingList.add(TextEditingController());
      oneBHKUnpackingList.add(TextEditingController());
      twoBHKwarehouseList.add(TextEditingController());
      twoBHKLiftList.add(TextEditingController());
      twoBHKPremiumPackagingList.add(TextEditingController());
      twoBHKUnpackingList.add(TextEditingController());
      threeBHKwarehouseList.add(TextEditingController());
      threeBHKLiftList.add(TextEditingController());
      threeBHKPremiumPackagingList.add(TextEditingController());
      threeBHKUnpackingList.add(TextEditingController());
    }
    for (var i = 0; i < prices!.length; i++) {
      oneBHKwarehouseList[i].text = prices![i]["warehouse1BHK"].toString();
      oneBHKPremiumPackagingList[i].text = prices![i]["premium1BHK"].toString();
      oneBHKUnpackingList[i].text = prices![i]["unpacking1BHK"].toString();
      oneBHKLiftList[i].text = prices![i]["lift1BHK"].toString();
      twoBHKwarehouseList[i].text = prices![i]["warehouse2BHK"].toString();
      twoBHKPremiumPackagingList[i].text = prices![i]["premium2BHK"].toString();
      twoBHKUnpackingList[i].text = prices![i]["unpacking2BHK"].toString();
      twoBHKLiftList[i].text = prices![i]["lift2BHK"].toString();
      threeBHKwarehouseList[i].text = prices![i]["warehouse3BHK"].toString();
      threeBHKPremiumPackagingList[i].text =
          prices![i]["premium3BHK"].toString();
      threeBHKUnpackingList[i].text = prices![i]["unpacking3BHK"].toString();
      threeBHKLiftList[i].text = prices![i]["lift3BHK"].toString();
    }

    setState(() {
      firstPriceAdded = true;
      showAllPrice = true;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        key: _scaffoldKey,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 70, child: Image.asset("assets/money.png")),
            SizedBox(
              height: 10,
            ),
            Text(
              "Service offerings &  amenities",
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
              height: 10,
            ),
            if (loading == true)
              Container(
                child: CircularProgressIndicator(),
              ),
            if (loading == false)
              allPriceAdded == false
                  ? Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              if (firstPriceAdded == false)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    box20,
                                    Text(
                                      "Kindly select the services you provide",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    box20,
                                    CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.all(0),
                                      title: const Text(
                                        'Warehouse',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                          "Well protected , covered safe storage facilities for customer to store their goods, for a stipulated period before reaching the final destination."),
                                      autofocus: false,
                                      activeColor: Color(0xFF3f51b5),
                                      checkColor: Colors.white,
                                      selected: warehouse!,
                                      value: warehouse,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          warehouse = value;
                                        });
                                      },
                                    ),
                                    if (warehouse == true)
                                      CheckboxListTile(
                                        title: const Text(
                                          'Are you providing free 15 days storage for customers?',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        autofocus: false,
                                        activeColor: Color(0xFF3f51b5),
                                        checkColor: Colors.white,
                                        selected: freeStorage!,
                                        value: freeStorage,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            freeStorage = value;
                                          });
                                        },
                                      ),
                                    Divider(),
                                    CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.all(0),
                                      title: const Text(
                                        'Premium Packaging',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                          "Additional layer of high-quality packaging materials for all the house items."),
                                      autofocus: false,
                                      activeColor: Color(0xFF3f51b5),
                                      checkColor: Colors.white,
                                      selected: premiumPackaging!,
                                      value: premiumPackaging,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          premiumPackaging = value;
                                        });
                                      },
                                    ),
                                    Divider(),
                                    CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.all(0),
                                      title: const Text(
                                        'Unpacking',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                          "Complete unpacking of all goods to place each item back in the location as pointed out by the customer."),
                                      autofocus: false,
                                      activeColor: Color(0xFF3f51b5),
                                      checkColor: Colors.white,
                                      selected: unpacking!,
                                      value: unpacking,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          unpacking = value;
                                        });
                                      },
                                    ),
                                    Divider(),
                                    CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.all(0),
                                      title: const Text(
                                        'Insurance',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                          "Please enter insurance as percentage of total declared value of the goods."),
                                      autofocus: false,
                                      activeColor: Color(0xFF3f51b5),
                                      checkColor: Colors.white,
                                      selected: insurance!,
                                      value: insurance,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          insurance = value;
                                        });
                                      },
                                    ),
                                    box10,
                                    if (insurance == true)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: TextFormField(
                                          controller: insuranceController,
                                          textInputAction: TextInputAction.next,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3f51b5),
                                          ),
                                          keyboardType: TextInputType.number,
                                          decoration: new InputDecoration(
                                              // helperText: "Tip : Rs. 10000",
                                              helperStyle: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                              ),
                                              helperMaxLines: 2,
                                              border: C.textfieldBorder,
                                              isDense: true, // Added this
                                              suffixText: "%",
                                              labelText:
                                                  " Enter % of items value",
                                              labelStyle:
                                                  TextStyle(fontSize: 13)),
                                          validator: (value) {
                                            if ((value == null ||
                                                    value.isEmpty) &&
                                                (insurance == true)) {
                                              return priceValidator;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    Divider(),
                                  ],
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              if (firstPriceAdded == false)
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
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
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
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                box10,
                                                if (warehouse == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Warehousing Pricing (price per day):",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        "( Enter Price per day )",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      box10,
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  warehouse1BHK,
                                                              controller:
                                                                  oneBHKwarehouse,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["warehouse1BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (warehouse ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  warehouse2BHK,
                                                              controller:
                                                                  twoBHKwarehouse,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["warehouse2BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (warehouse ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  warehouse3BHK,
                                                              controller:
                                                                  threeBHKwarehouse,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["warehouse3BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (warehouse ==
                                                                        true)) {
                                                                  return priceValidator;
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                if (premiumPackaging == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Premium packaging Pricing :",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      box10,
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  premium1BHK,
                                                              controller:
                                                                  oneBHKPremiumPackaging,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["premium1BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (premiumPackaging ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  premium2BHK,
                                                              controller:
                                                                  twoBHKPremiumPackaging,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["premium2BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (premiumPackaging ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  premium3BHK,
                                                              controller:
                                                                  threeBHKPremiumPackaging,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["premium3BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (premiumPackaging ==
                                                                        true)) {
                                                                  return priceValidator;
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                if (unpacking == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Unpacking Pricing :",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        "( Enter cost of additional labour required.)",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  unpacking1BHK,
                                                              controller:
                                                                  oneBHKUnpacking,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["unpacking1BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (unpacking ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  unpacking2BHK,
                                                              controller:
                                                                  twoBHKUnpacking,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["unpacking2BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (unpacking ==
                                                                        true)) {
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
                                                            child:
                                                                new TextFormField(
                                                              focusNode:
                                                                  unpacking3BHK,
                                                              controller:
                                                                  threeBHKUnpacking,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      helperText: priceTips != null
                                                                          ? "Tip : Rs. ${priceTips!["unpacking3BHKTip"]}"
                                                                          : "Tip : Not Available",
                                                                      helperStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      helperMaxLines:
                                                                          2,
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true,
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                              validator:
                                                                  (value) {
                                                                if ((value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) &&
                                                                    (unpacking ==
                                                                        true)) {
                                                                  return priceValidator;
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                Text(
                                                  "Price where lift is not available (per floor):",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  "( Enter Price difference per floor where lift is not available.)",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                box10,
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: new TextFormField(
                                                        focusNode: lift1BHK,
                                                        controller: oneBHKLift,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                helperText: priceTips != null
                                                                    ? "Tip : Rs. ${priceTips!["lift1BHKTip"]}"
                                                                    : "Tip : Not Available",
                                                                helperStyle:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                helperMaxLines:
                                                                    2,
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "1 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
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
                                                        focusNode: lift2BHK,
                                                        controller: twoBHKLift,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                helperText: priceTips != null
                                                                    ? "Tip : Rs. ${priceTips!["lift2BHKTip"]}"
                                                                    : "Tip : Not Available",
                                                                helperStyle:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                helperMaxLines:
                                                                    2,
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "2 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
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
                                                        focusNode: lift3BHK,
                                                        controller:
                                                            threeBHKLift,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                helperText: priceTips != null
                                                                    ? "Tip : Rs. ${priceTips!["lift3BHKTip"]}"
                                                                    : "Tip : Not Available",
                                                                helperStyle:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                helperMaxLines:
                                                                    2,
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "3 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ]))
                                    ],
                                  ),
                                ),
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
                              child: Text("Calculate for other Cities")),
                        if (showAllPrice == true)
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: prices!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "City",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${prices![index]["city"]}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                if (index != 0)
                                                  Row(
                                                    children: [
                                                      prices![index][
                                                                  "increase"] ==
                                                              true
                                                          ? Icon(
                                                              Icons
                                                                  .arrow_upward,
                                                              size: 12,
                                                              color:
                                                                  Colors.green)
                                                          : Icon(
                                                              Icons
                                                                  .arrow_downward,
                                                              size: 12,
                                                              color:
                                                                  Colors.red),
                                                      Text(
                                                        "${prices![index]["percent"].toString()} %",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: prices![index]
                                                                        [
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
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (warehouse == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Warehousing Pricing :",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        "( Enter Price per day )",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      box10,
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'warehouse1BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'warehouse1BHK']);
                                                              },
                                                              controller:
                                                                  oneBHKwarehouseList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'warehouse2BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'warehouse2BHK']);
                                                              },
                                                              controller:
                                                                  twoBHKwarehouseList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'warehouse3BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'warehouse3BHK']);
                                                              },
                                                              controller:
                                                                  threeBHKwarehouseList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                if (premiumPackaging == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Premium packaging Pricing :",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      box10,
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'premium1BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'premium1BHK']);
                                                              },
                                                              controller:
                                                                  oneBHKPremiumPackagingList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'premium2BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'premium2BHK']);
                                                              },
                                                              controller:
                                                                  twoBHKPremiumPackagingList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'premium3BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'premium3BHK']);
                                                              },
                                                              controller:
                                                                  threeBHKPremiumPackagingList[
                                                                      index],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                if (unpacking == true)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Unpacking Pricing :",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      box10,
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'unpacking1BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'unpacking1BHK']);
                                                              },
                                                              controller:
                                                                  oneBHKUnpackingList[
                                                                      index],
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "1 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'unpacking2BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'unpacking2BHK']);
                                                              },
                                                              controller:
                                                                  twoBHKUnpackingList[
                                                                      index],
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "2 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                new TextFormField(
                                                              onChanged: (e) {
                                                                setState(() {
                                                                  prices![index]
                                                                      [
                                                                      'unpacking3BHK'] = e;
                                                                });
                                                                print(prices![
                                                                        index][
                                                                    'unpacking3BHK']);
                                                              },
                                                              controller:
                                                                  threeBHKUnpackingList[
                                                                      index],
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF3f51b5),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  new InputDecoration(
                                                                      border: C
                                                                          .textfieldBorder,
                                                                      isDense:
                                                                          true, // Added this
                                                                      prefixText:
                                                                          "₹ ",
                                                                      labelText:
                                                                          "3 BHK Price",
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontSize: 13)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                Text(
                                                  "Lift Pricing :",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  "( Enter Price difference per floor where lift is not available. )",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: new TextFormField(
                                                        onChanged: (e) {
                                                          setState(() {
                                                            prices![index][
                                                                'lift1BHK'] = e;
                                                          });
                                                          print(prices![index]
                                                              ['lift1BHK']);
                                                        },
                                                        controller:
                                                            oneBHKLiftList[
                                                                index],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "1 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: new TextFormField(
                                                        onChanged: (e) {
                                                          setState(() {
                                                            prices![index][
                                                                'lift2BHK'] = e;
                                                          });
                                                          print(prices![index]
                                                              ['lift2BHK']);
                                                        },
                                                        controller:
                                                            twoBHKLiftList[
                                                                index],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "2 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: new TextFormField(
                                                        onChanged: (e) {
                                                          setState(() {
                                                            prices![index][
                                                                'lift3BHK'] = e;
                                                          });
                                                          print(prices![index]
                                                              ['lift3BHK']);
                                                        },
                                                        controller:
                                                            threeBHKLiftList[
                                                                index],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xFF3f51b5),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            new InputDecoration(
                                                                border: C
                                                                    .textfieldBorder,
                                                                isDense:
                                                                    true, // Added this
                                                                prefixText:
                                                                    "₹ ",
                                                                labelText:
                                                                    "3 BHK Price",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          C.box10
                                        ]),
                                  ),
                                  C.box10
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
                                      primary: Color(0xFFf9a825), // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        sendingData = true;
                                      });
                                      postOfferingsData();
                                    },
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )),
                      ],
                    )
                  : Container(
                      child: Column(
                        children: [
                          box20,
                          Text(
                            "Kindly select the services you provide",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          box10,
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                            title: const Text(
                              'Warehouse',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                "Well protected , covered safe storage facilities for customer to store their goods, for a stipulated period before reaching the final destination."),
                            autofocus: false,
                            activeColor: Color(0xFF3f51b5),
                            checkColor: Colors.white,
                            selected: warehouse!,
                            value: warehouse,
                            onChanged: (bool? value) {
                              setState(() {
                                priceChanged = true;
                                warehouse = value;
                              });
                            },
                          ),
                          if (warehouse == true)
                            CheckboxListTile(
                              title: const Text(
                                'Are you providing free 15 days storage for customers?',
                                style: TextStyle(fontSize: 12),
                              ),
                              autofocus: false,
                              activeColor: Color(0xFF3f51b5),
                              checkColor: Colors.white,
                              selected: freeStorage!,
                              value: freeStorage,
                              onChanged: (bool? value) {
                                setState(() {
                                  priceChanged = true;
                                  freeStorage = value;
                                });
                              },
                            ),
                          Divider(),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                            title: const Text(
                              'Premium Packaging',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                "Additional layer of high-quality packaging materials for all the house items."),
                            autofocus: false,
                            activeColor: Color(0xFF3f51b5),
                            checkColor: Colors.white,
                            selected: premiumPackaging!,
                            value: premiumPackaging,
                            onChanged: (bool? value) {
                              setState(() {
                                priceChanged = true;
                                premiumPackaging = value;
                              });
                            },
                          ),
                          Divider(),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                            title: const Text(
                              'Unpacking',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                "Complete unpacking of all goods to place each item back in the location as pointed out by the customer."),
                            autofocus: false,
                            activeColor: Color(0xFF3f51b5),
                            checkColor: Colors.white,
                            selected: unpacking!,
                            value: unpacking,
                            onChanged: (bool? value) {
                              setState(() {
                                priceChanged = true;
                                unpacking = value;
                              });
                            },
                          ),
                          Divider(),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(0),
                            title: const Text(
                              'Insurance',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                "Please enter insurance as percentage of total declared value of the goods."),
                            autofocus: false,
                            activeColor: Color(0xFF3f51b5),
                            checkColor: Colors.white,
                            selected: insurance!,
                            value: insurance,
                            onChanged: (bool? value) {
                              setState(() {
                                priceChanged = true;
                                insurance = value;
                              });
                            },
                          ),
                          box10,
                          if (insurance == true)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: TextFormField(
                                controller: insuranceController,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3f51b5),
                                ),
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    // helperText: "Tip : Rs. 10000",
                                    helperStyle: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                    helperMaxLines: 2,
                                    border: C.textfieldBorder,
                                    isDense: true, // Added this
                                    suffixText: "%",
                                    labelText: " Enter % of items value",
                                    labelStyle: TextStyle(fontSize: 13)),
                                validator: (value) {
                                  if ((value == null || value.isEmpty) &&
                                      (insurance == true)) {
                                    return priceValidator;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          Divider(),
                          box10,
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: prices!.length,
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
                                      collapsedBackgroundColor: priceBarColor,
                                      title: Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              "${prices![index]["city"]}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Spacer(),
                                            if (index != 0)
                                              if (prices![index]["percent"]
                                                      .toString() !=
                                                  "null")
                                                Row(
                                                  children: [
                                                    prices![index]
                                                                ["increase"] ==
                                                            true
                                                        ? Icon(
                                                            Icons.arrow_upward,
                                                            size: 12,
                                                            color: Colors.green)
                                                        : Icon(
                                                            Icons
                                                                .arrow_downward,
                                                            size: 12,
                                                            color: Colors.red),
                                                    Text(
                                                      "${prices![index]["percent"].toString()} %",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: prices![index][
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
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (warehouse == true)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Warehousing Pricing :",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                      "( Enter Price per day )",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    box10,
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'warehouse1BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'warehouse1BHK']);
                                                            },
                                                            controller:
                                                                oneBHKwarehouseList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "1 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'warehouse2BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'warehouse2BHK']);
                                                            },
                                                            controller:
                                                                twoBHKwarehouseList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "2 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'warehouse3BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'warehouse3BHK']);
                                                            },
                                                            controller:
                                                                threeBHKwarehouseList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "3 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              if (premiumPackaging == true)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Premium packaging Pricing :",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    box10,
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'premium1BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'premium1BHK']);
                                                            },
                                                            controller:
                                                                oneBHKPremiumPackagingList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "1 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'premium2BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'premium2BHK']);
                                                            },
                                                            controller:
                                                                twoBHKPremiumPackagingList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "2 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'premium3BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'premium3BHK']);
                                                            },
                                                            controller:
                                                                threeBHKPremiumPackagingList[
                                                                    index],
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "3 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              if (unpacking == true)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Unpacking Pricing :",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    box10,
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'unpacking1BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'unpacking1BHK']);
                                                            },
                                                            controller:
                                                                oneBHKUnpackingList[
                                                                    index],
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "1 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'unpacking2BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'unpacking2BHK']);
                                                            },
                                                            controller:
                                                                twoBHKUnpackingList[
                                                                    index],
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "2 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              new TextFormField(
                                                            onChanged: (e) {
                                                              setState(() {
                                                                priceChanged =
                                                                    true;
                                                                prices![index][
                                                                    'unpacking3BHK'] = e;
                                                              });
                                                              print(prices![
                                                                      index][
                                                                  'unpacking3BHK']);
                                                            },
                                                            controller:
                                                                threeBHKUnpackingList[
                                                                    index],
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF3f51b5),
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                new InputDecoration(
                                                                    border: C
                                                                        .textfieldBorder,
                                                                    isDense:
                                                                        true, // Added this
                                                                    prefixText:
                                                                        "₹ ",
                                                                    labelText:
                                                                        "3 BHK Price",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              Text(
                                                "Lift Pricing :",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                "( Enter Price difference per floor where lift is not available. )",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: new TextFormField(
                                                      onChanged: (e) {
                                                        setState(() {
                                                          priceChanged = true;
                                                          prices![index]
                                                              ['lift1BHK'] = e;
                                                        });
                                                        print(prices![index]
                                                            ['lift1BHK']);
                                                      },
                                                      controller:
                                                          oneBHKLiftList[index],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF3f51b5),
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          new InputDecoration(
                                                              border: C
                                                                  .textfieldBorder,
                                                              isDense:
                                                                  true, // Added this
                                                              prefixText: "₹ ",
                                                              labelText:
                                                                  "1 BHK Price",
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          13)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: new TextFormField(
                                                      onChanged: (e) {
                                                        setState(() {
                                                          priceChanged = true;
                                                          prices![index]
                                                              ['lift2BHK'] = e;
                                                        });
                                                        print(prices![index]
                                                            ['lift2BHK']);
                                                      },
                                                      controller:
                                                          twoBHKLiftList[index],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF3f51b5),
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          new InputDecoration(
                                                              border: C
                                                                  .textfieldBorder,
                                                              isDense:
                                                                  true, // Added this
                                                              prefixText: "₹ ",
                                                              labelText:
                                                                  "2 BHK Price",
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          13)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: new TextFormField(
                                                      onChanged: (e) {
                                                        setState(() {
                                                          priceChanged = true;
                                                          prices![index]
                                                              ['lift3BHK'] = e;
                                                        });
                                                        print(prices![index]
                                                            ['lift3BHK']);
                                                      },
                                                      controller:
                                                          threeBHKLiftList[
                                                              index],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF3f51b5),
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          new InputDecoration(
                                                              border: C
                                                                  .textfieldBorder,
                                                              isDense:
                                                                  true, // Added this
                                                              prefixText: "₹ ",
                                                              labelText:
                                                                  "3 BHK Price",
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          13)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  C.box10
                                ],
                              );
                            },
                          ),
                          box20,
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
                                      postOfferingsData();
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
          ],
        ),
      ),
    );
  }

  getFocusNodes() {
    warehouse1BHK = FocusNode();
    warehouse2BHK = FocusNode();
    warehouse3BHK = FocusNode();
    unpacking1BHK = FocusNode();
    unpacking2BHK = FocusNode();
    unpacking3BHK = FocusNode();
    premium1BHK = FocusNode();
    premium2BHK = FocusNode();
    premium3BHK = FocusNode();
    lift1BHK = FocusNode();
    lift2BHK = FocusNode();
    lift3BHK = FocusNode();

    warehouse1BHK!.addListener(() {
      if (priceTips != null) if (!warehouse1BHK!.hasFocus) {
        setState(() {
          if (int.parse(oneBHKwarehouse.text) >=
                  (priceTips!["warehouse1BHKTip"] +
                      (0.5 * priceTips!["warehouse1BHKTip"])) ||
              int.parse(oneBHKwarehouse.text) <=
                  (priceTips!["warehouse1BHKTip"] -
                      (0.5 * priceTips!["warehouse1BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    warehouse2BHK!.addListener(() {
      if (priceTips != null) if (!warehouse2BHK!.hasFocus) {
        setState(() {
          if (int.parse(twoBHKwarehouse.text) >=
                  (priceTips!["warehouse2BHKTip"] +
                      (0.5 * priceTips!["warehouse2BHKTip"])) ||
              int.parse(twoBHKwarehouse.text) <=
                  (priceTips!["warehouse2BHKTip"] -
                      (0.5 * priceTips!["warehouse2BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    warehouse3BHK!.addListener(() {
      if (priceTips != null) if (!warehouse3BHK!.hasFocus) {
        setState(() {
          if (int.parse(threeBHKwarehouse.text) >=
                  (priceTips!["warehouse3BHKTip"] +
                      (0.5 * priceTips!["warehouse3BHKTip"])) ||
              int.parse(threeBHKwarehouse.text) <=
                  (priceTips!["warehouse3BHKTip"] -
                      (0.5 * priceTips!["warehouse3BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    unpacking1BHK!.addListener(() {
      if (priceTips != null) if (!unpacking1BHK!.hasFocus) {
        setState(() {
          if (int.parse(oneBHKUnpacking.text) >=
                  (priceTips!["unpacking1BHKTip"] +
                      (0.5 * priceTips!["unpacking1BHKTip"])) ||
              int.parse(oneBHKUnpacking.text) <=
                  (priceTips!["unpacking1BHKTip"] -
                      (0.5 * priceTips!["unpacking1BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    unpacking2BHK!.addListener(() {
      if (priceTips != null) if (!unpacking2BHK!.hasFocus) {
        setState(() {
          if (int.parse(twoBHKUnpacking.text) >=
                  (priceTips!["unpacking2BHKTip"] +
                      (0.5 * priceTips!["unpacking2BHKTip"])) ||
              int.parse(twoBHKUnpacking.text) <=
                  (priceTips!["unpacking2BHKTip"] -
                      (0.5 * priceTips!["unpackingtwoBHKUnpacking2BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    unpacking3BHK!.addListener(() {
      if (priceTips != null) if (!unpacking3BHK!.hasFocus) {
        setState(() {
          if (int.parse(threeBHKUnpacking.text) >=
                  (priceTips!["unpacking3BHKTip"] +
                      (0.5 * priceTips!["unpacking3BHKTip"])) ||
              int.parse(threeBHKUnpacking.text) <=
                  (priceTips!["unpacking3BHKTip"] -
                      (0.5 * priceTips!["unpackingtwoBHKUnpacking3BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    premium1BHK!.addListener(() {
      if (priceTips != null) if (!premium1BHK!.hasFocus) {
        setState(() {
          if (int.parse(oneBHKPremiumPackaging.text) >=
                  (priceTips!["premium1BHKTip"] +
                      (0.5 * priceTips!["premium1BHKTip"])) ||
              int.parse(oneBHKPremiumPackaging.text) <=
                  (priceTips!["premium1BHKTip"] -
                      (0.5 * priceTips!["premium1BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    premium2BHK!.addListener(() {
      if (priceTips != null) if (!premium2BHK!.hasFocus) {
        setState(() {
          if (int.parse(twoBHKPremiumPackaging.text) >=
                  (priceTips!["premium2BHKTip"] +
                      (0.5 * priceTips!["premium2BHKTip"])) ||
              int.parse(twoBHKPremiumPackaging.text) <=
                  (priceTips!["premium2BHKTip"] -
                      (0.5 * priceTips!["premium2BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    premium3BHK!.addListener(() {
      if (priceTips != null) if (!premium3BHK!.hasFocus) {
        setState(() {
          if (int.parse(threeBHKPremiumPackaging.text) >=
                  (priceTips!["premium3BHKTip"] +
                      (0.5 * priceTips!["premium3BHKTip"])) ||
              int.parse(threeBHKPremiumPackaging.text) <=
                  (priceTips!["premium3BHKTip"] -
                      (0.5 * priceTips!["premium3BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    lift1BHK!.addListener(() {
      if (priceTips != null) if (!lift1BHK!.hasFocus) {
        setState(() {
          if (int.parse(oneBHKLift.text) >=
                  (priceTips!["lift1BHKTip"] +
                      (0.5 * priceTips!["lift1BHKTip"])) ||
              int.parse(oneBHKLift.text) <=
                  (priceTips!["lift1BHKTip"] -
                      (0.5 * priceTips!["lift1BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    lift2BHK!.addListener(() {
      if (priceTips != null) if (!lift2BHK!.hasFocus) {
        setState(() {
          if (int.parse(twoBHKLift.text) >=
                  (priceTips!["lift2BHKTip"] +
                      (0.5 * priceTips!["lift2BHKTip"])) ||
              int.parse(twoBHKLift.text) <=
                  (priceTips!["lift2BHKTip"] -
                      (0.5 * priceTips!["lift2BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
    lift3BHK!.addListener(() {
      if (priceTips != null) if (!lift3BHK!.hasFocus) {
        setState(() {
          if (int.parse(threeBHKLift.text) >=
                  (priceTips!["lift3BHKTip"] +
                      (0.5 * priceTips!["lift3BHKTip"])) ||
              int.parse(threeBHKLift.text) <=
                  (priceTips!["lift3BHKTip"] -
                      (0.5 * priceTips!["lift3BHKTip"]))) {
            correctPricing(context);
          }
        });
      }
    });
  }
}
