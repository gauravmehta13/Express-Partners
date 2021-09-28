import 'package:flutter/material.dart';

import 'progress_bar.dart';

class MyAppBar extends StatelessWidget {
  final int curStep;
  final String? title;
  MyAppBar({required this.curStep, this.title});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: Text(
        title ?? "Express",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, 10.0),
        child: StepProgressView(
            width: MediaQuery.of(context).size.width,
            curStep: curStep,
            color: Color(0xFFf9a825),
            titles: [
              "",
              "",
              "",
            ]),
      ),
    );
  }
}
