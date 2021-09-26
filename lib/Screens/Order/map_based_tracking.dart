import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants.dart';
import 'tracking.dart';

class FlutterMap extends StatefulWidget {
  final data;
  FlutterMap({required this.data});
  @override
  _FlutterMapState createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap> {
  bool isLoading = true;
  Marker? marker;
  Circle? circle;
  bool locationUnavailable = false;
  GoogleMapController? _controller;
  double? latitude = 0;
  double? longitude = 0;

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(lat, long, imageData, rotation, accuracy
      // Loc.LocationData newLocalData, Uint8List imageData
      ) {
    LatLng latlng = LatLng(lat, long);
    setState(() {
      _initialPosition = LatLng(lat, long);
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: double.parse(rotation.toString()),
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: double.parse(accuracy.toString()),
          zIndex: 1,
          strokeWidth: 2,
          strokeColor: C.primaryColor,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  Timer? timer;
  int apiCall = 0;

  setProgress() async {
    if (_controller != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(latitude!, longitude!),
              tilt: 0,
              zoom: 18.00)));
    }
  }

  getProgress() async {
    Uint8List imageData = await getMarker();
    var dio = Dio();
    final response = await dio.get(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceorder/livetrack?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceOrderId&serviceOrderId=${widget.data["ServiceOrderId"]}');

    Map<String, dynamic> map = json.decode(response.toString());
    print(map);
    if (map["resp"]["Items"].length == 0 ||
        map["resp"]["Items"][0]["lat"] == null) {
      setState(() {
        locationUnavailable = true;
      });
    } else {
      Map<String, dynamic> data = map["resp"]["Items"][0];
      print(data);
      setState(() {
        latitude = data["lat"];
        longitude = data["long"];
      });
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(data["lat"], data["long"]),
                tilt: 0,
                zoom: 18.00)));
      }
      updateMarkerAndCircle(data["lat"], data["long"], imageData,
          data["heading"], data["accuracy"]);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /////////
  GoogleMapController? mapController;
  //  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController dropLocationController = TextEditingController();
  static LatLng? _initialPosition;
  LatLng? _lastPosition = _initialPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polyLines = {};
  var webLocation;
  bool route = false;
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();
    getProgress();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (latitude != 0) {
        setProgress();
      }
    });
    logEvent("Tracking");
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    return Scaffold(
        body: SafeArea(
      child: isLoading == true
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Stack(children: [
              Column(
                children: [
                  if (locationUnavailable == true)
                    Expanded(
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/tracking.png",
                            height: 100,
                            width: 100,
                          ),
                          C.box30,
                          Text(
                            "Driver Location Unavailable",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          )
                        ],
                      )),
                    )
                  else
                    Expanded(
                      child: _initialPosition == null
                          ? Container(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Container(
                              child: GoogleMap(
                                //  initialCameraPosition: initialLocation,
                                markers:
                                    Set.of((marker != null) ? [marker!] : []),
                                circles:
                                    Set.of((circle != null) ? [circle!] : []),
                                onMapCreated: (GoogleMapController controller) {
                                  _controller = controller;
                                },
                                initialCameraPosition: CameraPosition(
                                    target: _initialPosition!, zoom: 14),
                                // onMapCreated: onCreated,
                                // myLocationEnabled: true,
                                // myLocationButtonEnabled: true,
                                zoomControlsEnabled: false,
                                compassEnabled: false,
                                // markers: _markers,
                                onCameraMove: _onCameraMove,
                                polylines: _polyLines,
                              ),
                            ),
                    ),
                  Container(
                    height: (MediaQuery.of(context).size.height / 2) - 30,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Tracking(
                  data: widget.data,
                ),
              ),
              Positioned(
                  top: 30,
                  left: 30,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: C.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ]),
    ));
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _addMarker(LatLng location, String address) {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastPosition.toString()),
          position: location,
          infoWindow: InfoWindow(title: address, snippet: "Drop Location"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  void createRoute(String encodedPoly) {
    setState(() {
      route = true;
      _polyLines.add(Polyline(
          polylineId: PolylineId(_lastPosition.toString()),
          width: 2,
          color: Color(0xFF3f51b5),
          points: convertToLatLng(decodePoly(encodedPoly))));
    });
  }

// will convert list of double into LatLng
  List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void clearMap() {
    setState(() {
      _markers = {};
      _polyLines = {};
    });
  }
}
