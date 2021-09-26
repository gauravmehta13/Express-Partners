import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Constants.dart';
import '../ProgressBar.dart';
import '../Widgets/Loading.dart';
import '../Widgets/Stepper.dart';
import 'Pricing/OutStation Pricing .dart';
import 'Pricing/Service%20Offering%20Pricing.dart';
import 'Pricing/Vehicle%20Pricing.dart';
import 'Pricing/Within City Pricing.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AllPrices extends StatefulWidget {
  final old;
  AllPrices({this.old});
  @override
  _AllPricesState createState() => new _AllPricesState();
}

class _AllPricesState extends State<AllPrices> {
  String title = 'Stepper (Custom)';
  int _currentStep = 0;
  FAStepperType _stepperType = FAStepperType.horizontal;
  bool loading = true;
  var dio = Dio();

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      getProgress();
    });
  }

  Map<String, dynamic>? data;

  getProgress() async {
    try {
      final response = await dio.get(
          'https://t2v0d33au7.execute-api.ap-south-1.amazonaws.com/Staging01/serviceprovidercost?tenantSet_id=PAM01&tenantUsecase=pam&type=serviceProviderId&serviceProviderId=${_auth.currentUser!.uid}');
      Map<String, dynamic>? map = json.decode(response.toString());
      setState(() {
        data = map;
        if (map!['resp']['Items'][0]["selfInfo"]["baseCity"] != null) {
          baseLocation = map['resp']['Items'][0]["selfInfo"]["baseCity"];
          print(map['resp']['Items'][0]["selfInfo"]["baseCity"]);
        }
      });
      print(map);
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  void _update(int count) {
    setState(() => _currentStep = count);
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          if (this._currentStep > 0) {
            this._currentStep = this._currentStep - 1;
          } else {
            this._currentStep = 0;
            Navigator.pop(context);
          }
        });
        return null;
      } as Future<bool> Function()?,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            launchWhatsApp();
          },
          backgroundColor: Color(0xFF25D366),
          child: FaIcon(FontAwesomeIcons.whatsapp),
        ),
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: AppBar(
              elevation: 1,
              leading: InkWell(
                  onTap: () {
                    setState(() {
                      if (this._currentStep > 0) {
                        this._currentStep = this._currentStep - 1;
                      } else {
                        this._currentStep = 0;
                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Icon(Icons.arrow_back)),
              automaticallyImplyLeading: false,
              title: Text(
                "GoFlexe",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, 10.0),
                child: StepProgressView(
                    width: MediaQuery.of(context).size.width,
                    curStep: 2,
                    color: Color(0xFFf9a825),
                    titles: [
                      "",
                      "",
                      "",
                    ]),
              ),
            )),
        body: loading == true
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Loading())
            : FAStepper(
                // titleHeight: 120.0,
                stepNumberColor: Colors.grey,
                // titleIconArrange: FAStepperTitleIconArrange.column,
                physics: ClampingScrollPhysics(),
                type: _stepperType,
                currentStep: this._currentStep,
                onStepTapped: widget.old != null
                    ? (step) {
                        setState(() {
                          this._currentStep = step;
                        });
                        print('onStepTapped :' + step.toString());
                      }
                    : null,
                onStepContinue: () {
                  setState(() {
                    if (this._currentStep < 4 - 1) {
                      this._currentStep = this._currentStep + 1;
                    } else {
                      _currentStep = 0;
                    }
                  });
                  print('onStepContinue :' + _currentStep.toString());
                },
                onStepCancel: () {
                  setState(() {
                    if (this._currentStep > 0) {
                      this._currentStep = this._currentStep - 1;
                    } else {
                      this._currentStep = 0;
                    }
                  });
                  print('onStepCancel :' + _currentStep.toString());
                },
                steps: [
                  FAStep(
                      title: Text('Within City'),
                      isActive: true,
                      state: _getState(1),
                      content: WithinCityPricing(
                        update: _update,
                        data: data,
                      )),
                  FAStep(
                      state: _getState(2),
                      title: Text('Outstation'),
                      isActive: true,
                      content: OutStationPricing(
                        update: _update,
                        data: data,
                      )),
                  FAStep(
                      state: _getState(3),
                      title: Text('Vehicle'),
                      isActive: true,
                      content: VehiclePricing(update: _update, data: data)),
                  FAStep(
                      state: _getState(4),
                      title: Text('Offerings'),
                      isActive: true,
                      content: ServiceOfferingPricing(
                          update: _update, data: data, old: widget.old)),
                ],
              ),
      ),
    );
  }

  FAStepstate _getState(int i) {
    if (_currentStep >= i)
      return FAStepstate.complete;
    else if (_currentStep == i - 1) {
      return FAStepstate.editing;
    } else
      return FAStepstate.indexed;
  }
}
