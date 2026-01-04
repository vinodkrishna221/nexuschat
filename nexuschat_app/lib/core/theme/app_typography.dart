import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        height: 1.1, // leading-tight
        color: AppColors.textWhite,
        letterSpacing: -0.02, // tracking-tight roughly
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w300, // font-light
        letterSpacing: 3.2, // tracking-[0.2em] = 16 * 0.2
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5, // tracking-wide
        color: AppColors.textWhite.withOpacity(0.2),
      ),
    );
  }
}
