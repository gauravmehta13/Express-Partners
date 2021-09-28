import 'package:flutter/material.dart';

import '../constants.dart';

class StageCompleted extends StatelessWidget {
  final String tilte;
  final String subtitle;
  const StageCompleted({Key? key, required this.subtitle, required this.tilte})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          SizedBox(
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
