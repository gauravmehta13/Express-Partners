import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Appbar.dart';
import '../Fade Route.dart';
import '../OnBoarding/OnBoarding.dart';

class AdditionalInfo extends StatefulWidget {
  @override
  _AdditionalInfoState createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {
  bool? userDetails = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFf9a825), // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () {
              Navigator.push(
                context,
                FadeRoute(page: Onboarding()),
              );
            },
            child: Text(
              "Done",
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(height: 80, child: Image.asset("assets/rating.png")),
              SizedBox(
                height: 10,
              ),
              Text(
                "Build your own catalog",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Help customers to get to know more about you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20,
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
              new TextFormField(
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
                        borderSide: new BorderSide(color: Colors.grey[200]!)),
                    labelText: "Description of Company*"),
              ),
              SizedBox(
                height: 20,
              ),
              new TextFormField(
                decoration: new InputDecoration(
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
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]!)),
                    labelText: "Website link"),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text("Upload Display Image :"),
                  SizedBox(
                    width: 10,
                  ),
                  RawMaterialButton(
                      onPressed: () {},
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
                height: 20,
              ),
              Row(
                children: [
                  Text("Other images showing business :"),
                  SizedBox(
                    width: 20,
                  ),
                  RawMaterialButton(
                      onPressed: () {},
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
              new TextFormField(
                decoration: new InputDecoration(
                    isDense: true, // Added this
                    labelText: "Google Reviews link if available"),
              ),
              CheckboxListTile(
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
                Column(
                  children: [
                    new TextFormField(
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
                          labelText: "Name"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new TextFormField(
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
                          labelText: "Contact Number"),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
