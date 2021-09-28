import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Screens/review_screen.dart';
import '../Widgets/loading.dart';
import '../appbar.dart';
import '../constants.dart';
import '../fade_route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MandatoryKYC extends StatefulWidget {
  final edit;
  final data;
  const MandatoryKYC({Key? key, this.edit, this.data}) : super(key: key);
  @override
  _MandatoryKYCState createState() => _MandatoryKYCState();
}

class _MandatoryKYCState extends State<MandatoryKYC> {
  bool gettingPin = false;
  bool gettingAddress = false;
  Location location = Location();
  double? latitude;
  double? longitude;
  late bool _serviceEnabled;
  PermissionStatus? _permissionGranted;
  late LocationData _locationData;
  var dio = Dio();

  var pickupArea = TextEditingController();
  var pickupPin = TextEditingController();
  var pickupCity = TextEditingController();
  var pickupState = TextEditingController();
  var pickupStreetAddress = TextEditingController();
  List<dynamic>? pickupSearchResults;
  List<dynamic>? pickupPinResults;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = true;
  bool sendingData = false;
  bool kycCompleted = false;
  bool? userDetails = true;
  final formKey = GlobalKey<FormState>();

  var companyName = TextEditingController();

  var gstNo = TextEditingController();
  var companyDescription = TextEditingController();
  var websiteLink = TextEditingController();
  var pointOfContactName = TextEditingController();
  var pointOfContactNumber = TextEditingController();
  List baseCity = [];

  PlatformFile? displayImage;
  String? displayImageLink;
  PlatformFile? incorporationCertificate;
  String? incorporationCertificateLink;
  List<PlatformFile>? otherImages = [];
  List<String?> otherImagesLink = [];
  bool uploadingImages = false;
  bool tappedOnCatalog = false;

  var pickupAddress = TextEditingController();

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

    _getUserLocation();
    logEvent("KYC_Screen");
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
        backgroundColor: const Color(0xFF25D366),
        child: const FaIcon(FontAwesomeIcons.whatsapp),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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

                      setState(() {
                        sendingData = true;
                      });
                      postUserInfoData();
                    }
                  },
            child: sendingData == true || uploadingImages == true
                ? Column(
                    children: const [
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
                        controller: companyDescription,
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
                            labelText: "Description of Company*"),
                      ),
                      box20,
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                  controller: pickupPin,
                                  onChanged: (pin) async {
                                    var pickupPin = int.tryParse(pin);
                                    int? count = 0, temp = pickupPin;
                                    while (temp! > 0) {
                                      count = count! + 1;
                                      temp = (temp / 10).floor();
                                    }
                                    print(count);

                                    if (count == 6) {
                                      setState(() {
                                        gettingPin = true;
                                      });
                                      searchPickupPin(pin);
                                    }
                                  },
                                  scrollPadding:
                                      const EdgeInsets.only(bottom: 150.0),
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    suffix: gettingPin
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator())
                                        : SizedBox.shrink(),
                                    isDense: true,
                                    counterText: "",
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
                                            BorderSide(color: Colors.grey)),
                                    labelText: "Pin Code",
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                  scrollPadding:
                                      const EdgeInsets.only(bottom: 150.0),
                                  controller: pickupAddress,
                                  onChanged: (value) {
                                    searchPickup(value);
                                  },
                                  decoration: textfieldDecoration(
                                      "Area / Colony", "Search Area"),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          if (pickupPinResults != null &&
                              pickupPinResults!.length != 0)
                            getSuggestions(pickupPinResults!, "Pickup"),
                          if (pickupSearchResults != null &&
                              pickupSearchResults!.length != 0)
                            getSuggestions(pickupSearchResults!, "Pickup"),
                          box20,
                        ],
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
                          "Select Serving Cities",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        title: Text("Cities where your business is located"),
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
                      TextButton(
                          onPressed: () {
                            showCatalog();
                          },
                          child: Row(
                            children: const [
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
                      Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                      Text("Other images showing business :"),
                      SizedBox(
                        width: 20,
                      ),
                      otherImages!.length != 0
                          ? GestureDetector(
                              onTap: () async {
                                setState(() {
                                  otherImages = otherImages;
                                });
                              },
                              child: Icon(Icons.done))
                          : RawMaterialButton(
                              onPressed: () async {
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

  postUserInfoData() async {
    Map<String, dynamic> data = {
      "uid": _auth.currentUser!.uid,
      "mobile": _auth.currentUser!.phoneNumber,
      "baseCity": baseCity,
      "smsOnboarding": widget.data != null ? true : false,
      "companyName": companyName.text,
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

  Widget getSuggestions(List suggestions, String type) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200.0,
      ),
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
              child: ListTile(
                  dense: true,
                  title: Text(
                    suggestions[index]["Name"],
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    getLatLng(suggestions[index]["Pincode"], type);

                    FocusScope.of(context).unfocus();

                    setState(() {
                      pickupAddress.text = suggestions[index]["Name"];
                      pickupPin.text = suggestions[index]["Pincode"];
                      pickupCity.text = suggestions[index]["Division"];
                      pickupState.text = suggestions[index]["State"];
                    });

                    print(suggestions[index]);
                    setState(() {
                      suggestions = [];
                      pickupPinResults = null;
                      pickupSearchResults = null;
                    });
                  }),
            );
          }),
    );
  }

  void _getUserLocation() async {
    setState(() {
      gettingAddress = true;
    });
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          gettingAddress = false;
        });
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          gettingAddress = false;
        });
        return;
      }
    }
    _locationData = await location.getLocation();
    print(_locationData.latitude.toString());
    print(_locationData.longitude.toString());
    setState(() {
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
    });

    getCity(
        _locationData.latitude.toString(), _locationData.longitude.toString());
  }

  getLatLng(pin, type) async {
    setState(() {
      longitude = null;
    });
    final resp = await dio.get(
        "https://nominatim.openstreetmap.org/search?format=json&postalcode=$pin&country=india");
    print(resp.data);
    var map = resp.data[0];
    setState(() {
      latitude = double.tryParse(map["lat"]);
      longitude = double.tryParse(map["lon"]);
    });
    print(latitude);
  }

  getCity(lat, lon) async {
    try {
      final resp = await dio.get(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon");
      print(resp.data);
      setState(() {
        pickupAddress.text = resp.data["address"]["county"];
        pickupPin.text = resp.data["address"]["postcode"];
        pickupCity.text = resp.data["address"]["state_district"];
        pickupState.text = resp.data["address"]["state"];
        gettingAddress = false;
      });
    } catch (e) {
      setState(() {
        gettingAddress = false;
      });
    }
  }

  Future<List<dynamic>?> getAreaData(String search) async {
    final response = await dio.get(
      "https://api.postalpincode.in/postoffice/$search",
    );
    print(response.data);
    var map = response.data[0]["PostOffice"];

    print(map);
    return map;
  }

  Future<List<dynamic>?> getPinData(pin) async {
    FocusScope.of(context).unfocus();
    var response = await dio.get("https://api.postalpincode.in/pincode/$pin");
    print(response.data);
    var data = response.data;
    return data[0]["PostOffice"];
  }

  searchPickup(String searchTerm) async {
    pickupSearchResults = await getAreaData(searchTerm);
    setState(() {
      pickupSearchResults = pickupSearchResults;
    });
    print(pickupSearchResults);
  }

  searchPickupPin(String pin) async {
    pickupPinResults = await getPinData(pin);
    setState(() {
      pickupPinResults = pickupPinResults;
      gettingPin = false;
    });
    print(pickupPinResults);
  }
}

textfieldDecoration(label, hint) {
  return InputDecoration(
      isDense: true,
      counterText: "",
      contentPadding: EdgeInsets.all(15),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFF2821B5),
        ),
      ),
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      labelText: label,
      hintText: hint);
}
