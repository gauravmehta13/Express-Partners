import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:express_partner/OnBoarding/price.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Widgets/loading.dart';
import '../appbar.dart';
import '../constants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MandatoryKYC extends StatefulWidget {
  final bool? edit;
  final bool? data;
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

  var pin = TextEditingController();
  var city = TextEditingController();
  var state = TextEditingController();
  var address = TextEditingController();
  List<dynamic>? searchResults;
  List<dynamic>? pinResults;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool sendingData = false;
  bool kycCompleted = false;

  final formKey = GlobalKey<FormState>();
  var companyName = TextEditingController();
  var companyDescription = TextEditingController();

  List withinCity = [];
  List outStationCity = [];

  List<String?> otherImagesLink = [];
  bool uploadingImages = false;

  List _items = [];
  String? imageUrl;

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
                      await postUserInfoData();
                      setState(() {
                        sendingData = false;
                      });
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
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            uploadingImages = true;
                          });
                          imageUrl =
                              await uploadImage(folderName: "profilePhotos");
                          setState(() {
                            uploadingImages = false;
                          });
                        },
                        child: Stack(
                          children: [
                            imageUrl != null
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: NetworkImage(
                                      imageUrl ?? "",
                                    ))
                                : CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[300],
                                    child: Image.asset("assets/kyc.png"),
                                  ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  radius: 20,
                                  child: Icon(
                                    FontAwesomeIcons.camera,
                                    color: Colors.white,
                                    size: 16,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      box20,
                      const Text(
                        "Verify Your Identity   ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFc1f0dc),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              "85% customers prefer to select a service provider with a complete profile.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2f7769),
                                fontSize: 12,
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: companyName,
                        decoration: InputDecoration(
                            prefixIcon:
                                const Icon(FontAwesomeIcons.addressCard),
                            isDense: true, // Added this
                            contentPadding: const EdgeInsets.all(15),
                            focusedBorder: const OutlineInputBorder(
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
                                  controller: pin,
                                  onChanged: (p) async {
                                    var tpin = int.tryParse(p);
                                    int? count = 0, temp = tpin;
                                    while (temp! > 0) {
                                      count = count! + 1;
                                      temp = (temp / 10).floor();
                                    }
                                    print(count);

                                    if (count == 6) {
                                      setState(() {
                                        gettingPin = true;
                                      });
                                      searchpin(p);
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
                                  controller: address,
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
                          if (pinResults != null && pinResults!.length != 0)
                            getSuggestions(pinResults!, "Pickup"),
                          if (searchResults != null &&
                              searchResults!.length != 0)
                            getSuggestions(searchResults!, "Pickup"),
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
                        initialValue: withinCity,
                        buttonText: Text(
                          "Select Within Cities",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        title: Text("Cities where your business is located"),
                        items: _items as List<MultiSelectItem>,
                        onSelectionChanged: (values) {
                          setState(() {
                            withinCity = values;
                          });
                        },
                        onConfirm: (values) {
                          setState(() {
                            withinCity = values;
                          });
                        },
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (dynamic value) {
                            setState(() {
                              withinCity.remove(value);
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
                      box5,
                      MultiSelectBottomSheetField(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        initialChildSize: 0.5,
                        listType: MultiSelectListType.CHIP,
                        searchable: true,
                        initialValue: outStationCity,
                        buttonText: Text(
                          "Select Outstation Cities",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        title: Text("Cities where your business is located"),
                        items: _items as List<MultiSelectItem>,
                        onSelectionChanged: (values) {
                          setState(() {
                            outStationCity = values;
                          });
                        },
                        onConfirm: (values) {
                          setState(() {
                            outStationCity = values;
                          });
                        },
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (dynamic value) {
                            setState(() {
                              outStationCity.remove(value);
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
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              uploadingImages = true;
                            });
                            setState(() async {
                              otherImagesLink = await uploadMultiImages(
                                  folderName: "OtherPhotos");
                              uploadingImages = false;
                            });
                          },
                          child: Text("Upload Business images")),
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
                                otherImagesLink[index] ?? "",
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

  postUserInfoData() async {
    Map<String, dynamic> data = {
      "uid": _auth.currentUser!.uid,
      "localCities": withinCity,
      "outstationCities": outStationCity,
      "about": {
        "mobile": _auth.currentUser!.phoneNumber,
        "businessName": companyName.text,
        "about": companyDescription.text,
        "pin": pin.text,
        "area": address.text,
        "city": city.text,
        "state": state.text,
        "imgUrl": imageUrl,
        "otherImages": otherImagesLink
      },
      "localPricing": {},
      "outstationPricing": {}
    };
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var database = await firebaseFirestore
        .collection("vendors")
        .doc(_auth.currentUser!.uid)
        .set(data)
        .then((value) => Get.to(() => AllPrices()))
        .onError((error, stackTrace) {
      log(error.toString());
    });
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
                      address.text = suggestions[index]["Name"];
                      pin.text = suggestions[index]["Pincode"];
                      city.text = suggestions[index]["Division"];
                      state.text = suggestions[index]["State"];
                    });

                    print(suggestions[index]);
                    setState(() {
                      suggestions = [];
                      pinResults = null;
                      searchResults = null;
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
        address.text = resp.data["address"]["county"];
        pin.text = resp.data["address"]["postcode"];
        city.text = resp.data["address"]["state_district"];
        state.text = resp.data["address"]["state"];
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
    searchResults = await getAreaData(searchTerm);
    setState(() {
      searchResults = searchResults;
    });
    print(searchResults);
  }

  searchpin(String pin) async {
    pinResults = await getPinData(pin);
    setState(() {
      pinResults = pinResults;
      gettingPin = false;
    });
    print(pinResults);
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

Future<List<String>> uploadMultiImages({String folderName = ""}) async {
  try {
    List<XFile>? images = await ImagePicker().pickMultiImage();
    List<String> imageUrls = [];

    if (images == null) {
      return [];
    }
    images.forEach((image) async {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(folderName)
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      UploadTask uploadTask;

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': image.path});

      if (kIsWeb) {
        uploadTask = ref.putData(await image.readAsBytes(), metadata);
      } else {
        uploadTask = ref.putFile(File(image.path));
      }

      TaskSnapshot storageTaskSnapshot = await uploadTask;

      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    });
    return imageUrls;
  } catch (e) {
    Get.snackbar("Error", e.toString());
    return [];
  }
}
