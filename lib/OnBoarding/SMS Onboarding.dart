import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:timelines/timelines.dart';

import '../Constants.dart';
import '../Drawer.dart';
import '../Fade Route.dart';
import '../Widgets/Counter.dart';
import '../Widgets/Loading.dart';
import '../Widgets/No%20Results%20Found.dart';
import '../auth/redirect_login.dart';

class SMSOnboarding extends StatefulWidget {
  final id;
  SMSOnboarding({this.id});
  @override
  _SMSOnboardingState createState() => _SMSOnboardingState();
}

class _SMSOnboardingState extends State<SMSOnboarding> {
  var dio = Dio();
  bool loading = true;
  Map? data;
  int _processIndex = 0;

  //////////////////////////
  ///
  double noOfLocalMovement = 0;
  double noOfOutstationMovement = 0;

  List<dynamic> intercity = [];
  List<dynamic> intracity = [];

  bool localShow = false;
  bool outstationShow = false;
  final formatCurrency =
      new NumberFormat.simpleCurrency(name: "", decimalDigits: 0);

  bool priceCalculated = false;
  bool price = false;
  bool estimatorLoading = false;
  String? earnings;
  String? revenue;
  late var _items;

  getEarnings() async {
    logEvent('checked_Earnings');
    setState(() {
      estimatorLoading = true;
    });
    List intra = [];
    List inter = [];
    for (var i = 0; i < intracity.length; i++) {
      intra.add({"city": intracity[i]});
    }

    for (var i = 0; i < intercity.length; i++) {
      inter.add({"city": intercity[i]});
    }
    print(inter);
    print(intra);
    Map data = {
      "type": "totalEstimation",
      "tenantUsecase": "pam",
      "tenantSet_id": "PAM01",
      "mobile": "",
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
        displaySnackBar("Earnings Unavailable for this selection", context);
      }
      estimatorLoading = false;
    });
  }

  void initState() {
    super.initState();

    _items = cities
        .map((i) => MultiSelectItem<dynamic>(
              i,
              i,
            ))
        .toList();
    if (widget.id != null) {
      logEvent('SMS_Onboarding_Screen');
      getData();
    } else {
      logEvent('Onboarding_Screen');
      increaseCounter();
      loading = false;
    }
    getSp();
  }

  List partnerData = [];

  getSp() async {
    try {
      var resp = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
          data: {
            "tenantSet_id": "PAM01",
            "tenantUsecase": "pac",
            "useCase": "partnerlist",
            "city": ""
          });
      print(resp);
      Map<String, dynamic> map = json.decode(resp.toString());
      for (var i = 0; i < map["resp"]["Items"].length; i++) {
        if (map["resp"]["Items"][i]["displayImage"] != null)
          partnerData.add(map["resp"]["Items"][i]);
      }
      setState(() {
        partnerData = partnerData;
      });
    } catch (e) {
      print(e);
    }
  }

  getData() async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/price-calculator',
          data: {
            "tenantSet_id": "PAM01",
            "useCase": "onboard",
            "tenantUsecase": "xyz",
            "oldId": widget.id
          });
      print(response);
      Map<String, dynamic>? map = json.decode(response.toString());
      print(map);

      setState(() {
        data = map!["resp"][0];
        loading = false;
      });
      increaseCounter();
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  increaseCounter() {
    Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        _processIndex++;
      });
      if (_processIndex > 3) {
        t.cancel();
      }
    });
  }

  bool newView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            launchWhatsApp();
          },
          backgroundColor: Color(0xFF25D366),
          child: FaIcon(FontAwesomeIcons.whatsapp),
        ),
        bottomNavigationBar: loading
            ? Container(
                height: 10,
              )
            : Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFf9a825), // background
                        onPrimary: Colors.black, // foreground
                      ),
                      onPressed: () async {
                        loginPrompt();
                      },
                      child: Text(
                        "Join Us",
                        style: TextStyle(fontSize: 17),
                      )),
                ),
              ),
        drawer: MyDrawer(),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              setState(() {
                newView = !newView;
              });
            },
            child: Column(
              children: [
                Text(
                  "GoFlexe",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, fontSize: 17),
                ),
                if (!newView)
                  Text(
                    "Packers & Movers",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
              ],
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    FadeRoute(page: FAQ()),
                  );
                },
                icon: FaIcon(
                  Icons.help_outline_rounded,
                ))
          ],
        ),
        body: loading
            ? Loading()
            : SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    newView
                        ? Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: C.primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(40.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  data != null
                                      ? "Welcome," + data!["Business Name"]
                                      : "Welcome, Packers & Movers",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                C.box10,
                                if (data != null &&
                                    data!["rating"] != null &&
                                    data!["rating"].toString().isNotEmpty)
                                  Row(
                                    children: [
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        initialRating: double.tryParse(
                                            data!["rating"].toString())!,
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        itemSize: 20,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 1.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double value) {},
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          )
                        : Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: C.primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(40.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome,",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  data != null
                                      ? data!["Business Name"]
                                      : "Packers & Movers",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                C.box10,
                                if (data != null &&
                                    data!["rating"] != null &&
                                    data!["rating"].toString().isNotEmpty)
                                  Row(
                                    children: [
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        initialRating: double.tryParse(
                                            data!["rating"].toString())!,
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        itemSize: 20,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 1.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double value) {},
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                C.box10,
                                Text(
                                    "Complete your free registration here and start shipping in less than 5 minutes!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ))
                              ],
                            ),
                          ),
                    C.box20,
                    Column(
                      children: [
                        Text("Increase your\nEarnings in 4 easy steps",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            )),
                        box10,
                        Container(height: 150, child: sellingProcess()),
                      ],
                    ),
                    box20,
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    free500Voucher(),
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    if (partnerData.length != 0) spList(),
                    box20,
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    box20,
                    whyJoinUs(),
                    Divider(
                      height: 50,
                      thickness: 3,
                    ),
                    checkEarnings(),
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    prefilledInfo(),
                    Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    box20,
                    if (data != null &&
                        data!["reviews"] != null &&
                        data!["reviews"]?.length != 0)
                      customerReviews(),
                    box30,
                    box30,
                  ]))));
  }

  loginPrompt() {
    showModalBottomSheet(
        isDismissible: false,
        shape: RoundedRectangleBorder(
          // <-- for border radius
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RedirectLogin(
                  intercity: intercity,
                  intracity: intracity,
                  data: data,
                  oldId: widget.id,
                ),
              ],
            ),
          );
        });
  }

  Widget spList() {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          box10,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recently Joined Partners",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black87.withOpacity(0.8)),
                ),
                Text(
                  "   New",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Container(
              height: 170,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 170,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.4,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  // enlargeCenterPage: true,
                  // enlargeStrategy: CenterPageEnlargeStrategy.height,
                  scrollDirection: Axis.horizontal,
                ),
                items: List.generate(partnerData.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Card(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: partnerData[index]
                                                ["displayImage"] ==
                                            null
                                        ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSDu8Wd7NE4H4IsXxko3l1bUucDHv7kl1BTA&usqp=CAU"
                                        : "https://goflexe-kyc.s3.ap-south-1.amazonaws.com/${partnerData[index]['displayImage']}",
                                    placeholder: (context, url) => CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        FontAwesomeIcons.truck,
                                        color: primaryColor,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                          partnerData[index]["companyName"] ??
                                              "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      Text(
                                          partnerData[index]["address"]
                                                  .split(" ")[partnerData[index]
                                                          ["address"]
                                                      .split(" ")
                                                      .length -
                                                  2] +
                                              " " +
                                              partnerData[index]["address"]
                                                  .split(" ")
                                                  .last
                                                  .toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                              top: 74,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Text(
                                  partnerData[index]["rating"] == null
                                      ? "4.0 ⭐"
                                      : "${partnerData[index]["rating"].toString()} ⭐",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ))
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget checkEarnings() {
    return Container(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Check how much can you earn?",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: primaryColor)),
            box20,
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
              initialValue: intercity,
              items: _items,
              onSelectionChanged: (values) {
                setState(() {
                  price = true;
                  outstationShow = true;
                  intercity = values;
                });
              },
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                noOfLocalMovement = value as double;
                              });
                              getEarnings();
                            }),
                        Text(
                          "Local Movements per week",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                if (outstationShow == true)
                  Expanded(
                    child: Column(
                      children: [
                        Counter(
                            initialValue: noOfOutstationMovement,
                            minValue: 0,
                            maxValue: 10,
                            step: 1,
                            decimalPlaces: 0,
                            onChanged: (value) {
                              setState(() {
                                noOfOutstationMovement = value as double;
                              });
                              getEarnings();
                            }),
                        Text(
                          "Outstation Movements per week",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600),
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
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
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
                                    ? "₹ ${formatCurrency.format(int.parse(earnings as String))} per\nannum"
                                    : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF2f7769),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
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
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
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
                                    ? "₹ ${formatCurrency.format(int.parse(revenue as String))} per\nannum"
                                    : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF2f7769),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
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
            ElevatedButton(
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
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget whyJoinUs() {
    List benefits = [
      {
        "title": "Visibility to PAN India customers",
        "benefit":
            "Have greater visibility of your services to a wide range of customers pan-india",
        "img": "assets/revenue.png"
      },
      {
        "title": "Easy to Use",
        "benefit":
            "Easy to use platform to schedule,track multiple orders at once",
        "img": "assets/smiling.png"
      },
      {
        "title": "Realtime Interaction",
        "benefit": "Get all order related details realtime.",
        "img": "assets/box.png"
      },
      {
        "title": "Incentive based Earning",
        "benefit": "Higher Incentives on accepting more orders per week.",
        "img": "assets/giftbox.png"
      },
      {
        "title": "Direct payment",
        "benefit": "Direct payment from customers.\nNo Commission.",
        "img": "assets/getPayment.png"
      },
      {
        "title": "Additional Earnings",
        "benefit":
            "Additional Service Offerings:\npremium packing, unpacking, warehouse and insurance.",
        "img": "assets/search.png"
      },
    ];

    final double runSpacing = 10;
    final double spacing = 10;

    return Container(
        width: double.maxFinite,
        child: Column(children: [
          Text("Why Join GoFlexe",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: primaryColor)),
          box20,
          Wrap(
            runSpacing: runSpacing,
            spacing: spacing,
            alignment: WrapAlignment.center,
            children: List.generate(benefits.length, (i) {
              return InkWell(
                onTap: () {
                  displaySnackBar(benefits[i]["benefit"], context);
                },
                child: Container(
                  height: 140,
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            benefits[i]["img"],
                          )),
                      box10,
                      Text(
                        benefits[i]["title"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ]));
  }

  Widget sellingProcess() {
    const completeColor = Color(0xff5ec792);
    const inProgressColor = Color(0xff5e6172);
    const todoColor = Color(0xffd1d2d7);

    Color getColor(int index) {
      if (index == _processIndex) {
        return inProgressColor;
      } else if (index < _processIndex) {
        return completeColor;
      } else {
        return todoColor;
      }
    }

    return Timeline.tileBuilder(
      shrinkWrap: true,
      theme: TimelineThemeData(
        direction: Axis.horizontal,
        connectorTheme: ConnectorThemeData(
          space: 30.0,
          thickness: 5.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemExtentBuilder: (_, __) =>
            MediaQuery.of(context).size.width / _processes.length,
        oppositeContentsBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: index <= _processIndex
                  ? CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 20,
                      child: Image.asset(images[index]))
                  : Container());
        },
        contentsBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              _processes[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getColor(index),
              ),
            ),
          );
        },
        indicatorBuilder: (_, index) {
          var color;
          var child;
          if (index == _processIndex) {
            color = inProgressColor;
            child = Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          } else if (index < _processIndex) {
            color = completeColor;
            child = Icon(
              Icons.check,
              color: Colors.white,
              size: 15.0,
            );
          } else {
            color = todoColor;
          }

          if (index <= _processIndex) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(30.0, 30.0),
                  painter: BezierPainter(
                    color: color,
                    drawStart: index > 0,
                    drawEnd: index < _processIndex,
                  ),
                ),
                DotIndicator(
                  size: 30.0,
                  color: color,
                  child: child,
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(15.0, 15.0),
                  painter: BezierPainter(
                    color: color,
                    drawEnd: index < _processes.length - 1,
                  ),
                ),
                OutlinedDotIndicator(
                  borderWidth: 4.0,
                  color: color,
                ),
              ],
            );
          }
        },
        connectorBuilder: (_, index, type) {
          if (index > 0) {
            if (index == _processIndex) {
              final prevColor = getColor(index - 1);
              final color = getColor(index);
              List<Color?> gradientColors;
              if (type == ConnectorType.start) {
                gradientColors = [Color.lerp(prevColor, color, 0.5), color];
              } else {
                gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)];
              }
              return DecoratedLineConnector(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors as List<Color>,
                  ),
                ),
              );
            } else {
              return SolidLineConnector(
                color: getColor(index),
              );
            }
          } else {
            return null;
          }
        },
        itemCount: _processes.length,
      ),
    );
  }

  Widget free500Voucher() {
    return InkWell(
      onTap: () {
        loginPrompt();
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
        padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Onboard with us and get\n",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: '₹ 500 ',
                            style: GoogleFonts.montserrat(
                              color: primaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.white.withOpacity(0.7),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          TextSpan(
                            text: "voucher as incentive",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Image.asset(
                  "assets/500.png",
                  height: 80,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget prefilledInfo() {
    return InkWell(
      onTap: () {
        launchWhatsApp();
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
        child: Row(
          children: [
            Image.asset(
              "assets/assist.jpg",
              height: 100,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "We will assist you in filling the information",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.white.withOpacity(0.7),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  box5,
                  Text(
                    "You can contact us anytime",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.white.withOpacity(0.7),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customerReviews() {
    return Container(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We will help you\nimprove your service standards",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87.withOpacity(0.8)),
                ),
                box5,
                Text(
                  "What customers are saying about your safety standards",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.grey),
                ),
                box5,
              ],
            ),
          ),
          box10,
          Container(
            height: 160,
            child: ListView.builder(
                padding: EdgeInsets.only(left: 15),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: data!["reviews"].length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: MediaQuery.of(context).size.width - 100,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFf0faff),
                      border: Border.all(
                          width: 3, color: Color(0xFF7fd3ef).withOpacity(0.4)),
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Image.network(
                                  data!["reviews"][index]["profile_photo_url"]),
                              backgroundColor: Colors.grey[400],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data!["reviews"][index]["author_name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0d5371)),
                                ),
                                if (data!["reviews"][index]["rating"] != null &&
                                    data!["reviews"][index]["rating"]
                                        .toString()
                                        .isNotEmpty)
                                  RatingBar.builder(
                                    ignoreGestures: true,
                                    initialRating: double.tryParse(
                                        data!["reviews"][index]["rating"]
                                            .toString())!,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    itemSize: 13,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double value) {},
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 60),
                            child: Text(
                              data!["reviews"][index]["text"]
                                      .toString()
                                      .isNotEmpty
                                  ? data!["reviews"][index]["text"]
                                  : "No review Available",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            data!["reviews"][index]
                                ["relative_time_description"],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
          box10,
        ],
      ),
    );
  }
}

final images = [
  "assets/register.png",
  "assets/addPrice.png",
  "assets/recieveOrders.png",
  "assets/getPayment.png"
];

final _processes = [
  'Register\nas Partner',
  'Add Pricing\nDetails',
  'Receive orders\n& ship',
  'Get quick\nPayment',
];

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  List filteredFAQ = [];

  var dio = Dio();
  bool loading = false;

  void initState() {
    super.initState();
    filteredFAQ = faq;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text(
            "FAQ's",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        body: loading == true
            ? Loading()
            : SafeArea(
                child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: new TextFormField(
                              textInputAction: TextInputAction.go,
                              onChanged: (string) {
                                setState(() {
                                  filteredFAQ = (faq)
                                      .where((u) => (u["faq"]
                                              .toString()
                                              .toLowerCase()
                                              .contains(string.toLowerCase()) ||
                                          u["ans"]
                                              .toString()
                                              .toLowerCase()
                                              .contains(string.toLowerCase())))
                                      .toList();
                                });
                              },
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                isDense: true, // Added this
                                contentPadding: EdgeInsets.all(15),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF2821B5),
                                  ),
                                ),
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.grey)),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: "Search FAQ's..",
                              ),
                            ),
                          ),
                          C.box20,
                          filteredFAQ.length == 0
                              ? NoResult()
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: filteredFAQ.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, right: 5, left: 5),
                                      child: Card(
                                        child: Container(
                                          // margin: EdgeInsets.only(bottom: 15),
                                          child: ExpansionTile(
                                            tilePadding: EdgeInsets.only(
                                                left: 10,
                                                top: 5,
                                                bottom: 5,
                                                right: 5),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.question_answer,
                                                  color: Color(0xFF9fa8da),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Expanded(
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          filteredFAQ[index]
                                                              ["faq"],
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ))),
                                                ),
                                              ],
                                            ),
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    bottom: 20),
                                                child: Text(
                                                  filteredFAQ[index]["ans"],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ],
                      ),
                    ))));
  }
}

List faq = [
  {
    "faq": "Is there any fee to become partner?",
    "ans": "No, its absolutely free. We will not charge anything from you."
  },

  {
    "faq": "What document do I need to register with you?",
    "ans":
        "No document is mandatory, but providing additional details like images and about you will help to increase the visibility among customers."
  },
  {
    "faq": "Who takes responsibility if the product is damaged during transit?",
    "ans": ""
  },
  {
    "faq":
        "As a partner, do I have to take care of the packaging materials from my end?",
    "ans": ""
  },

  {
    "faq": " How are Cash on Delivery transactions carried out?",
    "ans":
        "All COD orders money is collected our operations partner and is remitted into GoFlexe’s account. While doing the monthly reconciliation, we deduct the commission chargeable, along with taxes, and remit the balance amount to your account. This settlement includes both online as well as COD payments. The amount is transferred to you on a monthly basis."
  },
  {
    "faq": "Will your team communicate the order in regional languages?",
    "ans":
        "Orders will be forwarded to you via an email and SMS and will be in the English language only. For the initial couple of orders, we call the sellers and inform them about the incoming orders. You can indicate the preferred language of communication and we will do our best to accommodate the request."
  },
  {
    "faq":
        "Are you going to write something about my buisness/quality on your site apart from just displaying the menu?",
    "ans":
        "This is where we stand out. Each Seller Partner gets a dedicated page on our website with a vanity URL and would have the following (Some of them are Value Added Services which come at a very nominal price):\n\nVendor Images: Here, we will show our sellers make their unique products, and the efforts being put in by the people behind the enterprise. This is to establish trust in the eyes of the customer and make it look real and authentic.\nVendor Profile: We would also put a short write up about how you started your business, what was your inspiration from etc. This helps the customers connect better with you on an emotional level.\n\nProduct Images: This is our USP. We ensure each product is photographed in an aesthetic manner. This is a welcome change as compared to seeing white background images on other e-commerce platforms."
  },
  {
    "faq": "What are the promotional activities you do?",
    "ans":
        "We do both online as well as offline promotions. Online Promotions - Social Media Marketing on sites like Facebook, Instagram, Twitter Offline Promotions - ATL activities in regional and national newspapers, radio channels, magazines etc."
  },
  // {"faq": "", "ans": ""},
  // {"faq": "", "ans": ""},
  // {"faq": "", "ans": ""},
  {
    "faq": "How soon will I get payment after the sale?",
    "ans":
        "As soon as you deliver the product. Payment will get deposited in your bank account within 7 days."
  },
  {
    "faq": "Can I use this platform if I am already using another platform?",
    "ans":
        "Yes, we dont have any restriction for working with others while partnering with us."
  },
  {
    "faq": "Can I upload prices in bulk using CSV file?",
    "ans":
        "Yes, you need to email us your product CSV file and we will upload in your store. After uploading you just need to edit for any corrections and submit the prices."
  },
  {
    "faq": "Can I offer separate coupon for my products?",
    "ans":
        "Yes, you can create and offer discount coupons for your products only through store manager."
  },
  {
    "faq": "Can I offer local services?",
    "ans":
        "Yes, you can offer local services for your customers around you and save shipping time as well as maintain your regular customers."
  },
  {
    "faq": "Whom can I reach out to, in case I face a problem?",
    "ans":
        "You can contact us at admin@goflexe.com for any parnter related query."
  },
];

Path drawStar(Size size) {
  // Method to convert degree to radians
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}
