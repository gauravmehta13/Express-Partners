import 'dart:convert';
import 'dart:math';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import 'map_based_tracking.dart';
import 'order_details.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Place {
  bool isSelected;
  final String title;
  Place(
    this.isSelected,
    this.title,
  );
}

class PlaceSelection extends StatelessWidget {
  final Place _item;
  PlaceSelection(this._item);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _item.isSelected ? Color(0xFF3f51b5) : Colors.transparent,
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: Center(
        child: Text(_item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _item.isSelected ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  DateTime today = new DateTime.now();
  List<Place> place = [];
  Random random = new Random();
  List orders = [];
  List filteredOrders = [];
  bool isLoading = false;
  Place? selectedPlace;
  var dio = Dio();
  @override
  void initState() {
    super.initState();
    place.add(new Place(true, 'All'));
    place.add(new Place(false, 'Processing'));
    place.add(new Place(false, 'Delivered'));
    fetchOrders();
    logEvent("My_Orders");
  }

  fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
      });

      var url =
          "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceorder?tenantSet_id=PAM01&tenantUsecase=pam&username=${_auth.currentUser!.uid}";
      print(url);
      final response = await dio.get(url,
          options: Options(
            responseType: ResponseType.plain,
          ));

      List items = json.decode(response.toString());
      print(items);

      for (var i = 0; i < items.length; i++) {
        var url =
            "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=getProcess&orderId=${items[i]["ServiceOrderId"]}";
        print(url);
        final response = await dio.get(url,
            options: Options(
              responseType: ResponseType.plain,
            ));
        var map = json.decode(response.toString());
        var progress = getCurrentStage(map);
        items[i]["trackingData"] = map;
        items[i]["progress"] = progress;
        items[i]["loading"] = false;
        print("object$i");
      }
      print("object");

      items
          .sort((a, b) => b["progress"].length.compareTo(a["progress"].length));
      setState(() {
        orders = items;
        filteredOrders = orders;
        isLoading = false;
      });
      print(filteredOrders);
      print(filteredOrders.length);
    } catch (e) {
      print(e);
      displaySnackBar("Error! Please Try Again Later", context);
    }
  }

  assignDriver(data, i) async {
    try {
      print(data["trackingData"]["processId"].toString());
      print(data["trackingData"]["stages"][0]["stageId"].toString());
      print(data["trackingData"]["stages"][0]["tasks"][0]["taskId"].toString());
      print(data["trackingData"]["driverName"].toString());
      print(data["trackingData"]["deliveryDate"].toString());
      print(data["trackingData"]["pickupDate"].toString());
      print(data["trackingData"]["driverNumber"].toString());
      setState(() {
        orders[i]["loading"] = true;
      });
      var url =
          "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=updateCustomFields";
      final response = await dio.patch(
        url,
        data: {
          "trackingId": data["trackingData"]["processId"].toString(),
          "stageId": data["trackingData"]["stages"][0]["stageId"].toString(),
          "taskId": data["trackingData"]["stages"][0]["tasks"][0]["taskId"]
              .toString(),
          "custom": {
            "data": {
              "driverName": data["trackingData"]["driverName"].toString(),
              "contactNo": data["trackingData"]["driverNumber"].toString(),
              "pickupDate": data["trackingData"]["pickupDate"].toString(),
              "deliveryDate": data["trackingData"]["deliveryDate"].toString(),
            },
          },
        },
      ).then((value) => changeTask(data, i));
      print(response);
    } catch (e) {
      print(e);
      displaySnackBar("Error! Please Try Again Later", context);
    }
  }

  changeTask(data, i) async {
    try {
      var url =
          "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=changeTaskStatus";
      final response = await dio.patch(
        url,
        data: {
          "trackingId": data["trackingData"]["processId"].toString(),
          "stageId": data["trackingData"]["stages"][0]["stageId"].toString(),
          "taskId": data["trackingData"]["stages"][0]["tasks"][0]["taskId"]
              .toString(),
          "status": "NEXT",
        },
      ).then((value) => postDriverData(data, i));
      print(response);
    } catch (e) {
      print(e);
      displaySnackBar("Error! Please Try Again Later", context);
    }
  }

  postDriverData(data, i) async {
    try {
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceorder/livetrack',
          data: {
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "item": {
              "customerOrderId": data["customerOrderId"],
              "serviceOrderId": data["ServiceOrderId"],
              "phone-number": data["trackingData"]["driverNumber"].toString()
            }
          }).then((value) => setProgress(i));
      setState(() {
        orders[i]["loading"] = false;
      });
      displaySnackBar("Driver Assiged Successfully", context);
    } catch (e) {
      print(e);
      displaySnackBar("Error! Please Try Again Later", context);
    }
  }

  setProgress(i) async {
    try {
      var url =
          "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=getProcess&orderId=${orders[i]["ServiceOrderId"]}";
      print(url);
      final response = await dio.get(url,
          options: Options(
            responseType: ResponseType.plain,
          ));

      var map = json.decode(response.toString());
      var progress = getCurrentStage(map);
      setState(() {
        orders[i]["trackingData"] = map;
        orders[i]["progress"] = progress;
      });
      print(orders[i]["trackingData"]);
      setState(() {
        orders[i]["loading"] = false;
      });
    } catch (e) {
      print(e);
      displaySnackBar("Error! Please Try Again Later", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "GoFlexe",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Text(
              "My Orders",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: new GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 4 / 1),
              shrinkWrap: true,
              itemCount: place.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPlace = place[index];
                      place.forEach((element) {
                        element.isSelected = false;
                      });
                      place[index].isSelected = true;
                      if (place[index].title == "All") {
                        filteredOrders = orders;
                      }
                      if (place[index].title == "Processing") {
                        filteredOrders = (orders)
                            .where((u) => u['progress']
                                .toLowerCase()
                                .contains("processing"))
                            .toList();
                      }
                      if (place[index].title == "Delivered") {
                        filteredOrders = (orders)
                            .where((u) => u['progress']
                                .toLowerCase()
                                .contains("delivered"))
                            .toList();
                      }
                      print(place[index].title);
                    });
                  },
                  child: new PlaceSelection(place[index]),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (isLoading == true)
            Expanded(
              child: Container(
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else
            Expanded(
              child: filteredOrders.length == 0
                  ? Center(
                      child: Text(
                      "No Orders",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ))
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            var route = new MaterialPageRoute(
                                builder: (BuildContext context) => OrderDetails(
                                      details: filteredOrders[index],
                                    ));
                            Navigator.of(context).push(route);
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              elevation: 1.5,
                              child: Container(
                                  height: 150,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            filteredOrders[index]["data"]
                                                        ['OrderId'] !=
                                                    null
                                                ? 'Order No. ${filteredOrders[index]["data"]['OrderId']?.substring(0, 4) ?? "NA"}'
                                                : "NA",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Spacer(),
                                          Text(
                                            filteredOrders[index]["data"]
                                                        ["orderDate"] !=
                                                    null
                                                ? new DateFormat("EEE, d MMMM")
                                                    .format(DateTime.parse(
                                                        filteredOrders[index]
                                                                ["data"]
                                                            ["orderDate"]))
                                                    .toString()
                                                : "NA",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                      Spacer(),
                                      filteredOrders[index]["data"]
                                                  ["movementType"] ==
                                              "OutStation"
                                          ? Row(
                                              children: [
                                                Text(
                                                  'From :  ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  "Hyderabad",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13),
                                                ),
                                                Spacer(),
                                                Text(
                                                  'To : ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  "Chennai",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  'Movement :  ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  filteredOrders[index]["data"]
                                                          ["movementType"] ??
                                                      "NA",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13),
                                                ),
                                                Spacer(),
                                                Text(
                                                  'City :  ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  filteredOrders[index]["data"]
                                                          ["pickupCity"] ??
                                                      "NA",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Text(
                                            'Shift type : ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            filteredOrders[index]["data"]
                                                    ["shiftType"] ??
                                                "NA",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13),
                                          ),
                                          Spacer(),
                                          Text(
                                            'Total Amount : ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Rs. ${orders[index]["data"]["totalAmount"].toString()}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          if (filteredOrders[index]
                                                  ["progress"] !=
                                              "Delivered")
                                            filteredOrders[index]
                                                        ["loading"] ==
                                                    true
                                                ? CircularProgressIndicator()
                                                : filteredOrders[index]
                                                                    [
                                                                    "trackingData"]
                                                                ["stages"][0]
                                                            ["status"] !=
                                                        "COMPLETED"
                                                    ? MaterialButton(
                                                        color: C.secondaryColor,
                                                        textColor: Colors.black,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      18.0),
                                                        ),
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                  return Padding(
                                                                    padding: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets,
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              20,
                                                                          vertical:
                                                                              20),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            "Specify Driver Details",
                                                                            style:
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                                          ),
                                                                          C.box10,
                                                                          new TextFormField(
                                                                            onChanged:
                                                                                (val) {
                                                                              setState(() {
                                                                                filteredOrders[index]["trackingData"]["driverName"] = val;
                                                                              });
                                                                            },
                                                                            decoration: new InputDecoration(
                                                                                isDense: true, // Added this
                                                                                contentPadding: EdgeInsets.all(15),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                                  borderSide: BorderSide(
                                                                                    width: 1,
                                                                                    color: Color(0xFF2821B5),
                                                                                  ),
                                                                                ),
                                                                                border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.grey[200]!)),
                                                                                labelText: "Driver Name"),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          new TextFormField(
                                                                            onChanged:
                                                                                (val) {
                                                                              setState(() {
                                                                                filteredOrders[index]["trackingData"]["driverNumber"] = val;
                                                                              });
                                                                            },
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            decoration: new InputDecoration(
                                                                                isDense: true, // Added this
                                                                                contentPadding: EdgeInsets.all(15),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                                  borderSide: BorderSide(
                                                                                    width: 1,
                                                                                    color: Color(0xFF2821B5),
                                                                                  ),
                                                                                ),
                                                                                border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.grey[200]!)),
                                                                                labelText: "Driver Number"),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                20,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: DateTimePicker(
                                                                                  decoration: new InputDecoration(
                                                                                    errorStyle: TextStyle(fontSize: 10),
                                                                                    prefixIcon: Icon(Icons.calendar_today),
                                                                                    isDense: true, // Added this
                                                                                    contentPadding: EdgeInsets.all(15),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                                      borderSide: BorderSide(
                                                                                        width: 1,
                                                                                        color: Color(0xFF2821B5),
                                                                                      ),
                                                                                    ),
                                                                                    border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.grey)),
                                                                                    labelText: 'Pickup Date',
                                                                                  ),
                                                                                  style: TextStyle(fontSize: 14),
                                                                                  firstDate: today,
                                                                                  lastDate: DateTime(2100),
                                                                                  dateLabelText: "Pickup Date",
                                                                                  onChanged: (val) {
                                                                                    setState(() {
                                                                                      filteredOrders[index]["trackingData"]["pickupDate"] = val;
                                                                                    });
                                                                                    print(val);
                                                                                  },
                                                                                  validator: (val) {
                                                                                    if (val!.isEmpty) {
                                                                                      return "Required";
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  onSaved: (val) => print(val),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 20,
                                                                              ),
                                                                              Expanded(
                                                                                child: DateTimePicker(
                                                                                  style: TextStyle(fontSize: 14),
                                                                                  decoration: new InputDecoration(
                                                                                    // errorText:
                                                                                    //     dropDateValidator,
                                                                                    errorStyle: TextStyle(fontSize: 10),
                                                                                    prefixIcon: Icon(Icons.calendar_today),
                                                                                    isDense: true, // Added this
                                                                                    contentPadding: EdgeInsets.all(15),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                                      borderSide: BorderSide(
                                                                                        width: 1,
                                                                                        color: Color(0xFF2821B5),
                                                                                      ),
                                                                                    ),
                                                                                    border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.grey)),
                                                                                    labelText: 'Drop Date',
                                                                                  ),
                                                                                  initialDate: today.add(Duration(
                                                                                    days: 1,
                                                                                  )),
                                                                                  firstDate: today.add(Duration(
                                                                                    days: 1,
                                                                                  )),
                                                                                  lastDate: DateTime(2100),
                                                                                  dateLabelText: 'Drop Date',
                                                                                  onChanged: (val) async {
                                                                                    setState(() {
                                                                                      filteredOrders[index]["trackingData"]["deliveryDate"] = val;
                                                                                    });
                                                                                  },
                                                                                  // validator: (val) {
                                                                                  //   if (val.isEmpty) {
                                                                                  //     return "Required";
                                                                                  //   }
                                                                                  //   return null;
                                                                                  // },
                                                                                  onSaved: (val) => print(val),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                          ),
                                                                          ElevatedButton(
                                                                              onPressed: () {
                                                                                assignDriver(filteredOrders[index], index);
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Text("Assign"))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                              });
                                                        },
                                                        child: Text("Assign",
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                      )
                                                    : MaterialButton(
                                                        color: C.primaryColor,
                                                        textColor: Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      18.0),
                                                        ),
                                                        onPressed: () {
                                                          var route = new MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  FlutterMap(
                                                                      data: filteredOrders[
                                                                          index]));
                                                          Navigator.of(context)
                                                              .push(route);
                                                        },
                                                        child: Text("Track",
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                      )
                                          else
                                            SizedBox(
                                              height: 40,
                                            ),
                                          Spacer(),
                                          Text(
                                            filteredOrders[index]["progress"],
                                            style: TextStyle(
                                                color: filteredOrders[index]
                                                            ["progress"] ==
                                                        "Processing"
                                                    ? Colors.green
                                                    : filteredOrders[index]
                                                                ["progress"] ==
                                                            "Delivered"
                                                        ? C.primaryColor
                                                        : Colors.orange[800],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        );
                      }),
            ),
        ],
      ),
    );
  }

  getCurrentStage(d) {
    var count = 0;
    var data = d["stages"];
    data.forEach((stage) => {
          if (stage["status"] == "COMPLETED") {count++}
        });
    if (count == 0) {
      return "Pending Assignment";
    } else if (data.length == count) {
      return "Delivered";
    } else {
      return "Processing";
    }
  }
}
