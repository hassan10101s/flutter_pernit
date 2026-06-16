import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pernit_colors.dart';
import 'pernit_font_weights.dart';

class PernitTextTheme {
  const PernitTextTheme._();

  static const cairoFontFamily = 'Cairo';

  static TextTheme build() {
    return TextTheme(
      headlineMedium: _style(26, 22, 30, PernitFontWeights.bold, 1.22),
      titleLarge: _style(22, 18, 24, PernitFontWeights.bold, 1.24),
      titleMedium: _style(18, 16, 20, PernitFontWeights.bold, 1.3),
      titleSmall: _style(16, 14, 18, PernitFontWeights.bold, 1.35),
      bodyLarge: _style(16, 14, 18, PernitFontWeights.bold, 1.45),
      bodyMedium: _style(14, 12, 16, PernitFontWeights.bold, 1.45),
      bodySmall: _style(12, 11, 14, PernitFontWeights.bold, 1.45),
      labelLarge: _style(14, 12, 16, PernitFontWeights.bold, 1.3),
      labelMedium: _style(12, 11, 14, PernitFontWeights.bold, 1.3),
      labelSmall: _style(11, 10, 12, PernitFontWeights.bold, 1.25),
    );
  }

  static TextStyle _style(
    double size,
    double min,
    double max,
    FontWeight weight,
    double height,
  ) {
    return TextStyle(
      color: PernitColors.textStrong,
      fontFamily: cairoFontFamily,
      fontSize: size.sp.clamp(min, max).toDouble(),
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }
}
