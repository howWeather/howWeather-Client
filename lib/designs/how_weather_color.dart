import 'dart:core';
import 'package:flutter/material.dart';

final class HowWeatherColor extends Color {
  HowWeatherColor(super.value);

  static const Color black = Color(0xFF1C1C1C);
  static const Color white = Color(0xFFFDFDFD);
  static const Color error = Color.fromARGB(255, 240, 58, 46);

  static const Map<int, Color> primary = <int, Color>{
    50: Color(0xFFE5F1FF),
    100: Color(0xFFCCE1FF),
    200: Color(0xFFB2D1FF),
    300: Color(0xFF99C2FF),
    400: Color(0xFF80B1FF),
    500: Color(0xFF669CFF),
    600: Color(0xFF4D8BFF),
    700: Color(0xFF337EFF),
    800: Color(0xFF1A6EFF),
    900: Color(0xFF005EFF),
  };
  static const Map<int, Color> secondary = <int, Color>{
    50: Color(0xFFFFFCF1),
    100: Color(0xFFFFF8E4),
    200: Color(0xFFFFF1CC),
    300: Color(0xFFFEE9A3),
    400: Color(0xFFFDCE6F),
    500: Color(0xFFF6B53D),
    600: Color(0xFFFAA21E),
    700: Color(0xFFEF8915),
    800: Color(0xFFEB7311),
    900: Color(0xFFE5610F),
  };
  static const Map<int, Color> neutral = <int, Color>{
    50: Color.fromARGB(255, 246, 246, 250),
    100: Color.fromARGB(255, 242, 242, 244),
    200: Color.fromARGB(255, 231, 231, 234),
    300: Color.fromARGB(255, 201, 201, 212),
    400: Color.fromARGB(255, 180, 180, 194),
    500: Color.fromARGB(255, 126, 127, 142),
    600: Color.fromARGB(255, 105, 106, 125),
    700: Color.fromARGB(255, 71, 71, 86),
    800: Color.fromARGB(255, 40, 41, 49),
    900: Color.fromARGB(255, 25, 25, 29),
  };

  static const Map<int, Color> colorMap = {
    1: Color(0xFFEE3737),
    2: Color(0xFFEE8337),
    3: Color(0xFFEEC337),
    4: Color(0xFFABC81A),
    5: Color(0xFF37B4EE),
    6: Color(0xFF3759EE),
    7: Color(0xFF9637EE),
    8: Color(0xFFFF89E3),
    9: Color(0xFFFFFFFF),
    10: Color(0xFF111111),
    11: Color(0xFF743C11),
  };

  static List<double> createColorMatrixFromColor(Color color) {
    // RGB 값을 0~1로 정규화
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    return <double>[
      r, 0, 0, 0, 0, // Red
      0, g, 0, 0, 0, // Green
      0, 0, b, 0, 0, // Blue
      0, 0, 0, 1, 0, // Alpha
    ];
  }

  static const Map<int, String> thicknessMap = {
    1: "얇음",
    2: "보통",
    3: "두꺼움",
  };
}
