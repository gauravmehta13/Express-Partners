import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../Widgets/stepper.dart';
import '../../constants.dart';

class Tracking extends StatefulWidget {
  Map data;
  Tracking({required this.data});
  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  bool driverLoading = false;
  var driverName = new TextEditingController();
  var driverNo = new TextEditingController();

  String? imageLink;
  List? trackingDetails = [];
  List<FAStep> trackingSteps = [];
  int _currentStep = 0;
  bool orderDelivered = false;
  FAStepperType _stepperType = FAStepperType.vertical;
  bool isLoading = true;
  var dio = Dio();

  void initState() {
    super.initState();
    getTracking();
  }

  getTracking() async {
    setState(() {
      trackingDetails = widget.data["trackingData"]["stages"];
      print(trackingDetails);
    });
    getCurrentStage(widget.data["trackingData"]["stages"]);
    var buttonName =
        await getButtonNames(widget.data["trackingData"]["stages"]);
    print(buttonName);
    setState(() {
      trackingSteps = [];
    });
    for (var i = 0; i < trackingDetails!.length; i++) {
      trackingSteps.add(
        FAStep(
            title: Text(trackingDetails![i]["stageLabel"]),
            isActive: true,
            state: _getState(trackingDetails![i]["number"]),
            content: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (trackingDetails![i]["tasks"][0]["customFields"]
                                  ["data"]["show_fields"][0]["type"] ==
                              "input-attachment") {
                            getImage();
                          } else {
                            changeTask();
                          }
                        },
                        child: Text(buttonName)),
                  ],
                ))),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  getCurrentStage(data) {
    var count = 0;
    data.forEach((stage) => {
          if (stage["status"] == "COMPLETED") {count++}
        });
    if (data.length == count) {
      setState(() {
        orderDelivered = true;
      });
    } else {
      setState(() {
        _currentStep = count;
      });
    }
  }

  getCurrentTask(data) {
    String? taskName = "";
    for (var i = 0; i < data.length; i++) {
      for (var j = 0; j < data[i]["tasks"].length; j++) {
        print(data[i]["tasks"][j]["status"]);
        if (data[i]["tasks"][j]["status"] == "PENDING") {
          setState(() {
            taskName = data[i]["tasks"][j]["name"];
          });
          break;
        }
      }
    }
    return taskName;
  }

  getButtonNames(data) {
    String? buttonName = "";
    for (var i = 0; i < data.length; i++) {
      for (var j = 0; j < data[i]["tasks"].length; j++) {
        print(data[i]["tasks"][j]["status"]);
        if (data[i]["tasks"][j]["status"] == "PENDING") {
          setState(() {
            buttonName = data[i]["tasks"][j]["customFields"]["data"]
                ["show_fields"][0]["label"];
          });
          break;
        }
      }
    }
    return buttonName;
  }

  increaseStep() {
    setState(() {
      if (this._currentStep < 4) {
        this._currentStep = this._currentStep + 1;
      } else if (this._currentStep == 4) {
        setState(() {
          orderDelivered = true;
        });
      }
    });
  }

  List tracking = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: C.primaryColor, width: 2),
              borderRadius: BorderRadius.vertical(
                  top: (Radius.circular(30)), bottom: (Radius.circular(0))),
              color: Colors.white,
            ),
            height: MediaQuery.of(context).size.height / 2,
            child: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : orderDelivered == false
                    ? trackingStepper()
                    : Container(
                        width: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/check.png",
                                height: 60,
                                width: 60,
                              ),
                              C.box20,
                              Text(
                                "Order Delivered Successfully",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ]))),
        if (orderDelivered == false)
          Positioned(
              top: 0,
              right: 5,
              child: GestureDetector(
                onTap: () {
                  editDriverSheet();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: driverLoading == true
                      ? SizedBox(
                          child: CircularProgressIndicator(),
                          height: 25.0,
                          width: 25.0,
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 10,
                              color: C.primaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Edit Driver Details",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: C.primaryColor),
                            ),
                          ],
                        ),
                ),
              ))
      ],
    );
  }

  Widget trackingStepper() {
    return FAStepper(
        titleHeight: 20,
        // titleHeight: 120.0,
        stepNumberColor: Colors.grey,
        // titleIconArrange: FAStepperTitleIconArrange.column,
        physics: ClampingScrollPhysics(),
        type: _stepperType,
        currentStep: this._currentStep,
        steps: trackingSteps);
  }

  FAStepstate _getState(int i) {
    if (_currentStep > i)
      return FAStepstate.complete;
    else if (_currentStep == i - 1) {
      return FAStepstate.indexed;
    } else
      return FAStepstate.indexed;
  }

  editDriver() async {
    var url =
        "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=updateCustomFields";
    final response = await dio.patch(
      url,
      data: {
        "trackingId": widget.data["trackingData"]["processId"].toString(),
        "stageId":
            widget.data["trackingData"]["stages"][0]["stageId"].toString(),
        "taskId": widget.data["trackingData"]["stages"][0]["tasks"][0]["taskId"]
            .toString(),
        "custom": {
          "data": {
            "driverName": driverName.text,
            "contactNo": driverNo.text,
          },
        },
      },
    ).then((value) => postDriverData());
    print(response);
  }

  postDriverData() async {
    final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceorder/livetrack',
        data: {
          "tenantUsecase": "pam",
          "tenantSet_id": "PAM01",
          "item": {
            "customerOrderId": widget.data["customerOrderId"],
            "serviceOrderId": widget.data["ServiceOrderId"],
            "phone-number": driverNo.text
          }
        });
    setState(() {
      driverLoading = false;
    });
    if (response.statusCode == 200) {
      displaySnackBar("Driver Saved Successfully", context);
    } else {
      displaySnackBar("Error! Try Again Later.", context);
    }
  }

  changeTask() async {
    setState(() {
      isLoading = true;
    });
    var url =
        "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=changeTaskStatus";
    var taskName = await getCurrentTask(widget.data["trackingData"]["stages"]);
    print(taskName);
    var data = await getTrackingIds(widget.data["trackingData"], taskName);
    final response =
        await dio.patch(url, data: data).then((value) => setProgress());
    print(response);
  }

  setProgress() async {
    var url =
        "https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/tracking?type=getProcess&orderId=${widget.data["ServiceOrderId"]}";
    print(url);
    final response = await dio.get(url,
        options: Options(
          responseType: ResponseType.plain,
        ));
    var map = json.decode(response.toString());
    setState(() {
      widget.data["trackingData"] = map;
    });
    print(widget.data["trackingData"]);
    setState(() {
      widget.data["loading"] = false;
    });
    getTracking();
  }

  /////////////////////////////////////////////////////////////////////////////////
  getTrackingIds(trackingData, taskName) {
    Map? details;
    trackingData["stages"].forEach((stage) => {
          stage["tasks"].forEach((task) => {
                if (task["name"] == taskName)
                  {
                    details = {
                      "trackingId": trackingData["processId"],
                      "stageId": stage["stageId"],
                      "taskId": task["taskId"],
                      "status": "NEXT"
                    }
                  }
              })
        });
    return details;
  }

  getImage() async {}

  Future<dynamic> editDriverSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Specify Driver Details",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  C.box10,
                  new TextFormField(
                    controller: driverName,
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
                        border: new OutlineInputBorder(
                            borderSide:
                                new BorderSide(color: Colors.grey[200]!)),
                        labelText: "Driver Name"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  new TextFormField(
                    controller: driverNo,
                    keyboardType: TextInputType.number,
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
                        border: new OutlineInputBorder(
                            borderSide:
                                new BorderSide(color: Colors.grey[200]!)),
                        labelText: "Driver Number"),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          driverLoading = true;
                        });
                        editDriver();
                        Navigator.pop(context);
                      },
                      child: Text("Save"))
                ],
              ),
            );
          });
        });
  }
}
