import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Error404 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/error-404.png',
                  height: 150,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Error",
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please Try Again Later",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),

                // OutlineButton(
                //   child: Text(
                //     "RETRY",
                //     style: TextStyle(
                //       color: Colors.black,
                //     ),
                //   ),
                //   onPressed: () {
                //     AppSettings.openWIFISettings();
                //     Navigator.of(context).pop();
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
