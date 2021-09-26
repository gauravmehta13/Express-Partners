// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:goflexe_partner/Data/PriceData.dart';
// import 'package:goflexe_partner/OnBoarding/Price.dart';
// import 'package:goflexe_partner/Widgets/Item%20List.dart';
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
//   List<Cities> warehouseCities = [];
//   List<Pricing> prices;
//   List<Pricing> withinPrices;
//   TextEditingController one = new TextEditingController();
//   TextEditingController two = new TextEditingController();
//   TextEditingController three = new TextEditingController();
//   List<TextEditingController> withinoneBhkPrice = [];
//   List<TextEditingController> withintwoBhkPrice = [];
//   List<TextEditingController> withinthreeBhkPrice = [];
//   List<TextEditingController> oneBhkPrice = [];
//   List<TextEditingController> twoBhkPrice = [];
//   List<TextEditingController> threeBhkPrice = [];
//   @override
//   void initState() {
//     prices = Pricing.getOutStationPrice();
//     withinPrices = Pricing.getWithinCityPrice();

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
//     for (var i = 0; i < withinPrices.length; i++) {
//       withinoneBhkPrice.add(TextEditingController());
//       withintwoBhkPrice.add(TextEditingController());
//       withinthreeBhkPrice.add(TextEditingController());
//     }
//     for (var i = 0; i < withinPrices.length; i++) {
//       withinoneBhkPrice[i].text = withinPrices[i].oneBHKprice;
//       withintwoBhkPrice[i].text = withinPrices[i].twoBHKprice;
//       withinthreeBhkPrice[i].text = withinPrices[i].threeBHKprice;
//     }
//   }

//   bool warehouse = false;
//   bool showAllPrice = false;
//   bool showNewPrice = false;
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
//           child: SizedBox(
//             height: 50,
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 primary: Color(0xFFf9a825), // background
//                 onPrimary: Colors.white, // foreground
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   FadeRoute(page: AllPrices()),
//                 );
//               },
//               child: Text(
//                 "Next",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           )),
//       appBar: PreferredSize(
//           preferredSize: Size(double.infinity, 60),
//           child: MyAppBar(
//             curStep: 2,
//           )),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 80, child: Image.asset("assets/money.png")),
//               SizedBox(
//                 height: 10,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "Location and Item Pricing",
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
//                 height: 10,
//               ),
//               TextButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                         isScrollControlled: true,
//                         isDismissible: true,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         context: context,
//                         builder: (BuildContext context) {
//                           return StatefulBuilder(builder: (context, setState) {
//                             return Container(
//                                 height: MediaQuery.of(context).size.height *
//                                     (2 / 3),
//                                 padding: EdgeInsets.all(10),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(Icons.close),
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       },
//                                     ),
//                                     // NewItemList(),
//                                   ],
//                                 ));
//                           });
//                         });
//                   },
//                   child: Text(".")),
//               ItemList(),
//               if (!firstPriceAdded)
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Card(
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10),
//                           color: Colors.grey[300],
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Banglore",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.w600),
//                               ),
//                               ElevatedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       showNewPrice = !showNewPrice;
//                                     });
//                                   },
//                                   child: Text("Add Price"))
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: new TextFormField(
//                                   style: TextStyle(fontSize: 12),
//                                   keyboardType: TextInputType.number,
//                                   decoration: new InputDecoration(
//                                     border: new OutlineInputBorder(
//                                         //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                         borderSide: BorderSide(
//                                             color: Colors.white,
//                                             width: 0.0) //This is Ignored,
//                                         ),
//                                     contentPadding: EdgeInsets.all(15),
//                                     isDense: true, // Added this
//                                     prefixText: "₹ ",
//                                     labelText: "1 BHK Price",
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                 child: new TextFormField(
//                                   style: TextStyle(fontSize: 12),
//                                   keyboardType: TextInputType.number,
//                                   decoration: new InputDecoration(
//                                     border: new OutlineInputBorder(
//                                         //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                         borderSide: BorderSide(
//                                             color: Colors.white,
//                                             width: 0.0) //This is Ignored,
//                                         ),
//                                     contentPadding: EdgeInsets.all(15),
//                                     isDense: true, // Added this
//                                     prefixText: "₹ ",
//                                     labelText: "2 BHK Price",
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                 child: new TextFormField(
//                                   style: TextStyle(fontSize: 12),
//                                   keyboardType: TextInputType.number,
//                                   decoration: new InputDecoration(
//                                     border: new OutlineInputBorder(
//                                         //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                         borderSide: BorderSide(
//                                             color: Colors.white,
//                                             width: 0.0) //This is Ignored,
//                                         ),
//                                     contentPadding: EdgeInsets.all(15),
//                                     isDense: true, // Added this
//                                     prefixText: "₹ ",
//                                     labelText: "3 BHK Price",
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         if (showNewPrice == true)
//                           Column(
//                             children: [
//                               Container(
//                                   padding: EdgeInsets.all(10),
//                                   child: Column(children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           width: 100,
//                                           child: Text(
//                                             "Banglore",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                         ),
//                                         Spacer(
//                                           flex: 2,
//                                         ),
//                                         Icon(Icons.arrow_forward_rounded),
//                                         Spacer(
//                                           flex: 2,
//                                         ),
//                                         Text(
//                                           "Hyderabad",
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Spacer()
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               isDense: true,
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "1 BHK Price",
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "2 BHK Price",
//                                               isDense: true,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "3 BHK Price",
//                                               isDense: true,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ])),
//                               Container(
//                                   padding: EdgeInsets.all(10),
//                                   child: Column(children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           width: 100,
//                                           child: Text(
//                                             "Banglore",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                         ),
//                                         Spacer(
//                                           flex: 2,
//                                         ),
//                                         Icon(Icons.arrow_forward_rounded),
//                                         Spacer(
//                                           flex: 2,
//                                         ),
//                                         Text(
//                                           "Chennai",
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                         Spacer()
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               isDense: true,
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "1 BHK Price",
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "2 BHK Price",
//                                               isDense: true,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Expanded(
//                                           child: TextFormField(
//                                             style: TextStyle(fontSize: 12),
//                                             keyboardType: TextInputType.number,
//                                             decoration: InputDecoration(
//                                               border: new OutlineInputBorder(
//                                                   //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                   borderSide: BorderSide(
//                                                       color: Colors.white,
//                                                       width:
//                                                           0.0) //This is Ignored,
//                                                   ),
//                                               contentPadding:
//                                                   EdgeInsets.all(15),
//                                               prefixText: "₹ ",
//                                               labelText: "3 BHK Price",
//                                               isDense: true,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ])),
//                               if (showAllPrice != true)
//                                 ElevatedButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         showAllPrice = true;
//                                       });
//                                     },
//                                     child: Text("Calculate Prices"))
//                             ],
//                           )
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   )
//                 ]),
//               if (showAllPrice == true)
//                 ListView.builder(
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: prices.length - 1,
//                   itemBuilder: (context, index) {
//                     return Column(
//                       children: [
//                         Card(
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 color: Colors.grey[300],
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       prices[index + 1].from,
//                                       style: TextStyle(
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                     ElevatedButton(
//                                         onPressed: () {
//                                           for (var i = 0;
//                                               i < prices.length;
//                                               i++) {
//                                             print(prices[i].expand);
//                                             setState(() {
//                                               prices[i].expand = false;
//                                               showNewPrice = false;
//                                             });
//                                           }
//                                           setState(() {
//                                             prices[index].expand = true;
//                                           });
//                                         },
//                                         child: Text("Edit Price"))
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 10),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: new TextFormField(
//                                         style: TextStyle(fontSize: 12),
//                                         controller: oneBhkPrice[index + 1],
//                                         keyboardType: TextInputType.number,
//                                         decoration: new InputDecoration(
//                                           border: new OutlineInputBorder(
//                                               //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                               borderSide: BorderSide(
//                                                   color: Colors.white,
//                                                   width: 0.0) //This is Ignored,
//                                               ),
//                                           contentPadding: EdgeInsets.all(15),
//                                           isDense: true, // Added this
//                                           prefixText: "₹ ",
//                                           labelText: "1 BHK Price",
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Expanded(
//                                       child: new TextFormField(
//                                         style: TextStyle(fontSize: 12),
//                                         controller: twoBhkPrice[index + 1],
//                                         keyboardType: TextInputType.number,
//                                         decoration: new InputDecoration(
//                                           border: new OutlineInputBorder(
//                                               //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                               borderSide: BorderSide(
//                                                   color: Colors.white,
//                                                   width: 0.0) //This is Ignored,
//                                               ),
//                                           contentPadding: EdgeInsets.all(15),
//                                           isDense: true, // Added this
//                                           prefixText: "₹ ",
//                                           labelText: "2 BHK Price",
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Expanded(
//                                       child: new TextFormField(
//                                         style: TextStyle(fontSize: 12),
//                                         controller: threeBhkPrice[index + 1],
//                                         keyboardType: TextInputType.number,
//                                         decoration: new InputDecoration(
//                                           border: new OutlineInputBorder(
//                                               //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                               borderSide: BorderSide(
//                                                   color: Colors.white,
//                                                   width: 0.0) //This is Ignored,
//                                               ),
//                                           contentPadding: EdgeInsets.all(15),
//                                           isDense: true, // Added this
//                                           prefixText: "₹ ",
//                                           labelText: "3 BHK Price",
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               if (prices[index].expand == true)
//                                 Column(
//                                   children: [
//                                     Container(
//                                         padding: EdgeInsets.all(10),
//                                         child: Column(children: [
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 width: 100,
//                                                 child: Text(
//                                                   prices[index + 1].from,
//                                                   style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                               ),
//                                               Spacer(
//                                                 flex: 2,
//                                               ),
//                                               Icon(Icons.arrow_forward_rounded),
//                                               Spacer(
//                                                 flex: 2,
//                                               ),
//                                               Text(
//                                                 prices[index + 1].to,
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               Spacer()
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height: 10,
//                                           ),
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       oneBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                       border:
//                                                           new OutlineInputBorder(
//                                                               //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                               borderSide: BorderSide(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   width:
//                                                                       0.0) //This is Ignored,
//                                                               ),
//                                                       contentPadding:
//                                                           EdgeInsets.all(15),
//                                                       prefixText: "₹ ",
//                                                       labelText: "1 BHK Price",
//                                                       isDense: true),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       twoBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                     border:
//                                                         new OutlineInputBorder(
//                                                             //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                             borderSide: BorderSide(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 width:
//                                                                     0.0) //This is Ignored,
//                                                             ),
//                                                     contentPadding:
//                                                         EdgeInsets.all(15),
//                                                     prefixText: "₹ ",
//                                                     labelText: "2 BHK Price",
//                                                     isDense: true,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       threeBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                     border:
//                                                         new OutlineInputBorder(
//                                                             //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                             borderSide: BorderSide(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 width:
//                                                                     0.0) //This is Ignored,
//                                                             ),
//                                                     contentPadding:
//                                                         EdgeInsets.all(15),
//                                                     prefixText: "₹ ",
//                                                     labelText: "3 BHK Price",
//                                                     isDense: true,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ])),
//                                     Container(
//                                         padding: EdgeInsets.all(10),
//                                         child: Column(children: [
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 width: 100,
//                                                 child: Text(
//                                                   prices[index + 1].from,
//                                                   style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                 ),
//                                               ),
//                                               Spacer(
//                                                 flex: 2,
//                                               ),
//                                               Icon(Icons.arrow_forward_rounded),
//                                               Spacer(
//                                                 flex: 2,
//                                               ),
//                                               Text(
//                                                 prices[index + 1].to1,
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               Spacer()
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height: 10,
//                                           ),
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       oneBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                       border:
//                                                           new OutlineInputBorder(
//                                                               //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                               borderSide: BorderSide(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   width:
//                                                                       0.0) //This is Ignored,
//                                                               ),
//                                                       contentPadding:
//                                                           EdgeInsets.all(15),
//                                                       prefixText: "₹ ",
//                                                       labelText: "1 BHK Price",
//                                                       isDense: true),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       twoBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                     border:
//                                                         new OutlineInputBorder(
//                                                             //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                             borderSide: BorderSide(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 width:
//                                                                     0.0) //This is Ignored,
//                                                             ),
//                                                     contentPadding:
//                                                         EdgeInsets.all(15),
//                                                     prefixText: "₹ ",
//                                                     labelText: "2 BHK Price",
//                                                     isDense: true,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Expanded(
//                                                 child: TextFormField(
//                                                   controller:
//                                                       threeBhkPrice[index + 1],
//                                                   style:
//                                                       TextStyle(fontSize: 12),
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration: InputDecoration(
//                                                     border:
//                                                         new OutlineInputBorder(
//                                                             //borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//                                                             borderSide: BorderSide(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 width:
//                                                                     0.0) //This is Ignored,
//                                                             ),
//                                                     contentPadding:
//                                                         EdgeInsets.all(15),
//                                                     prefixText: "₹ ",
//                                                     labelText: "3 BHK Price",
//                                                     isDense: true,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ])),
//                                   ],
//                                 )
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         )
//                       ],
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
