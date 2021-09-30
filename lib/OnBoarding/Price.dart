import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Widgets/loading.dart';
import '../Widgets/stepper.dart';
import '../constants.dart';
import '../progress_bar.dart';
import 'Pricing/outstation_pricing.dart';
import 'Pricing/service_offering_pricing.dart';
import 'Pricing/vehicle_pricing.dart';
import 'Pricing/within_city_pricing.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AllPrices extends StatefulWidget {
  final old;
  AllPrices({this.old});
  @override
  _AllPricesState createState() => _AllPricesState();
}

class _AllPricesState extends State<AllPrices> {
  int _currentStep = 0;
  final FAStepperType _stepperType = FAStepperType.horizontal;
  bool loading = false;
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    getAveragePrices();
  }

  Map avgPrices = {};

  getAveragePrices() async {
    var dio = Dio();
    try {
      final response = await dio.get(
          "https://my-json-server.typicode.com/gauravmehta13/Express-Partners/prices");
      setState(() {
        avgPrices = response.data;
      });
    } catch (e) {
      displaySnackBar("Error, Please Try Again Later..!!", context);
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
    return Scaffold(
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
                    if (_currentStep > 0) {
                      _currentStep = _currentStep - 1;
                    } else {
                      _currentStep = 0;
                      Navigator.pop(context);
                    }
                  });
                },
                child: Icon(Icons.arrow_back)),
            automaticallyImplyLeading: false,
            title: const Text(
              "Express",
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
              currentStep: _currentStep,
              onStepTapped: widget.old != null
                  ? (step) {
                      setState(() {
                        _currentStep = step;
                      });
                      print('onStepTapped :' + step.toString());
                    }
                  : null,
              onStepContinue: () {
                setState(() {
                  if (_currentStep < 4 - 1) {
                    _currentStep = _currentStep + 1;
                  } else {
                    _currentStep = 0;
                  }
                });
                print('onStepContinue :' + _currentStep.toString());
              },
              onStepCancel: () {
                setState(() {
                  if (_currentStep > 0) {
                    _currentStep = _currentStep - 1;
                  } else {
                    _currentStep = 0;
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
                      data: avgPrices,
                    )),
                FAStep(
                    state: _getState(2),
                    title: Text('Outstation'),
                    isActive: true,
                    content: OutStationPricing(
                      update: _update,
                      data: avgPrices,
                    )),
                FAStep(
                    state: _getState(3),
                    title: Text('Vehicle'),
                    isActive: true,
                    content: VehiclePricing(update: _update, data: avgPrices)),
                FAStep(
                    state: _getState(4),
                    title: Text('Offerings'),
                    isActive: true,
                    content: ServiceOfferingPricing(
                        update: _update, data: avgPrices, old: widget.old)),
              ],
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
