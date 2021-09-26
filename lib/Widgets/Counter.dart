library counter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void CounterChangeCallback(num value);

class Counter extends StatelessWidget {
  final CounterChangeCallback onChanged;

  Counter({
    Key? key,
    required num initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.decimalPlaces,
    this.color,
    this.textStyle,
    this.step = 1,
    this.buttonSize = 25,
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        selectedValue = initialValue,
        super(key: key);

  ///min value user can pick
  final num minValue;

  ///max value user can pick
  final num maxValue;

  /// decimal places required by the counter
  final int decimalPlaces;

  ///Currently selected integer value
  num selectedValue;

  /// if min=0, max=5, step=3, then items will be 0 and 3.
  final num step;

  /// indicates the color of fab used for increment and decrement
  Color? color;

  /// text syle
  TextStyle? textStyle;

  final double buttonSize;

  void _incrementCounter() {
    if (selectedValue + step <= maxValue) {
      onChanged((selectedValue + step));
    }
  }

  void _decrementCounter() {
    if (selectedValue - step >= minValue) {
      onChanged((selectedValue - step));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    color = color ?? themeData.accentColor;
    textStyle = textStyle ??
        new TextStyle(
          fontSize: 20.0,
        );

    return new Container(
      padding: new EdgeInsets.all(4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        child: Container(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              new GestureDetector(
                onTap: _decrementCounter,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.remove,
                    color: Color(0xFF3f51b5),
                  ),
                ),
              ),
              new Text(
                  '${num.parse((selectedValue).toStringAsFixed(decimalPlaces))}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              new GestureDetector(
                onTap: _incrementCounter,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF3f51b5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
