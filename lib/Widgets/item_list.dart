import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/Items%20Model.dart';

int? _activeMeterIndex = 0;

// ignore: must_be_immutable
class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  Timer? _timer;
  bool expanded = false;
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await loadJson();
    });
  }

  List<Items> items = [];
  bool loading = true;

  loadJson() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/ItemList.json");
    setState(() {
      items =
          (json.decode(data) as List).map((d) => Items.fromJson(d)).toList();
      loading = false;
    });
    if (_activeMeterIndex == 0) {
      load();
    }
  }

  load() {
    _timer = Timer(Duration(seconds: 5), () {
      setState(() {
        _activeMeterIndex = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: ExpansionPanelList(
                dividerColor: Colors.amber,
                expansionCallback: (int index, bool status) {
                  setState(() {
                    _activeMeterIndex = _activeMeterIndex == 0 ? null : 0;
                  });
                },
                children: [
                  ExpansionPanel(
                    backgroundColor: priceBarColor,
                    isExpanded: _activeMeterIndex == 0,
                    headerBuilder: (BuildContext context, bool isExpanded) =>
                        Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        ImageIcon(
                          AssetImage("assets/list.png"),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text("List of Items"),
                      ],
                    ),
                    canTapOnHeader: true,
                    body: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      items[index].type!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: items[index].custom!.length,
                                    padding: EdgeInsets.all(5),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 4,
                                            crossAxisCount: 3,
                                            childAspectRatio: 5),
                                    itemBuilder: (BuildContext context, int i) {
                                      return new Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: new Center(
                                          child: Text(
                                              items[index].custom![i].itemName!,
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Divider()
                              ],
                            ),
                          );
                        }),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
