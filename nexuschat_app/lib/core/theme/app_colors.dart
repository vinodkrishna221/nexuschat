import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF895BF5);
  static const Color accent = Color(0xFFD946EF);

  // Background
  static const Color backgroundLight = Color(0xFFF6F5F8);
  static const Color backgroundDark = Color(0xFF151022); // #151022 
  // Note: The HTML also uses #0A0A0F for body bg, let's keep both or stick to one.
  // HTML body bg is #0A0A0F. Let's use that as the profound dark background.
  static const Color backgroundDarker = Color(0xFF0A0A0F);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Color(0xFFA291CA);
  
  // Gradients
  static const List<Color> logoGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFD946EF),
  ];
  
  static const List<Color> textGradient = [
    Colors.white,
    Color(0xCCFFFFFF), // white/80
  ];
}
