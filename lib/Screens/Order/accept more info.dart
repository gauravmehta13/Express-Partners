import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../Constants.dart';

class AcceptMoreInfo extends StatefulWidget {
  final details;
  AcceptMoreInfo({required this.details});
  @override
  _AcceptMoreInfoState createState() => _AcceptMoreInfoState();
}

class _AcceptMoreInfoState extends State<AcceptMoreInfo> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          alignment: Alignment.bottomRight,
          height: 40,
          child: Row(
            children: [
              Text(
                "More Info",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close)),
            ],
          ),
        ),
        C.box20,
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
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                        "${widget.details["pickupAddress"] ?? "NA"}, ${widget.details["pickupArea"] ?? "NA"}",
                        style: TextStyle(
                          fontSize: 12,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Drop Address",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                        widget.details["dropArea"].isNotEmpty
                            ? "${widget.details["dropAddress"] ?? "NA"}, ${widget.details["dropArea"] ?? "NA"}"
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
                    widget.details["contactNo"] ?? "NA",
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
                    widget.details["shiftType"] ?? "NA",
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
                    widget.details["shiftDate"] != null &&
                            widget.details["shiftDate"] != "null"
                        ? new DateFormat("EEE, d MMMM")
                            .format(DateTime.parse(widget.details["shiftDate"]))
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
                    widget.details["dropDate"] != null &&
                            widget.details["dropDate"] != "null"
                        ? new DateFormat("EEE, d MMMM")
                            .format(DateTime.parse(widget.details["dropDate"]))
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
                    "₹ ${widget.details["basicCharges"]}",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              if (widget.details["singleServices"] != null)
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.details["singleServices"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return widget.details["singleServices"][index]
                                  ["selected"] ==
                              true
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.details["singleServices"][index]
                                          ["label"],
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Spacer(),
                                    Text(
                                      "₹ ${widget.details["singleServices"][index]["selectionDetails"]["newPrice"].toString()}",
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text(
                "Order Total",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                "₹ ${widget.details["totalAmount"]}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                  elements: widget.details["items"],
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            value!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  itemBuilder: (c, element) {
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "${element['itemName'] ?? ""} ( ${element['total'].toString()} )",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600),
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
    );
  }
}
