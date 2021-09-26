import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import 'map_based_tracking.dart';
//https://dribbble.com/shots/12199961-Package-Order-List-and-Order-Summary-iOS-Mobile-App-Senz

class OrderDetails extends StatefulWidget {
  final details;
  OrderDetails({required this.details});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  Random random = new Random();
  String dashString =
      "------------------------------------------------------------";
  bool review = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 175),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 175,
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 50, 10, 10),
            decoration: BoxDecoration(
              color: C.primaryColor,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MaterialButton(
                      minWidth: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child: FaIcon(
                        FontAwesomeIcons.boxOpen,
                        color: C.primaryColor,
                        size: 33,
                      ),
                    ),
                    SizedBox(width: 15),
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shipment In Transit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                MaterialButton(
                                  minWidth: 0,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  onPressed: () {
                                    _launchURL(
                                      'help@goflexe.com',
                                      'Facing issue with my Shipment',
                                      'Order Id: 321323 \nMobile : +91 9237373332\n$dashString\n\n',
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_center,
                                    color: Colors.white,
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PreferredSize(
        preferredSize: Size(double.infinity, 80),
        child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 25),
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Row(
              children: [
                widget.details["trackingData"]["stages"][0]["status"] !=
                        "COMPLETED"
                    ? MaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minWidth: 0,
                        onPressed: () {},
                        color: C.secondaryColor,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            width: (MediaQuery.of(context).size.width / 2) - 50,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Assign",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                      )
                    : MaterialButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minWidth: 0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FlutterMap(
                                      data: widget.details,
                                    )),
                          );
                        },
                        color: C.secondaryColor,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            width: (MediaQuery.of(context).size.width / 2) - 50,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.track_changes),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Track",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                      ),
                Spacer(),
                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: 0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FlutterMap(
                                data: widget.details,
                              )),
                    );
                  },
                  color: C.secondaryColor,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      width: (MediaQuery.of(context).size.width / 2) - 50,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.rupeeSign,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Payments",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
              ],
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          child: Icon(
                            Icons.location_city,
                            size: 15,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 30),
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: Colors.black,
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            dashGapRadius: 0.0,
                          ),
                        ),
                        CircleAvatar(
                          radius: 14,
                          child: Icon(
                            Icons.home_filled,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Pickup Address",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                              "${widget.details["data"]["pickupAddress"] ?? "NA"}, ${widget.details["data"]["pickupArea"] ?? "NA"}",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Text("Drop Address",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                              widget.details["data"]["dropArea"].isNotEmpty
                                  ? "${widget.details["data"]["dropAddress"] ?? "NA"}, ${widget.details["data"]["dropArea"] ?? "NA"}"
                                  : "Not Available",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Text("Customer Details"),
                color: Colors.grey[300],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Contact No.",
                          style: TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          widget.details["data"]["contactNo"] ?? "NA",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Text("Order Details"),
                color: Colors.grey[300],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Apartment Size",
                          style: TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          widget.details["data"]["shiftType"] ?? "NA",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          "Shift Date",
                          style: TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          widget.details["data"]["shiftDate"] != null &&
                                  widget.details["data"]["shiftDate"] != "null"
                              ? new DateFormat("EEE, d MMMM")
                                  .format(DateTime.parse(
                                      widget.details["data"]["shiftDate"]))
                                  .toString()
                              : "NA",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          "Drop Date",
                          style: TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          widget.details["data"]["dropDate"] != null &&
                                  widget.details["data"]["dropDate"] != "null"
                              ? new DateFormat("EEE, d MMMM")
                                  .format(DateTime.parse(
                                      widget.details["data"]["dropDate"]))
                                  .toString()
                              : "NA",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Text("Pricing Details"),
                color: Colors.grey[300],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Basic Charges",
                          style: TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                        Text(
                          "₹ ${widget.details["data"]["basicCharges"]}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (widget.details["data"]["singleServices"] != null)
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              widget.details["data"]["singleServices"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return widget.details["data"]["singleServices"]
                                        [index]["selected"] ==
                                    true
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.details["data"]
                                                    ["singleServices"][index]
                                                ["label"],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Spacer(),
                                          Text(
                                            "₹ ${widget.details["data"]["singleServices"][index]["selectionDetails"]["newPrice"].toString()}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  )
                                : Container();
                          }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DottedLine(
                  direction: Axis.horizontal,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.black,
                  dashRadius: 0.0,
                  dashGapLength: 4.0,
                  dashGapColor: Colors.transparent,
                  dashGapRadius: 0.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Text(
                      "Pay on Delivery",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text(
                      "Order Total",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "₹ ${widget.details["data"]["totalAmount"]}",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTileTheme(
                dense: true,
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.grey[300],
                  backgroundColor: Colors.grey[300],
                  title: Text("Item List"),
                  tilePadding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    GroupedListView<dynamic, String?>(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        elements: widget.details["data"]["items"],
                        groupBy: (element) => element['categoryName'],
                        groupComparator: (value1, value2) =>
                            value2!.compareTo(value1!),
                        // itemComparator: (item1, item2) =>
                        //     item2.name.compareTo(item1.name),
                        // optional
                        // useStickyGroupSeparators: true, // optional
                        // floatingHeader: true, // optional
                        order: GroupedListOrder.DESC,
                        groupSeparatorBuilder: (String? value) => Card(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(
                                  value!,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        itemBuilder: (c, element) {
                          return Container(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${element['itemName'] ?? ""} ( ${element['total'].toString()} )",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                // if (element['custom'].length != 0)
                                //   GridView.builder(
                                //       shrinkWrap: true,
                                //       gridDelegate:
                                //           new SliverGridDelegateWithFixedCrossAxisCount(
                                //         crossAxisCount: 4,
                                //         childAspectRatio: 6 / 1,
                                //       ),
                                //       itemCount:
                                //           element['custom'].length,
                                //       itemBuilder:
                                //           (BuildContext ctx, index) {
                                //         return Container(
                                //           alignment: Alignment.center,
                                //           child: Text(
                                //             "${element['custom'][index]['itemName'] ?? ""} ( ${element['custom'][index]['quantity'] ?? 0} )",
                                //             style: TextStyle(
                                //               fontSize: 10,
                                //             ),
                                //           ),
                                //         );
                                //       }),
                              ],
                            ),
                          );
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
