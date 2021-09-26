// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dropdown/flutter_dropdown.dart';
// import 'package:goflexe_partner/Data/PriceData.dart';
// import 'package:goflexe_partner/OnBoarding/availability.dart';
// import 'package:grouped_list/grouped_list.dart';
// import '../Appbar.dart';
// import '../Fade Route.dart';

// class Cities {
//   int id;
//   String name;
//   String pricePerDay;

//   Cities({this.id, this.name, this.pricePerDay});
// }

// class PricingDetails extends StatefulWidget {
//   @override
//   _PricingDetailsState createState() => _PricingDetailsState();
// }

// class _PricingDetailsState extends State<PricingDetails> {
//   static List<Cities> cities = [
//     Cities(id: 0, name: "Mumbai", pricePerDay: ""),
//     Cities(id: 1, name: "Delhi", pricePerDay: ""),
//     Cities(id: 2, name: "NCR", pricePerDay: ""),
//     Cities(
//       id: 3,
//       name: "Banglore",
//       pricePerDay: "",
//     ),
//     Cities(
//       id: 4,
//       name: "Hyderabad",
//       pricePerDay: "",
//     ),
//     Cities(
//       id: 5,
//       name: "Pune",
//       pricePerDay: "",
//     ),
//     Cities(
//       id: 6,
//       name: "Ahemdabad",
//       pricePerDay: "",
//     ),
//     Cities(
//       id: 7,
//       name: "Chennai",
//       pricePerDay: "",
//     ),
//   ];
//   List<Cities> warehouseCities = [];
//   List<Pricing> prices;
//   @override
//   void initState() {
//     prices = Pricing.getPrice();
//     super.initState();
//     for (var i = 0; i <= cities.length; i++) {
//       additionalSelected.insert(i, false);
//     }
//   }
//   bool warehouse = false;
//   bool freeStorage = true;
//   bool additionalChargesSelection = false;
//   bool firstPriceAdded = false;
//   String shiftType;

//   List<bool> additionalSelected = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Container(
//           padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
//           child: firstPriceAdded == true
//               ? SizedBox(
//                   height: 50,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Color(0xFFf9a825), // background
//                       onPrimary: Colors.white, // foreground
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         FadeRoute(page: Availability()),
//                       );
//                     },
//                     child: Text(
//                       "Next",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 )
//               : SizedBox(
//                   height: 50,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Color(0xFFf9a825), // background
//                       onPrimary: Colors.white, // foreground
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         firstPriceAdded = true;
//                         additionalChargesSelection = false;
//                       });
//                     },
//                     child: Text(
//                       "Add",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 )),
//       appBar: PreferredSize(
//           preferredSize: Size(double.infinity, 60),
//           child: MyAppBar(
//             curStep: 2,
//           )),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 10,
//               ),
//               SizedBox(height: 80, child: Image.asset("assets/money.png")),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "Location and Item Pricing Details",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Text(
//                 "Add pricing inclusive of transport, Loading, Unloading and Packaging. Not inclusive of Taxes.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w600),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Text("Choose Shift Type :"),
//                       Spacer(),
//                       DropDown(
//                         items: ["1 BHk", "2 BHK", "3 BHK", "3+ BHK"],
//                         hint: Text("Select Shift Type"),
//                         initialValue: "2 BHK",
//                         onChanged: (e) {
//                           setState(() {
//                             shiftType = e;
//                             print(e);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       DropDown(
//                         items: [
//                           // "Mumbai",
//                           // "Delhi",
//                           // "NCR",
//                           "Banglore",
//                           "Hyderabad",
//                           // "Pune",
//                           // "Ahemdabad",
//                           "Chennai"
//                         ],
//                         hint: Text("From Location"),
//                         initialValue: "Banglore",
//                         onChanged: (e) {
//                           setState(() {
//                             shiftType = e;
//                             print(e);
//                           });
//                         },
//                       ),
//                       Icon(Icons.arrow_forward),
//                       DropDown(
//                         items: [
//                           // "Mumbai",
//                           // "Delhi",
//                           // "NCR",
//                           "Banglore",
//                           "Hyderabad",
//                           // "Pune",
//                           // "Ahemdabad",
//                           "Chennai"
//                         ],
//                         hint: Text("To Location"),
//                         initialValue: "Hyderabad",
//                         onChanged: (e) {
//                           setState(() {
//                             shiftType = e;
//                             additionalChargesSelection = true;
//                             print(e);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   new TextFormField(
//                     keyboardType: TextInputType.number,
//                     decoration: new InputDecoration(
//                         isDense: true, // Added this
//                         prefixText: "₹ ",
//                         labelText: "Enter Price"),
//                   ),
//                   if (additionalChargesSelection == true)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Text(
//                           "Specify Additional Charges :",
//                           style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.grey[850],
//                               fontWeight: FontWeight.w600),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Car movement cost :"),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                                 child: TextFormField(
//                               style: TextStyle(fontSize: 12),
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(10),
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always,
//                                 hintText: "Hatchback Price",
//                                 prefixText: "₹ ",
//                                 hintStyle: TextStyle(fontSize: 10),
//                                 isCollapsed: true,
//                               ),
//                             )),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                                 child: TextFormField(
//                               style: TextStyle(fontSize: 12),
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(10),
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always,
//                                 prefixText: "₹ ",
//                                 hintText: "Sedan Price",
//                                 hintStyle: TextStyle(fontSize: 10),
//                                 isCollapsed: true,
//                               ),
//                             )),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                                 child: TextFormField(
//                               style: TextStyle(fontSize: 12),
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.all(10),
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.always,
//                                 prefixText: "₹ ",
//                                 hintText: "SUV Price",
//                                 hintStyle: TextStyle(fontSize: 10),
//                                 isCollapsed: true,
//                               ),
//                             )),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Bike movement cost :"),
//                             SizedBox(
//                               width: 30,
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width / 3,
//                               child: TextFormField(
//                                 style: TextStyle(fontSize: 12),
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.all(10),
//                                   prefixText: "₹ ",
//                                   hintText: "Enter Price",
//                                   hintStyle: TextStyle(fontSize: 10),
//                                   isCollapsed: true,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Extra charges without lift :"),
//                             SizedBox(
//                               width: 30,
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width / 3,
//                               child: TextFormField(
//                                 style: TextStyle(fontSize: 12),
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.all(10),
//                                   hintText: "Enter Price",
//                                   hintStyle: TextStyle(fontSize: 10),
//                                   prefixText: "₹ ",
//                                   isCollapsed: true,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                 ],
//               ),
//               if (firstPriceAdded == true)
//                 Column(
//                   children: [
//                     Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           "We have automatically added prices for other citites on the basis of your selection.*",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600, fontSize: 12),
//                         )),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     GroupedListView<dynamic, String>(
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       elements: prices,
//                       groupBy: (element) => element.shiftType,
//                       groupComparator: (value1, value2) =>
//                           value2.compareTo(value1),
//                       itemComparator: (item1, item2) =>
//                           item2.from.compareTo(item1.from),
//                       // optional
//                       // useStickyGroupSeparators: true, // optional
//                       // floatingHeader: true, // optional
//                       order: GroupedListOrder.DESC,
//                       groupSeparatorBuilder: (String value) => Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           padding: EdgeInsets.only(bottom: 5),
//                           decoration: BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(
//                                       color: Colors.grey[300], width: 1))),
//                           child: Text(
//                             value,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       itemBuilder: (c, element) {
//                         return Container(
//                             color: (element.price == "₹ 31000" ||
//                                     element.price == "₹ 31000 (+15%)")
//                                 ? Colors.grey[400]
//                                 : Colors.white,
//                             padding: EdgeInsets.all(10),
//                             child: Table(children: [
//                               TableRow(children: [
//                                 Text(
//                                   element.from,
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 Icon(Icons.arrow_forward_rounded),
//                                 Text(
//                                   element.to,
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 SizedBox.shrink(),
//                                 Text(
//                                   "${element.price}",
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ]),

//                               // child: Row(
//                               //   mainAxisAlignment:
//                               //       MainAxisAlignment.spaceBetween,
//                               //   children: [
//                               //     Text(
//                               //       element.from,
//                               //       style: TextStyle(
//                               //           fontSize: 12,
//                               //           fontWeight: FontWeight.w600),
//                               //     ),
//                               //     SizedBox(),
//                               //     Icon(Icons.arrow_forward_rounded),
//                               //     SizedBox(),
//                               //     Text(
//                               //       element.to,
//                               //       style: TextStyle(
//                               //           fontSize: 12,
//                               //           fontWeight: FontWeight.w600),
//                               //     ),
//                               //     SizedBox(
//                               //       width: 30,
//                               //     ),
//                               //     Text(
//                               //       "₹ ${element.price.toString()}",
//                               //       style: TextStyle(
//                               //           fontSize: 12,
//                               //           fontWeight: FontWeight.w600),
//                               //     ),
//                               //   ],
//                               // ),
//                             ]));
//                       },
//                     ),
//                     Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           "*For all other cities price will be higher or lower compared to your selection.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: Colors.grey),
//                         )),
//                     SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//               CheckboxListTile(
//                 title: const Text('Do you provide warehouse services?'),
//                 autofocus: false,
//                 activeColor: Color(0xFF3f51b5),
//                 checkColor: Colors.white,
//                 selected: warehouse,
//                 value: warehouse,
//                 onChanged: (bool value) {
//                   setState(() {
//                     warehouse = value;
//                   });
//                 },
//               ),
//               if (warehouse == true)
//                 CheckboxListTile(
//                   title: const Text(
//                     'Are you providing free 15 days storage for customers?',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                   autofocus: false,
//                   activeColor: Color(0xFF3f51b5),
//                   checkColor: Colors.white,
//                   selected: freeStorage,
//                   value: freeStorage,
//                   onChanged: (bool value) {
//                     setState(() {
//                       freeStorage = value;
//                     });
//                   },
//                 ),
//               if (warehouse == true)
//                 GestureDetector(
//                   onTap: () {
//                     showModalBottomSheet(
//                         isScrollControlled: true,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         context: context,
//                         builder: (BuildContext context) {
//                           return StatefulBuilder(builder: (context, setState) {
//                             return Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 30),
//                               height: MediaQuery.of(context).size.height / 3,
//                               width: MediaQuery.of(context).size.width - 100,
//                               child: Column(
//                                 children: [
//                                   new GridView.builder(
//                                     padding: EdgeInsets.zero,
//                                     gridDelegate:
//                                         SliverGridDelegateWithFixedCrossAxisCount(
//                                             crossAxisCount: 3,
//                                             crossAxisSpacing: 5,
//                                             mainAxisSpacing: 5,
//                                             childAspectRatio: 3 / 1),
//                                     shrinkWrap: true,
//                                     itemCount: cities.length,
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return GestureDetector(
//                                           onTap: () {
//                                             if (additionalSelected[index] ==
//                                                 false) {
//                                               warehouseCities
//                                                   .add(cities[index]);
//                                               setState(() {
//                                                 warehouseCities =
//                                                     warehouseCities;
//                                                 additionalSelected[index] =
//                                                     true;
//                                               });
//                                             }
//                                           },
//                                           child: Container(
//                                               padding: EdgeInsets.all(5),
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(30),
//                                                   border: Border.all(
//                                                     color: Color(0xFF3f51b5),
//                                                   )),
//                                               child: Center(
//                                                   child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 5),
//                                                 child: Row(
//                                                   children: [
//                                                     if (additionalSelected[
//                                                             index] ==
//                                                         true)
//                                                       Icon(Icons.done),
//                                                     Expanded(
//                                                       child: Text(
//                                                         cities[index].name,
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style: TextStyle(
//                                                             fontSize: 10,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w600),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ))));
//                                     },
//                                   ),
//                                   Spacer(),
//                                   Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: MaterialButton(
//                                       color: Color(0xFF3f51b5),
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text(
//                                         'ADD',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             );
//                           });
//                         }).then((val) {
//                       setState(() {
//                         warehouseCities = warehouseCities;
//                       });
//                       print(val);
//                     });
//                   },
//                   child: Card(
//                     child: Container(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Select Cities",
//                             style: TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.w600),
//                           ),
//                           Icon(Icons.arrow_forward_ios),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               SizedBox(
//                 height: 10,
//               ),
//               if (warehouseCities.length != 0 && warehouse == true)
//                 Column(
//                   children: [
//                     Align(
//                       alignment: Alignment.topLeft,
//                       child: Text("  Mention Price per day for each city :",
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           )),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     ListView.builder(
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: warehouseCities.length,
//                       itemBuilder: (BuildContext ctxt, int index) {
//                         return Card(
//                           shape: Border(
//                               bottom: BorderSide(color: Colors.grey, width: 1)),
//                           elevation: 0,
//                           child: Container(
//                               padding: EdgeInsets.all(20),
//                               child: Table(children: [
//                                 TableRow(children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         height: 20,
//                                       ),
//                                       Text(
//                                         warehouseCities[index].name,
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         height: 20,
//                                       ),
//                                       Text(
//                                         "2 BHK",
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                     ],
//                                   ),
//                                   new TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         prefixText: "₹ ",
//                                         isDense: true,
//                                         hintText: "₹ "),
//                                   ),
//                                 ])
//                               ])),
//                         );
//                       },
//                       // optional
//                     ),
//                   ],
//                 ),
//               SizedBox(
//                 height: 30,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
