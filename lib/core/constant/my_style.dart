import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyStyle {
  //Branding TextStyles
  static TextStyle b1 = GoogleFonts.cinzelDecorative(
    fontWeight: FontWeight.bold,
    fontSize: 32,
  );
  static TextStyle b2 = GoogleFonts.cinzelDecorative(
    fontWeight: FontWeight.bold,
    fontSize: 28,
  );
  static TextStyle b3 = GoogleFonts.cinzelDecorative(
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
  static TextStyle b4 = GoogleFonts.cinzelDecorative(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  static TextStyle b5 = GoogleFonts.cinzelDecorative(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  //System TextStyles
  static TextStyle s1 = GoogleFonts.cairo(
    fontSize: 22,
  );
  static TextStyle s2 = GoogleFonts.cairo(
    fontSize: 18,
  );
  static TextStyle s3 = GoogleFonts.cairo(
    fontSize: 14,
  );
  static TextStyle s4 = GoogleFonts.cairo(
    fontSize: 10,
  );

  //Button TextStyles
  static TextStyle button = GoogleFonts.cairo(
    fontWeight: FontWeight.w900,
    fontSize: 12,
  );
  static TextStyle buttonBig = GoogleFonts.cairo(
    fontWeight: FontWeight.w900,
    fontSize: 18,
  );
}
