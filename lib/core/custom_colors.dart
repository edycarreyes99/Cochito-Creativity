import 'package:flutter/material.dart';

class CustomColors {
  MaterialColor _primaryColor =
      new MaterialColor(0xFFFCA4A4, const <int, Color>{
    50: const Color(0xFFF8F0FE),
    100: const Color(0xFFF9F6FD),
    200: const Color(0xFFFBF0FE),
    300: const Color(0xFFFEEBF3),
    400: const Color(0xFFFCBEBF),
    500: const Color(0xFFFCA4A4),
    600: const Color(0xFFf48fb1),
    700: const Color(0xFFf06292),
    800: const Color(0xFFec407a),
    900: const Color(0xFFe91e63),
  });

  MaterialColor _accentColor = new MaterialColor(0xFF7B9CB0, const <int, Color>{
    50: const Color(0xFFeceff1),
    100: const Color(0xFFcfd8dc),
    200: const Color(0xFFb0bec5),
    300: const Color(0xFF90a4ae),
    400: const Color(0xFF78909c),
    500: const Color(0xFF7B9CB0),
    600: const Color(0xFF546e7a),
    700: const Color(0xFF455a64),
    800: const Color(0xFF37474f),
    900: const Color(0xFF263238),
  });

  get primaryColor => this._primaryColor;

  get accentColor => this._accentColor;
}
