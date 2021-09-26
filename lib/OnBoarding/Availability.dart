import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Appbar.dart';
import '../Constants.dart';
import '../Fade Route.dart';
import '../Screens/BottomNavBar.dart';
import '../Widgets/Counter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Availability extends StatefulWidget {
  final edit;
  Availability({this.edit});
  @override
  _AvailabilityState createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  String? _selectedDate;
  String? _dateCount;
  String? _range;
  String? _rangeCount;
  List<PickerDateRange>? availableDates = [];
  List availableDateRange = [];
  List<DateTime>? unavailabledateRange;
  bool? available = true;
  bool loading = true;
  bool sendingData = false;
  bool detailsSubmitted = false;
  double daysPrior = 2;
  var dio = Dio();

  @override
  void initState() {
    _selectedDate = '';
    _dateCount = '';
    _range = '';
    _rangeCount = '';
    super.initState();
    getProgress();
    logEvent("Availability_Screen");
  }

  getProgress() async {
    try {
      final response = await dio.get(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser!.uid}');

      Map<String, dynamic> map = json.decode(response.toString());
      print(map['resp']['Items'][0]['selfInfo']['availability']);
      if (map['resp']['Items'] != null) {
        if (map['resp']['Items'][0]['selfInfo']['availability'].length != 0) {
          setState(() {
            daysPrior = double.parse(map['resp']['Items'][0]['selfInfo']
                    ['availability']['priorDays']
                .toString());
            available = map['resp']['Items'][0]['selfInfo']['availability']
                ['availableThroughoutYear'];
            loading = false;
          });
          print("object");
          print(map['resp']['Items'][0]['selfInfo']['availability']
              ['availableThroughoutYear']);
        } else {
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

  postKYCData() async {
    final response = await dio.post(
        'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/kyc/info?type=packersAndMoversSP',
        data: {
          "type": "packersAndMoversSP",
          "id": _auth.currentUser!.uid,
          "mobile": _auth.currentUser!.phoneNumber,
          "tenantUsecase": "pam",
          "tenantSet_id": "PAM01",
          "kycDone": true,
        });
    print(response);
    setState(() {
      sendingData = false;
      detailsSubmitted = true;
    });
    print(response.statusCode);
  }

  postAvailabilityData() async {
    logEvent('Completed_Onboarding');
    try {
      for (var i = 0; i < availableDates!.length; i++) {
        String date = DateFormat('dd/MM/yyyy')
                .format(availableDates![i].startDate!)
                .toString() +
            ' - ' +
            DateFormat('dd/MM/yyyy')
                .format(
                    availableDates![i].endDate ?? availableDates![i].startDate!)
                .toString();
        availableDateRange.add(date);
      }
      print(availableDateRange);
      final response = await dio.post(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost',
          data: {
            "serviceProviderId": _auth.currentUser!.uid,
            "mobile": _auth.currentUser!.phoneNumber,
            "tenantUsecase": "pam",
            "tenantSet_id": "PAM01",
            "selfInfo": {
              "kycDone": true,
              "availability": {
                "priorDays": daysPrior,
                "availableThroughoutYear": available,
                "availablityDates": availableDateRange
              }
            }
          });

      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        await postKYCData();
      } else {
        setState(() {
          sendingData = false;
        });
        displaySnackBar("Error, Please try again later.", context);
      }
    } catch (e) {
      displaySnackBar("Error,Please Try Again Later!", context);
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      print(args.value);
      availableDates = args.value;
      print(_range);

      print(availableDates);
      if (args.value is PickerDateRange) {
        _range =
            DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd/MM/yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();
      } else if (args.value is DateTime) {
        _selectedDate = args.value;
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

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
        bottomNavigationBar: detailsSubmitted == true
            ? Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFf9a825), // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        FadeRoute(page: BottomNavScreen()),
                      );
                    },
                    child: sendingData == true
                        ? Center(
                            child: LinearProgressIndicator(
                              backgroundColor: Color(0xFF3f51b5),
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFf9a825),
                              ),
                            ),
                          )
                        : Text(
                            "Return to HomePage",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ))
            : Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFf9a825), // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () async {
                      setState(() {
                        sendingData = true;
                      });
                      await postAvailabilityData();
                      setState(() {
                        detailsSubmitted = true;
                      });
                    },
                    child: sendingData == true
                        ? Center(
                            child: LinearProgressIndicator(
                              backgroundColor: Color(0xFF3f51b5),
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFf9a825),
                              ),
                            ),
                          )
                        : Text(
                            "Save",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                )),
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: MyAppBar(
              curStep: 3,
            )),
        body: loading == true
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : detailsSubmitted == false
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              height: 80,
                              child: Image.asset("assets/availability.png")),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Availability Details",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "You can change the availability details later in your profile.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 20,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Order Acceptance",
                                        style: TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Ex. ( Order placed on 18 will be acceptable on 20 by you.)",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Counter(
                                    initialValue: daysPrior,
                                    minValue: 0,
                                    maxValue: 10,
                                    step: 1,
                                    decimalPlaces: 0,
                                    onChanged: (value) {
                                      setState(() {
                                        daysPrior = value as double;
                                      });
                                    }),
                              ],
                            ),
                          ),

                          // Text('Selected date: ' + _selectedDate),
                          // Text('Selected date count: ' + _dateCount),
                          // Text('Selected range: ' + _range),
                          // Text('Selected ranges count: ' + _rangeCount),

                          SizedBox(
                            height: 20,
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.all(0),
                            dense: true,
                            title: const Text(
                              'Available throughout the year?',
                            ),
                            // subtitle: Text(
                            //     "Confirm your availability for all selected routes and services for the entire year."),
                            autofocus: false,
                            activeColor: Color(0xFF3f51b5),
                            checkColor: Colors.white,
                            selected: available!,
                            value: available,
                            onChanged: (bool? value) {
                              setState(() {
                                available = value;
                              });
                            },
                          ),
                          if (available == false)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Select Availability Dates",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Editing your calendar is easy - just select a date range for your availability. You can always make changes after you publish.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SfDateRangePicker(
                                    navigationDirection:
                                        DateRangePickerNavigationDirection
                                            .vertical,
                                    view: DateRangePickerView.month,
                                    onSelectionChanged: _onSelectionChanged,
                                    showNavigationArrow: true,
                                    initialDisplayDate: DateTime.now(),
                                    selectionMode:
                                        DateRangePickerSelectionMode.multiRange,
                                    initialSelectedRange: PickerDateRange(
                                        DateTime.now()
                                            .subtract(const Duration(days: 4)),
                                        DateTime.now()
                                            .add(const Duration(days: 3))),
                                  ),
                                ]),
                          SizedBox(
                            height: 20,
                          ),
                        ])))
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/namaste.png",
                          height: 100,
                          width: 100,
                        ),
                        C.box20,
                        Text(
                          "Thank You",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900),
                        ),
                        C.box10,
                        Text(
                          "Your details have been submitted successfully.",
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        C.box10,
                        if (widget.edit == null)
                          Text(
                            "You can edit or edit your details later from the profile menu.",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ));
  }
}
