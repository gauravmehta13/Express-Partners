import 'package:flutter/material.dart';

import '../Constants.dart';

class StageCompleted extends StatelessWidget {
  final tilte;
  final subtitle;
  StageCompleted({required this.subtitle, required this.tilte});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
          ),
          Container(
              height: 50, width: 50, child: Image.asset("assets/checked.png")),
          SizedBox(
            height: 30,
          ),
          Text(
            tilte,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 20, color: Colors.grey),
          ),
          C.box10,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
