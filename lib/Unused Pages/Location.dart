// import 'package:flutter/material.dart';
// import 'package:goflexe_partner/OnBoarding/Pricing%20Details.dart';
// import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
// import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
// import 'package:multi_select_flutter/util/multi_select_item.dart';
// import 'package:multi_select_flutter/util/multi_select_list_type.dart';

// class Place {
//   bool isSelected;
//   final String title;
//   Place(
//     this.isSelected,
//     this.title,
//   );
// }

// class Cities {
//   int id;
//   String name;

//   Cities({this.id, this.name});
// }

// class Location extends StatefulWidget {
//   @override
//   _LocationState createState() => _LocationState();
// }

// class _LocationState extends State<Location> {
//   List<Place> place = [];
//   @override
//   void initState() {
//     super.initState();
//     place.add(new Place(true, 'Intracity'));
//     place.add(new Place(false, 'Intercity'));
//   }

//   String selectedPlace;

//   static List<Cities> _cities = [
//     Cities(id: 0, name: "Mumbai"),
//     Cities(id: 1, name: "Delhi"),
//     Cities(id: 2, name: "NCR"),
//     Cities(id: 3, name: "Banglore"),
//     Cities(id: 4, name: "Hyderabad"),
//     Cities(id: 5, name: "Pune"),
//     Cities(id: 6, name: "Ahemdabad"),
//     Cities(id: 7, name: "Chennai"),
//   ];
//   final _items = _cities
//       .map((extraItems) => MultiSelectItem<Cities>(
//             extraItems,
//             extraItems.name,
//           ))
//       .toList();
//   List<dynamic> _newCities = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
//         child: SizedBox(
//           height: 50,
//           width: double.infinity,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               primary: Color(0xFFf9a825), // background
//               onPrimary: Colors.white, // foreground
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PricingDetails()),
//               );
//             },
//             child: Text(
//               "Next",
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ),
//       ),
//       appBar: AppBar(
//         elevation: 1,
//         title: Text(
//           "GoFlexe",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Image.asset("assets/map.png"),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   "Specify Service Areas",
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(
//                   "In order to complete your registration, we need the following details from you.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: Colors.grey),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(5),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(
//                       25.0,
//                     ),
//                   ),
//                   child: new GridView.builder(
//                     padding: EdgeInsets.zero,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, childAspectRatio: 4 / 1),
//                     shrinkWrap: true,
//                     itemCount: place.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return new GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedPlace = place[index].title;
//                             place.forEach((element) {
//                               element.isSelected = false;
//                             });
//                             place[index].isSelected = true;
//                             print(place[index].title);
//                             // StoreProvider.of<AppState>(context)
//                             //     .dispatch(ShiftType(place[index]));
//                           });
//                         },
//                         child: new PlaceSelection(place[index]),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 MultiSelectBottomSheetField(
//                   initialChildSize: 0.4,
//                   listType: MultiSelectListType.CHIP,
//                   searchable: true,
//                   buttonText: Text(
//                     "Select Cities",
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//                   ),
//                   title: Text("Additional Items"),
//                   items: _items,
//                   onConfirm: (values) {
//                     setState(() {
//                       _newCities = values;
//                     });
//                   },
//                   chipDisplay: MultiSelectChipDisplay(
//                     onTap: (value) {
//                       setState(() {
//                         _newCities.remove(value);
//                       });
//                     },
//                   ),
//                 ),
//                 _newCities.isEmpty
//                     ? Container(
//                         padding: EdgeInsets.all(10),
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "No Cities Selected",
//                           style: TextStyle(color: Colors.black54),
//                         ))
//                     : Container(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlaceSelection extends StatelessWidget {
//   final Place _item;
//   PlaceSelection(this._item);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: _item.isSelected ? Color(0xFF3f51b5) : Colors.transparent,
//         borderRadius: BorderRadius.circular(
//           25.0,
//         ),
//       ),
//       child: Center(
//         child: Text(_item.title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 color: _item.isSelected ? Colors.white : Colors.black,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600)),
//       ),
//     );
//   }
// }
