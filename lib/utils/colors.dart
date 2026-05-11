import 'package:flutter/material.dart';

class AppColors {
  static const Color biruCerah = Color(0xFF2196F3);
  static const Color biruMedium = Color(0xFF1976D2);
  static const Color biruTua = Color(0xFF0D47A1);
  static const Color biruGelap = Color(0xFF1A237E);
  static const Color lightRed = Color.fromARGB(255, 255, 206, 183);

  static const Color primaryRed = Color(0xFFE53E3E);
  static const Color redLight = Color(0xFFFF6B6B);
  static const Color redDark = Color(0xFFD53E3E);
  static const Color darkText = Color(0xFF2D3748);
  static const Color accentBackground = Color(0xFF1F3467);
  static const Color textGrey = Color(0xFF2D3748);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color shadowBlack = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF5F7FA);
  static const Color softBlue = Color(0xFF046399);
  static const Color deepBlue = Color(0xFF1F3467);
  static const Color mistBlue = Color(0xFF9E383B);
  static const Color warningOrange = Color(0xFFFFA000);
  static const Color green = Color(0xFF2E7D32);

  static const LinearGradient gradientBlue = LinearGradient(
    colors: [biruCerah, biruMedium, biruTua, biruGelap],
    stops: [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientRed = LinearGradient(
    colors: [redLight, primaryRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

extension ColorValuesExt on Color {
  Color withValues({double alpha = 1.0}) => withValues(alpha: alpha);
}
