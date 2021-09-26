import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../Appbar.dart';
import '../Constants.dart';
import '../Fade Route.dart';
import '../OnBoarding/Mandatory%20KYC.dart';
import '../OnBoarding/Price.dart';
import '../Widgets/Loading.dart';
import 'BottomNavBar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ReviewScreen extends StatefulWidget {
  final edit;
  final done;
  ReviewScreen({this.edit, this.done});
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  final greenKey = new GlobalKey();
  final blueKey = new GlobalKey();
  final orangeKey = new GlobalKey();
  final yellowKey = new GlobalKey();
  final sliverListtKey = new GlobalKey();
  RenderBox? overRender;
  RenderBox? revRender;
  RenderBox? menuRender;
  RenderBox? contactRender;
  RenderBox? sliverRender;
  ScrollController? scrollController;
  TabController? _tabController;
  late TabController _topTabController;
  late double greenHeight;
  late double blueHeight;
  late double orangeHeight;
  late double yellowHeight;
  var dio = Dio();
  List<dynamic>? userData = [];
  bool loading = true;
  bool sendingData = false;
  ///////////////////////////////////
  TextEditingController websiteController = new TextEditingController();
  var websiteNode = FocusNode();
  TextEditingController aboutController = new TextEditingController();
  var aboutNode = FocusNode();
  TextEditingController contactController = new TextEditingController();
  var contactNode = FocusNode();
  List? servingCities = [];

  final _items = cities
      .map((extraItems) => MultiSelectItem<dynamic>(
            extraItems,
            extraItems,
          ))
      .toList();
  List<dynamic> intercity = [];
  List<dynamic> intracity = [];

  @override
  void initState() {
    super.initState();
    print(widget.edit);
    getKycData();

    scrollController = ScrollController();
    _tabController = new TabController(length: 4, vsync: this);
    _topTabController = new TabController(length: 4, vsync: this);
    addScrollControllerListener();
    logEvent("Review_Screen");
  }

  getKycData() async {
    try {
      final response = await dio.get(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?tenantSet_id=PAM01&tenantUsecase=pam&type=packersAndMoversSP&id=${_auth.currentUser!.uid}',
          options: Options(
            responseType: ResponseType.plain,
          ));
      print(response);
      Map? map = json.decode(response.toString());

      setState(() {
        userData = map!["resp"];
        websiteController.text = userData![0]["website"].isNotEmpty
            ? userData![0]["website"]
            : "Not Available";
        aboutController.text = userData![0]['companyDescription'].isNotEmpty
            ? userData![0]['companyDescription']
            : "Not Available";
        contactController.text = userData![0]['name'] ?? "Not Available";
        servingCities = userData![0]["outstationCities"] != null
            ? (userData![0]["outstationCities"] ??
                    [""] + userData![0]["localCities"] ??
                    [""])
                .toSet()
                .toList()
            : ["Not Available"];
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  SliverPersistentHeader makeTabBarHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 50.0,
        child: Container(
          color: Colors.white,
          child: TabBar(
            onTap: (val) {
              tabBarOnTap(val);
            },
            unselectedLabelColor: Colors.grey.shade700,
            indicatorColor: Color(0xFF3f51b5),
            indicatorWeight: 2.0,
            labelColor: Color(0xFF3f51b5),
            controller: _tabController,
            tabs: <Widget>[
              new Tab(
                child: Text(
                  "PHOTOS",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              new Tab(
                child: Text(
                  "ABOUT",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              new Tab(
                child: Text(
                  "CONTACT",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              new Tab(
                child: Text(
                  "REVIEWS",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _topTabController.dispose();
    scrollController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFf9a825), // background
              onPrimary: Colors.black, // foreground
            ),
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              postKYCData();
              if (widget.done != null) {
                Navigator.push(
                  context,
                  FadeRoute(page: BottomNavScreen()),
                );
              } else {
                if (widget.edit != null) {
                  Navigator.push(
                    context,
                    FadeRoute(
                        page: MandatoryKYC(
                      edit: "edit",
                    )),
                  );
                } else {
                  Navigator.push(
                    context,
                    FadeRoute(page: AllPrices()),
                  );
                }
              }
            },
            child: widget.done != null
                ? Text("Save")
                : widget.edit != null
                    ? Text("Edit")
                    : sendingData == true
                        ? Column(
                            children: [
                              Text(""),
                              Center(
                                child: LinearProgressIndicator(
                                  backgroundColor: Color(0xFF3f51b5),
                                  valueColor: AlwaysStoppedAnimation(
                                    Color(0xFFf9a825),
                                  ),
                                ),
                              ),
                              Text("Please Wait")
                            ],
                          )
                        : Text(
                            "Next",
                            style: TextStyle(color: Colors.black),
                          ),
          ),
        ),
      ),
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: MyAppBar(
            curStep: 0,
          )),
      body: loading
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Loading())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This is how the customer will view your screen.",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      C.box10,
                      if (widget.edit == null)
                        Text(
                          "You can go back to the previous screen to add or edit details",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Card(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (3 / 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userData![0]['companyName'] ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                userData![0]['address'] ?? "",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              if (userData![0]["rating"] !=
                                                      null &&
                                                  userData![0]["rating"]
                                                      .toString()
                                                      .isNotEmpty)
                                                RatingBar.builder(
                                                  ignoreGestures: true,
                                                  initialRating: userData![0]
                                                              ["rating"] !=
                                                          null
                                                      ? double.parse(
                                                          userData![0]["rating"]
                                                              .toString())
                                                      : 0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  itemSize: 18,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 1.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate:
                                                      (double value) {},
                                                ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.amber,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.amber,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 13,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Text(
                                                              "VERIFIED",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                          .grey[
                                                                      700])),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  (2 / 5) -
                                              50,
                                          color: Colors.grey[300],
                                          child: SizedBox(
                                            child: Image.network(
                                              userData![0]["displayImage"] ==
                                                      null
                                                  ? "https://images-na.ssl-images-amazon.com/images/I/61u%2BNKkFnmL._SL1000_.jpg"
                                                  : "https://goflexe-kyc.s3.ap-south-1.amazonaws.com/${userData![0]["displayImage"]}",
                                              fit: BoxFit.cover,
                                            ),
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
                                      ],
                                    ),

                                    SizedBox(
                                      height: 20,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Icon(
                                    //       Icons.tag_faces_sharp,
                                    //       color: Colors.grey,
                                    //     ),
                                    //     SizedBox(
                                    //       width: 5,
                                    //     ),
                                    //     Text(
                                    //       "Services Offered : ",
                                    //       style: TextStyle(
                                    //         color: Colors.grey[700],
                                    //         fontWeight: FontWeight.w600,
                                    //       ),
                                    //     ),
                                    //     SizedBox(
                                    //       width: 5,
                                    //     ),
                                    //     Expanded(
                                    //       child: Text(
                                    //         "Warehousing & Premium Packaging",
                                    //         style: TextStyle(
                                    //           fontSize: 12,
                                    //           color: Colors.grey,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.internetExplorer,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Website : ",
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: websiteController,
                                            focusNode: websiteNode,
                                            showCursor: true,
                                            cursorColor: Colors.black,
                                            cursorWidth: 3,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            onTap: () {
                                              websiteController.clear();
                                            },
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: "",
                                            ),
                                            onChanged: (x) {},
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            websiteController.clear();
                                            websiteNode.requestFocus();
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 12,
                                          ),
                                        ),
                                        Spacer()
                                      ],
                                    ),

                                    if (userData![0]["outstationCities"] !=
                                        null)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_city,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Serving in : ",
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                servingCities.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  askCity();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          userData![0]["mobile"].toString(),
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "(Call - for Service Enquiry)",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      makeTabBarHeader(),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Card(
                              child: Container(
                                key: greenKey,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Photos",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 100,
                                      child: userData![0]["otherImages"] == null
                                          ? Center(
                                              child: Text(
                                              "Not Available",
                                              style: TextStyle(),
                                            ))
                                          : ListView.builder(
                                              itemCount: userData![0]
                                                      ["otherImages"]
                                                  .length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return new Container(
                                                  height: 100,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: Image.network(
                                                    "https://goflexe-kyc.s3.ap-south-1.amazonaws.com/${userData![0]["otherImages"][index]}",
                                                    fit: BoxFit.fill,
                                                  ),
                                                  alignment: Alignment.center,
                                                );
                                              },
                                              scrollDirection: Axis.horizontal,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Container(
                                key: blueKey,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("About",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            maxLines: 5,
                                            controller: aboutController,
                                            focusNode: aboutNode,
                                            showCursor: true,
                                            cursorColor: Colors.black,
                                            cursorWidth: 3,
                                            style: TextStyle(fontSize: 14),
                                            onTap: () {
                                              aboutController.clear();
                                            },
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: "",
                                            ),
                                            onChanged: (x) {},
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            aboutController.clear();
                                            aboutNode.requestFocus();
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Container(
                                key: orangeKey,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Contact Information",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Contact Person",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            contactController.clear();
                                            contactNode.requestFocus();
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      controller: contactController,
                                      focusNode: contactNode,
                                      showCursor: true,
                                      cursorColor: Colors.black,
                                      cursorWidth: 3,
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                      onTap: () {
                                        websiteController.clear();
                                      },
                                      decoration: InputDecoration.collapsed(
                                        hintText: "",
                                      ),
                                      onChanged: (x) {},
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Address",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      userData![0]["address"] ?? "",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Contact Number",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.grey,
                                          size: 12,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          userData![0]['pointOfContactNo'] == ""
                                              ? userData![0]["mobile"] ?? ""
                                              : userData![0]
                                                  ['pointOfContactNo'],
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Container(
                                key: yellowKey,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    box10,
                                    Text("Reviews",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    box20,
                                    if (userData![0]["reviews"] != null &&
                                        userData![0]["reviews"].length != 0)
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              userData![0]["reviews"].length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFf0faff),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        5.0) //                 <--- border radius here
                                                    ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        child: Image.network(
                                                            userData![0][
                                                                        "reviews"]
                                                                    [index][
                                                                "profile_photo_url"]),
                                                        backgroundColor:
                                                            Colors.grey[400],
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            userData![0][
                                                                        "reviews"]
                                                                    [index]
                                                                ["author_name"],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Color(
                                                                    0xFF0d5371)),
                                                          ),
                                                          RatingBar.builder(
                                                            ignoreGestures:
                                                                true,
                                                            initialRating: double.tryParse(
                                                                userData![0]["reviews"]
                                                                            [
                                                                            index]
                                                                        [
                                                                        "rating"]
                                                                    .toString())!,
                                                            minRating: 0,
                                                            direction:
                                                                Axis.horizontal,
                                                            itemSize: 13,
                                                            allowHalfRating:
                                                                true,
                                                            itemCount: 5,
                                                            itemPadding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        1.0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            onRatingUpdate:
                                                                (double
                                                                    value) {},
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 60),
                                                    child: Text(
                                                      userData![0]["reviews"]
                                                                      [index]
                                                                  ["text"]
                                                              .toString()
                                                              .isNotEmpty
                                                          ? userData![0]
                                                                  ["reviews"]
                                                              [index]["text"]
                                                          : "No review Available",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Text(
                                                      userData![0]["reviews"]
                                                              [index][
                                                          "relative_time_description"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Divider()
                                                ],
                                              ),
                                            );
                                          })
                                    else
                                      Text("No Reviews Available")
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  askCity() {
    showModalBottomSheet(
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
                    });
                  },
                  onConfirm: (values) {
                    setState(() {
                      intracity = values;
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
                  onConfirm: (values) {
                    setState(() {
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
                box20,
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        servingCities =
                            (intercity + intracity).toSet().toList();
                      });

                      Navigator.pop(context);
                    },
                    child: Text("Done"))
              ],
            ),
          );
        });
  }

  postKYCData() async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
          data: {
            "type": "packersAndMoversSP",
            "id": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "localCities": intracity,
            "outstationCities": intracity,
            "companyDescription": aboutController.text,
            "website": websiteController.text,
            "name": contactController.text,
          });
      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
      } else {
        setState(() {
          sendingData = false;
        });
        displaySnackBar("Error, Please try again later.", context);
      }
    } catch (e) {
      print(e);
      setState(() {
        sendingData = false;
      });
      displaySnackBar("Error, Please try again later.", context);
    }
  }

  void addScrollControllerListener() {
    scrollController!.addListener(() {
      if (greenKey.currentContext != null) {
        greenHeight = greenKey.currentContext!.size!.height;
      }
      if (blueKey.currentContext != null) {
        blueHeight = blueKey.currentContext!.size!.height;
      }
      if (orangeKey.currentContext != null) {
        orangeHeight = orangeKey.currentContext!.size!.height;
      }
      if (yellowKey.currentContext != null) {
        yellowHeight = yellowKey.currentContext!.size!.height;
      }
      if (scrollController!.offset > greenHeight + 200 &&
          scrollController!.offset < blueHeight + greenHeight + 200) {
      } else {}
      if (scrollController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (scrollController!.offset > 0 &&
            scrollController!.offset < greenHeight + 200) {
          _tabController!.animateTo(0);
        } else if (scrollController!.offset > greenHeight + 200 &&
            scrollController!.offset < blueHeight + greenHeight + 200) {
          _tabController!.animateTo(1);
        } else if (scrollController!.offset > blueHeight + greenHeight + 200 &&
            scrollController!.offset <
                blueHeight + greenHeight + orangeHeight + 200) {
          _tabController!.animateTo(2);
        } else if (scrollController!.offset >
                blueHeight + greenHeight + orangeHeight + 200 &&
            scrollController!.offset <=
                blueHeight + greenHeight + orangeHeight + yellowHeight + 200) {
          _tabController!.animateTo(3);
        } else {}
      } else if (scrollController!.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (scrollController!.offset < greenHeight) {
          _tabController!.animateTo(0);
        } else if (scrollController!.offset > greenHeight &&
            scrollController!.offset < blueHeight + greenHeight) {
          _tabController!.animateTo(1);
        } else if (scrollController!.offset > blueHeight + greenHeight &&
            scrollController!.offset <
                blueHeight + greenHeight + orangeHeight) {
          _tabController!.animateTo(2);
        } else if (scrollController!.offset >
                blueHeight + greenHeight + orangeHeight &&
            scrollController!.offset <
                blueHeight + greenHeight + orangeHeight + yellowHeight) {
          _tabController!.animateTo(3);
        } else {}
      }
    });
  }

  void tabBarOnTap(val) {
    switch (val) {
      case 0:
        {
          if (greenKey.currentContext == null) {
            scrollController!.position
                .ensureVisible(
              orangeKey.currentContext!.findRenderObject()!,
              alignment:
                  0.0, // How far into view the item should be scrolled (between 0 and 1).
              duration: const Duration(milliseconds: 200),
            )
                .then((value) {
              scrollController!.position
                  .ensureVisible(
                orangeKey.currentContext!.findRenderObject()!,
                alignment:
                    0.0, // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  blueKey.currentContext!.findRenderObject()!,
                  alignment:
                      0.0, // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position.ensureVisible(
                    greenKey.currentContext!.findRenderObject()!,
                    alignment:
                        0.0, // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  );
                });
              });
            });
          } else {
            scrollController!.position.ensureVisible(
              greenKey.currentContext!.findRenderObject()!,
              alignment: 0.0,
              // How far into view the item should be scrolled (between 0 and 1).
              duration: const Duration(milliseconds: 800),
            );
          }
        }
        break;
      case 1:
        {
          if (blueKey.currentContext == null) {
            if (_tabController!.previousIndex == 0) {
              scrollController!.position
                  .ensureVisible(
                greenKey.currentContext!.findRenderObject()!,
                alignment: 0.0,
                // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  greenKey.currentContext!.findRenderObject()!,
                  alignment: 0.5,
                  // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position.ensureVisible(
                    blueKey.currentContext!.findRenderObject()!,
                    alignment: 0.0,
                    // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  );
                });
              });
            } else {
              scrollController!.position
                  .ensureVisible(
                orangeKey.currentContext!.findRenderObject()!,
                alignment: 0.5,
                // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  orangeKey.currentContext!.findRenderObject()!,
                  alignment: 0.0,
                  // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position
                      .ensureVisible(
                    blueKey.currentContext!.findRenderObject()!,
                    alignment: 0.5,
                    // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  )
                      .then((value) {
                    scrollController!.position.ensureVisible(
                      blueKey.currentContext!.findRenderObject()!,
                      alignment: 0.0,
                      // How far into view the item should be scrolled (between 0 and 1).
                      duration: const Duration(milliseconds: 200),
                    );
                  });
                });
              });
            }
          } else {
            scrollController!.position.ensureVisible(
              blueKey.currentContext!.findRenderObject()!,
              alignment: 0.0,
              // How far into view the item should be scrolled (between 0 and 1).
              duration: const Duration(milliseconds: 400),
            );
          }
        }
        break;
      case 2:
        {
          if (orangeKey.currentContext == null) {
            if (_tabController!.previousIndex == 0) {
              scrollController!.position
                  .ensureVisible(
                greenKey.currentContext!.findRenderObject()!,
                alignment: 0.0,
                // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  greenKey.currentContext!.findRenderObject()!,
                  alignment: 0.5,
                  // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position
                      .ensureVisible(
                    blueKey.currentContext!.findRenderObject()!,
                    alignment: 0.0,
                    // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  )
                      .then((value) {
                    scrollController!.position
                        .ensureVisible(
                      blueKey.currentContext!.findRenderObject()!,
                      alignment: 0.5,
                      // How far into view the item should be scrolled (between 0 and 1).
                      duration: const Duration(milliseconds: 200),
                    )
                        .then((value) {
                      scrollController!.position.ensureVisible(
                        orangeKey.currentContext!.findRenderObject()!,
                        alignment: 0.2,
                        // How far into view the item should be scrolled (between 0 and 1).
                        duration: const Duration(milliseconds: 200),
                      );
                    });
                  });
                });
              });
            } else if (_tabController!.previousIndex == 1) {
              scrollController!.position
                  .ensureVisible(
                blueKey.currentContext!.findRenderObject()!,
                alignment: 0.5,
                // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position.ensureVisible(
                  orangeKey.currentContext!.findRenderObject()!,
                  alignment: 0.2,
                  // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                );
              });
            }
          } else {
            scrollController!.position.ensureVisible(
              orangeKey.currentContext!.findRenderObject()!,
              alignment: 0.0,
              // How far into view the item should be scrolled (between 0 and 1).
              duration: const Duration(milliseconds: 600),
            );
          }
        }
        break;
      case 3:
        {
          if (yellowKey.currentContext == null) {
            if (_tabController!.previousIndex == 0) {
              scrollController!.position
                  .ensureVisible(
                greenKey.currentContext!.findRenderObject()!,
                alignment:
                    0.0, // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  greenKey.currentContext!.findRenderObject()!,
                  alignment:
                      0.5, // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position
                      .ensureVisible(
                    blueKey.currentContext!.findRenderObject()!,
                    alignment:
                        0.0, // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  )
                      .then((value) {
                    scrollController!.position
                        .ensureVisible(
                      blueKey.currentContext!.findRenderObject()!,
                      alignment:
                          0.5, // How far into view the item should be scrolled (between 0 and 1).
                      duration: const Duration(milliseconds: 200),
                    )
                        .then((value) {
                      scrollController!.position
                          .ensureVisible(
                        orangeKey.currentContext!.findRenderObject()!,
                        alignment:
                            0.0, // How far into view the item should be scrolled (between 0 and 1).
                        duration: const Duration(milliseconds: 200),
                      )
                          .then((value) {
                        scrollController!.position
                            .ensureVisible(
                          orangeKey.currentContext!.findRenderObject()!,
                          alignment:
                              0.5, // How far into view the item should be scrolled (between 0 and 1).
                          duration: const Duration(milliseconds: 200),
                        )
                            .then((value) {
                          scrollController!.position.ensureVisible(
                            yellowKey.currentContext!.findRenderObject()!,
                            alignment:
                                0.0, // How far into view the item should be scrolled (between 0 and 1).
                            duration: const Duration(milliseconds: 200),
                          );
                        });
                      });
                    });
                  });
                });
              });
            } else {
              scrollController!.position
                  .ensureVisible(
                blueKey.currentContext!.findRenderObject()!,
                alignment:
                    1.0, // How far into view the item should be scrolled (between 0 and 1).
                duration: const Duration(milliseconds: 200),
              )
                  .then((value) {
                scrollController!.position
                    .ensureVisible(
                  orangeKey.currentContext!.findRenderObject()!,
                  alignment:
                      0.0, // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(milliseconds: 200),
                )
                    .then((value) {
                  scrollController!.position.ensureVisible(
                    yellowKey.currentContext!.findRenderObject()!,
                    alignment:
                        0.0, // How far into view the item should be scrolled (between 0 and 1).
                    duration: const Duration(milliseconds: 200),
                  );
                });
              });
            }
          } else {
            scrollController!.position.ensureVisible(
              yellowKey.currentContext!.findRenderObject()!,
              alignment: 0.0,
              // How far into view the item should be scrolled (between 0 and 1).
              duration: const Duration(milliseconds: 800),
            );
          }
        }
        break;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
