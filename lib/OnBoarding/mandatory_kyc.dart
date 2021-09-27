import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:mime/mime.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Screens/review_screen.dart';
import '../Widgets/loading.dart';
import '../appbar.dart';
import '../constants.dart';
import '../fade_route.dart';
import '../model/place_search.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MandatoryKYC extends StatefulWidget {
  final edit;
  final data;
  MandatoryKYC({this.edit, this.data});
  @override
  _MandatoryKYCState createState() => _MandatoryKYCState();
}

class _MandatoryKYCState extends State<MandatoryKYC> {
  loc.Location location = loc.Location();
  String? lat;
  String? lng;
  late bool _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  late loc.LocationData _locationData;
  var dio = Dio();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = true;
  bool sendingData = false;
  bool kycCompleted = false;
  bool? userDetails = true;
  List<PlaceSearch>? pickupSearchResults;
  final formKey = GlobalKey<FormState>();
  var area = TextEditingController();
  var companyName = TextEditingController();
  var streetAddress = TextEditingController();
  var gstNo = TextEditingController();
  var companyDescription = TextEditingController();
  var websiteLink = TextEditingController();
  var pointOfContactName = TextEditingController();
  var pointOfContactNumber = TextEditingController();
  List baseCity = [];

  GlobalKey<EnsureVisibleState>? ensureKey;

  PlatformFile? displayImage;
  String? displayImageLink;
  PlatformFile? incorporationCertificate;
  String? incorporationCertificateLink;
  List<PlatformFile>? otherImages = [];
  List<String?> otherImagesLink = [];
  bool uploadingImages = false;
  bool tappedOnCatalog = false;

  List _items = [];

  @override
  void initState() {
    super.initState();

    _items = cities
        .map((i) => MultiSelectItem<dynamic>(
              i,
              i,
            ))
        .toList();
    ensureKey = GlobalKey<EnsureVisibleState>();
    getProgress();
    if (widget.data != null) {
      prefillData();
    }
    logEvent("KYC_Screen");
  }

  prefillData() {
    companyName.text = widget.data["Business Name"];
    streetAddress.text = widget.data["Address"];
  }

  getKycData() async {
    try {
      final response = await dio.get(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?tenantSet_id=PAM01&tenantUsecase=pam&type=packersAndMoversSP&id=${_auth.currentUser!.uid}',
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  getProgress() async {
    _getUserLocation();
    try {
      final response = await dio.get(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser!.uid}');

      Map<String, dynamic> map = json.decode(response.toString());
      print(map);
      if (map['resp']['Items'] != null) {
        if (map['resp']['Items'][0]['selfInfo'].length != 0) {
          var info = map['resp']['Items'][0]['selfInfo'];
          setState(() {
            companyName.text = info["companyName"];
            companyDescription.text = info["companyDescription"];
            area.text = info["area"];
            streetAddress.text = info["street"];
            gstNo.text = info["gstNo"];
            websiteLink.text = info["website"];
            loading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        }
        print(map['resp']['Items'][0]['selfInfo']);
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchWhatsApp();
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        backgroundColor: Color(0xFF25D366),
        child: FaIcon(FontAwesomeIcons.whatsapp),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFf9a825), // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: loading == true || uploadingImages == true
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      // if (!tappedOnCatalog) {
                      //   // FeatureDiscovery.clearPreferences(context, <String>{
                      //   //   '1',
                      //   // });
                      //   FeatureDiscovery.discoverFeatures(
                      //     context,
                      //     const <String>{
                      //       '1',
                      //     },
                      //   );
                      //   return;
                      // }
                      setState(() {
                        sendingData = true;
                      });
                      postUserInfoData();
                    }
                  },
            child: sendingData == true || uploadingImages == true
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
          child: MyAppBar(curStep: 1)),
      body: loading
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Loading())
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 60, child: Image.asset("assets/kyc.png")),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Verify Your Identity   ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "85% customers prefer to select a service provider with a complete profile.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2f7769),
                                fontSize: 12,
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: companyName,
                        decoration: InputDecoration(
                            prefixIcon: Icon(FontAwesomeIcons.addressCard),
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
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!)),
                            labelText: "Name of Company*"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      box20,
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: area,
                        onChanged: (value) {
                          //  searchPickup(value);
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.gps_fixed),
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
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!)),
                            labelText: "Area*"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: streetAddress,
                                decoration: InputDecoration(
                                    isDense: true, // Added this
                                    prefixIcon: Icon(FontAwesomeIcons.building),
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Color(0xFF2821B5),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!)),
                                    labelText: "Street Address*"),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MultiSelectBottomSheetField(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(5)),
                                initialChildSize: 0.5,
                                listType: MultiSelectListType.CHIP,
                                searchable: true,
                                initialValue: baseCity,
                                buttonText: Text(
                                  "Select Base Cities",
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                title: Text(
                                    "Cities where your business is located"),
                                items: _items as List<MultiSelectItem>,
                                onSelectionChanged: (values) {
                                  setState(() {
                                    baseCity = values;
                                    baseLocation = values;
                                  });
                                },
                                onConfirm: (values) {
                                  setState(() {
                                    baseCity = values;
                                    baseLocation = values;
                                  });
                                },
                                chipDisplay: MultiSelectChipDisplay(
                                  onTap: (dynamic value) {
                                    setState(() {
                                      baseCity.remove(value);
                                      baseLocation!.remove(value);
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select base cities';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Upload Display Image :",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  displayImage == null
                                      ? RawMaterialButton(
                                          onPressed: () async {
                                            await getDisplayImage();
                                            setState(() {
                                              displayImage = displayImage;
                                            });
                                          },
                                          elevation: 0,
                                          fillColor: Color(0xFFf9a825),
                                          child: Icon(
                                            FontAwesomeIcons.camera,
                                            size: 20.0,
                                          ),
                                          padding: EdgeInsets.all(10.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))
                                      : GestureDetector(
                                          onTap: () async {
                                            await getDisplayImage();
                                            setState(() {
                                              displayImage = displayImage;
                                            });
                                          },
                                          child: Icon(Icons.done),
                                        ),
                                ],
                              ),
                            ],
                          ),
                          if (pickupSearchResults != null &&
                              pickupSearchResults!.length != 0)
                            Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.white)),
                          if (pickupSearchResults != null)
                            Container(
                              height: 200,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: pickupSearchResults!.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[100]!))),
                                      child: ListTile(
                                        dense: true,
                                        title: Text(
                                          pickupSearchResults![index]
                                              .description!,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            area.text =
                                                pickupSearchResults![index]
                                                    .description!;

                                            //pickupSearchResults[index].placeId
                                          });
                                          print(pickupSearchResults![index]);
                                          // _getPincode(
                                          //     pickupSearchResults[index].placeId);
                                          setState(() {
                                            pickupSearchResults = null;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                      box20,
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: DescribedFeatureOverlay(
                            featureId: '1',
                            targetColor: Colors.white,
                            textColor: Colors.white,
                            backgroundColor: primaryColor,
                            onOpen: () async {
                              WidgetsBinding.instance!
                                  .addPostFrameCallback((_) {
                                ensureKey!.currentState!.ensureVisible(
                                  preciseAlignment: 0.5,
                                  duration: const Duration(milliseconds: 400),
                                );
                              });
                              return true;
                            },
                            // ignore: missing_return
                            // onBackgroundTap: () {
                            //   FeatureDiscovery.dismissAll(context);
                            //   showCatalog();
                            // },

                            contentLocation: ContentLocation.below,
                            title: Text(
                              'Build Your Own Catalog',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  backgroundColor: primaryColor),
                            ),
                            overflowMode: OverflowMode.ignore,
                            description: Text(
                              'Add business images and description so that customers will know more about you.',
                              style: TextStyle(
                                  backgroundColor: primaryColor, fontSize: 13),
                            ),
                            tapTarget: IconButton(
                              onPressed: () {
                                FeatureDiscovery.dismissAll(context);
                                showCatalog();
                              },
                              icon: Icon(Icons.add),
                            ),

                            child: EnsureVisible(
                              key: ensureKey,
                              child: TextButton(
                                  onPressed: () {
                                    showCatalog();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Color(0xFF3f51b5),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Build your own catalog",
                                        style: TextStyle(
                                          color: Color(0xFF3f51b5),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          )),
                      Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "Building your own catalog will help you target more customers",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2f7769),
                                fontSize: 12,
                              ),
                            ),
                          )),
                      box20,
                      Container(
                        height: 100,
                        child: ListView.builder(
                          itemCount: otherImagesLink.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width / 3,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Image.network(
                                "https://goflexe-kyc.s3.ap-south-1.amazonaws.com/${otherImagesLink[index]}",
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
            ),
    );
  }

  showCatalog() {
    setState(() {
      tappedOnCatalog = true;
    });
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height - 200,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                  ),
                  C.box20,
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: companyDescription,
                    decoration: InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF2821B5),
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        labelText: "Description of Company*"),
                  ),
                  box20,
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: gstNo,
                    decoration: InputDecoration(
                        isDense: true, // Added this

                        contentPadding: EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF2821B5),
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        labelText: "GST (Optional)"),
                  ),
                  box20,
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: websiteLink,
                    decoration: InputDecoration(
                        prefixText: "https:// ",
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF2821B5),
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        labelText: "Website link"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "Incorporation Certificate :\n(Optional)",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      incorporationCertificate == null
                          ? RawMaterialButton(
                              onPressed: () {
                                getIncorporationCertificate();
                              },
                              elevation: 0,
                              fillColor: Color(0xFFf9a825),
                              child: ImageIcon(AssetImage("assets/upload.png")),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)))
                          : GestureDetector(
                              onTap: () {
                                getIncorporationCertificate();
                              },
                              child: Icon(Icons.done))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text("Other images showing business :"),
                      SizedBox(
                        width: 20,
                      ),
                      otherImages!.length != 0
                          ? GestureDetector(
                              onTap: () async {
                                await getOtherImages();
                                setState(() {
                                  otherImages = otherImages;
                                });
                              },
                              child: Icon(Icons.done))
                          : RawMaterialButton(
                              onPressed: () async {
                                await getOtherImages();
                                setState(() {
                                  otherImages = otherImages;
                                });
                              },
                              elevation: 0,
                              fillColor: Color(0xFFf9a825),
                              child: Icon(
                                FontAwesomeIcons.camera,
                                size: 20.0,
                              ),
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.all(0),
                    dense: true,
                    title: const Text(
                      'Are you the point of contact for customer orders?',
                      style: TextStyle(fontSize: 12),
                    ),
                    autofocus: false,
                    activeColor: Color(0xFF3f51b5),
                    checkColor: Colors.white,
                    selected: userDetails!,
                    value: userDetails,
                    onChanged: (bool? value) {
                      setState(() {
                        userDetails = value;
                      });
                    },
                  ),
                  if (userDetails == false)
                    Column(children: [
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: pointOfContactName,
                        decoration: InputDecoration(
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
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!)),
                            labelText: "Name"),
                      ),
                      box20,
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: pointOfContactNumber,
                        decoration: InputDecoration(
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
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!)),
                            labelText: "Contact Number"),
                      ),
                    ]),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'OKAY',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3f51b5)),
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
            );
          });
        });
  }

  void _getUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print(_locationData.latitude.toString());
    print(_locationData.longitude.toString());
    setState(() {
      lat = _locationData.latitude.toString();
      lng = _locationData.longitude.toString();
    });
    getCity(lat.toString(), lng.toString());
  }

  getCity(lat, lon) async {
    var dio = Dio();
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon");
    print(resp.data);
    setState(() {
      area.text = resp.data["display_name"];
      // baseCity.add(resp.data["address"]["state_district"]);
    });
  }

  postUserInfoData() async {
    Map<String, dynamic> data = {
      "uid": _auth.currentUser!.uid,
      "mobile": _auth.currentUser!.phoneNumber,
      "baseCity": baseCity,
      "smsOnboarding": widget.data != null ? true : false,
      "companyName": companyName.text,
      "address": "${streetAddress.text}, ${area.text}",
      "area": area.text,
      "street": streetAddress.text,
      "gstNo": gstNo.text,
      "companyDescription": companyDescription.text,
      "website": websiteLink.text,
      "contactName": pointOfContactName.text,
      "contactMobile": pointOfContactNumber.text
    };
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var database = await firebaseFirestore
        .collection("accounts")
        .doc(_auth.currentUser!.uid)
        .set(data)
        .onError((error, stackTrace) => print(error));
    Navigator.push(
      context,
      FadeRoute(
          page: ReviewScreen(
        done: widget.edit != null ? "done" : null,
      )),
    );
    return database;
  }

  getIncorporationCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
      type: FileType.custom,
    );
    if (result != null) {
      print(result);
      print(result.files);
      print(result.files.single);
      print(result.files.single.name);
      print(result.files.single.size);
      print(result.files.single.path);
      setState(() {
        // print(paths.first.extension);
        // fileName = paths != null ? paths.map((e) => e.name).toString() : '...';
        // print(fileName);
      });
      setState(() {
        incorporationCertificate = result.files.single;
      });
      uploadIncorpCertificate();
    } else {
      // User canceled the picker
    }
  }

  getDisplayImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      allowedExtensions: ["jpg"],
      type: FileType.custom,
    );
    if (result != null) {
      setState(() {
        displayImage = result.files.single;
      });
      uploadDisplayImage();
    } else {
      // User canceled the picker
    }
  }

  getOtherImages() async {
    try {
      otherImages = (await FilePicker.platform.pickFiles(
        withReadStream: true,
        allowMultiple: true,
        allowedExtensions: ["jpg"],
        type: FileType.custom,
      ))
          ?.files;
      setState(() {
        otherImages = otherImages;
      });
      print(otherImages!.length);
      uploadOtherImages();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
  }

  uploadIncorpCertificate() async {
    setState(() {
      uploadingImages = true;
    });
    final mimeType = lookupMimeType(incorporationCertificate!.name);
    print(mimeType);

    await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
        data: {
          "contentType": mimeType,
          "metaData": {
            "contentType": mimeType,
          },
        }).then((response) async {
      Map<String, dynamic> map = json.decode(response.toString());

      setState(() {
        incorporationCertificateLink = map['key'];
      });
      print(incorporationCertificateLink);

      dio.put(
        map['s3PutObjectUrl'],
        data: incorporationCertificate!.readStream,
        options: Options(
          contentType: mimeType,
          headers: {"Content-Length": incorporationCertificate!.size},
        ),
        onSendProgress: (int sentBytes, int totalBytes) {
          double progressPercent = sentBytes / totalBytes * 100;
          print("$progressPercent %");
        },
      ).then((response) {
        print(response);
        print(response.statusCode);
        dio.post(
            'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
            data: {
              "type": "packersAndMoversSP",
              "id": _auth.currentUser!.uid,
              "mobile": _auth.currentUser!.phoneNumber,
              "tenantUsecase": "pam",
              "tenantSet_id": "PAM01",
              "incorporationCertificate":
                  incorporationCertificateLink.toString()
            }).then((response) {
          print(response);
          setState(() {
            uploadingImages = false;
          });
        });
      }).catchError((error) {
        setState(() {
          uploadingImages = false;
        });
        print(error);
      });
    });
  }

  uploadDisplayImage() async {
    setState(() {
      uploadingImages = true;
    });
    final mimeType = lookupMimeType(displayImage!.name);
    await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
        data: {
          "contentType": mimeType,
          "metaData": {
            "contentType": mimeType,
          },
        }).then((response) async {
      print(response);
      Map<String, dynamic> map = json.decode(response.toString());
      setState(() {
        displayImageLink = map['key'];
      });
      print(displayImageLink);
      print(mimeType);

      dio.put(
        map['s3PutObjectUrl'],
        data: displayImage!.readStream,
        options: Options(
          contentType: mimeType,
          headers: {
            "Content-Length": displayImage!.size,
          },
        ),
        onSendProgress: (int sentBytes, int totalBytes) {
          double progressPercent = sentBytes / totalBytes * 100;
          print("$progressPercent %");
        },
      ).then((response) {
        print(response);
        print(response.statusCode);
        dio.post(
            'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
            data: {
              "type": "packersAndMoversSP",
              "id": _auth.currentUser!.uid,
              "mobile": _auth.currentUser!.phoneNumber,
              "tenantUsecase": "pam",
              "tenantSet_id": "PAM01",
              "displayImage": displayImageLink.toString()
            }).then((response) {
          print(response);
        });
        dio.post(
            'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
            data: {
              "serviceProviderId": _auth.currentUser!.uid,
              "mobile": _auth.currentUser!.phoneNumber,
              "tenantUsecase": "pam",
              "tenantSet_id": "PAM01",
              "selfInfo": {"displayImage": displayImageLink.toString()}
            }).then((value) => print(value));
        print(response);
        setState(() {
          uploadingImages = false;
        });
      }).catchError((error) {
        setState(() {
          uploadingImages = false;
        });
        print(error);
      });
    });
  }

  uploadOtherImages() async {
    for (var i = 0; i < otherImages!.length; i++) {
      setState(() {
        uploadingImages = true;
      });
      final mimeType = lookupMimeType(otherImages![i].name);
      await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/document?type=packersAndMovers',
          data: {
            "contentType": mimeType,
            "metaData": {
              "contentType": mimeType,
            },
          }).then((response) async {
        print(response);
        Map<String, dynamic> map = json.decode(response.toString());
        setState(() {
          otherImagesLink.add(map['key']);
        });
        print(otherImagesLink[i]);
        dio.put(
          map['s3PutObjectUrl'],
          data: otherImages![i].readStream,
          options: Options(
            contentType: mimeType,
            headers: {
              "Content-Length": otherImages![i].size,
            },
          ),
          onSendProgress: (int sentBytes, int totalBytes) {
            double progressPercent = sentBytes / totalBytes * 100;
            print("$progressPercent %");
          },
        ).then((response) {
          print(response);

          print(response.statusCode);
        }).catchError((error) {
          setState(() {
            uploadingImages = false;
          });
          print(error);
        });
      });
    }
    dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
        data: {
          "type": "packersAndMoversSP",
          "id": _auth.currentUser!.uid,
          "mobile": _auth.currentUser!.phoneNumber,
          "tenantUsecase": "pam",
          "tenantSet_id": "PAM01",
          "otherImages": otherImagesLink
        }).then((response) {
      print(response);
      setState(() {
        uploadingImages = false;
      });
    });
  }
}
