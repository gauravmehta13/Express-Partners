import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepProgressView extends StatelessWidget {
  final double _width;

  final List<String>? _titles;
  final int _curStep;
  final Color _activeColor;
  final Color _inactiveColor = Colors.grey;
  final double lineWidth = 4.0;

  StepProgressView(
      {Key? key,
      required int curStep,
      List<String>? titles,
      required double width,
      required Color color})
      : _titles = titles,
        _curStep = curStep,
        _width = width,
        _activeColor = color,
        assert(width > 0),
        super(key: key);

  Widget build(BuildContext context) {
    return Container(
        width: this._width,
        child: Column(
          children: <Widget>[
            Row(
              children: _iconViews(),
            ),
          ],
        ));
  }

  List<Widget> _iconViews() {
    var list = <Widget>[];
    _titles!.asMap().forEach((i, icon) {
      var lineColor = _curStep > i + 1 ? _activeColor : _inactiveColor;

      list.add(Container());

      //line between icons
      if (i != _titles!.length - 1) {
        list.add(Expanded(
            child: Container(
          height: lineWidth,
          color: lineColor,
        )));
      }
    });

    return list;
  }
}
