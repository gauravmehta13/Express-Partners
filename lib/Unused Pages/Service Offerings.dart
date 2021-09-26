// import 'package:flutter/material.dart';
// import 'package:goflexe_partner/Data/PriceData.dart';
// import 'package:goflexe_partner/OnBoarding/Availability.dart';

// import '../Appbar.dart';
// import '../Fade Route.dart';

// class ServiceOfferings extends StatefulWidget {
//   @override
//   _ServiceOfferingsState createState() => _ServiceOfferingsState();
// }

// class _ServiceOfferingsState extends State<ServiceOfferings> {
//   List<Pricing> prices;
//   List<Pricing> withinPrices;
//   TextEditingController one = new TextEditingController();
//   TextEditingController two = new TextEditingController();
//   TextEditingController three = new TextEditingController();

//   List<TextEditingController> oneBhkPrice = [];
//   List<TextEditingController> twoBhkPrice = [];
//   List<TextEditingController> threeBhkPrice = [];
//   @override
//   void initState() {
//     prices = Pricing.getWithinCityPrice();

//     super.initState();

//     for (var i = 0; i < prices.length; i++) {
//       oneBhkPrice.add(TextEditingController());
//       twoBhkPrice.add(TextEditingController());
//       threeBhkPrice.add(TextEditingController());
//     }
//     for (var i = 0; i < prices.length; i++) {
//       oneBhkPrice[i].text = prices[i].oneBHKprice;
//       twoBhkPrice[i].text = prices[i].twoBHKprice;
//       threeBhkPrice[i].text = prices[i].threeBHKprice;
//     }
//   }

//   String location = "";
//   bool warehouse = false;
//   bool showAllPrice = false;
//   bool freeStorage = true;
//   bool additionalChargesSelection = false;
//   bool firstPriceAdded = false;
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
//                       "Add Price",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 )),
//       appBar: PreferredSize(
//           preferredSize: Size(double.infinity, 60),
//           child: MyAppBar(
//             curStep: 3,
//           )),
//       body: SingleChildScrollView(
//         child: Container(
//             padding: EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 80, child: Image.asset("assets/money.png")),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   "Service offerings &  amenities",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(
//                   "Add pricing for service offerings. Not inclusive of taxes.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       showAllPrice == false
//                           ? Container(
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               color: Colors.grey[300],
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Select City :",
//                                     style: TextStyle(
//                                         fontSize: 17,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                   // DropDown(
//                                   //   items: ["Banglore", "Hyderabad", "Chennai"],
//                                   //   hint: Text("From Location"),
//                                   //   initialValue: "Banglore",
//                                   //   onChanged: (e) {
//                                   //     setState(() {
//                                   //       location = e;
//                                   //       print(e);
//                                   //     });
//                                   //   },
//                                   // ),
//                                 ],
//                               ),
//                             )
//                           : Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 10),
//                               width: double.infinity,
//                               color: Colors.grey[300],
//                               child: Text(
//                                 "Banglore :",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (showAllPrice == false)
//                               CheckboxListTile(
//                                 contentPadding: EdgeInsets.all(0),
//                                 title: const Text(
//                                     'Do you provide warehouse services?'),
//                                 autofocus: false,
//                                 activeColor: Color(0xFF3f51b5),
//                                 checkColor: Colors.white,
//                                 selected: warehouse,
//                                 value: warehouse,
//                                 onChanged: (bool value) {
//                                   setState(() {
//                                     warehouse = value;
//                                   });
//                                 },
//                               ),
//                             if (warehouse == true)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Warehousing Pricing :",
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: new TextFormField(
//                                           style: TextStyle(fontSize: 12),
//                                           keyboardType: TextInputType.number,
//                                           decoration: new InputDecoration(
//                                               isDense: true, // Added this
//                                               prefixText: "₹ ",
//                                               labelText: "1 BHK Price",
//                                               labelStyle:
//                                                   TextStyle(fontSize: 13)),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 10,
//                                       ),
//                                       Expanded(
//                                         child: new TextFormField(
//                                           style: TextStyle(fontSize: 12),
//                                           keyboardType: TextInputType.number,
//                                           decoration: new InputDecoration(
//                                               isDense: true, // Added this
//                                               prefixText: "₹ ",
//                                               labelText: "2 BHK Price",
//                                               labelStyle:
//                                                   TextStyle(fontSize: 13)),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 10,
//                                       ),
//                                       Expanded(
//                                         child: new TextFormField(
//                                           style: TextStyle(fontSize: 12),
//                                           keyboardType: TextInputType.number,
//                                           decoration: new InputDecoration(
//                                               isDense: true, // Added this
//                                               prefixText: "₹ ",
//                                               labelText: "3 BHK Price",
//                                               labelStyle:
//                                                   TextStyle(fontSize: 13)),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Text(
//                               "Premium packaging Pricing :",
//                               style: TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.w600),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "1 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "2 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "3 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Text(
//                               "Lift Cost :",
//                               style: TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.w600),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "1 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "2 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Expanded(
//                                   child: new TextFormField(
//                                     style: TextStyle(fontSize: 12),
//                                     keyboardType: TextInputType.number,
//                                     decoration: new InputDecoration(
//                                         isDense: true, // Added this
//                                         prefixText: "₹ ",
//                                         labelText: "3 BHK Price",
//                                         labelStyle: TextStyle(fontSize: 13)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       if (showAllPrice == true)
//                         ListView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: prices.length,
//                           itemBuilder: (context, index) {
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 10),
//                                     width: double.infinity,
//                                     color: Colors.grey[300],
//                                     child: Text(
//                                       "${prices[index].from} :",
//                                       style: TextStyle(
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Warehousing Pricing :",
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "1 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "2 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "3 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 15,
//                                         ),
//                                         Text(
//                                           "Premium packaging Pricing :",
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "1 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "2 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "3 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 15,
//                                         ),
//                                         Text(
//                                           "Lift Cost :",
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "1 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "2 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Expanded(
//                                               child: new TextFormField(
//                                                 controller: oneBhkPrice[index],
//                                                 style: TextStyle(fontSize: 12),
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: new InputDecoration(
//                                                     isDense: true, // Added this
//                                                     prefixText: "₹ ",
//                                                     labelText: "3 BHK Price",
//                                                     labelStyle: TextStyle(
//                                                         fontSize: 13)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 20,
//                                   )
//                                 ]);
//                           },
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//       ),
//     );
//   }
// }
