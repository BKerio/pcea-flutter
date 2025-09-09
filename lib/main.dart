import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = Theme.of(context).textTheme;

    final headlineFont = GoogleFonts.poppinsTextTheme(baseTextTheme);
    final bodyFont = GoogleFonts.robotoTextTheme(baseTextTheme);
    final _ = GoogleFonts.sourceCodeProTextTheme(baseTextTheme);

    final mergedTextTheme = bodyFont
        .copyWith(
          displayLarge: headlineFont.displayLarge,
          displayMedium: headlineFont.displayMedium,
          displaySmall: headlineFont.displaySmall,
          headlineLarge: headlineFont.headlineLarge,
          headlineMedium: headlineFont.headlineMedium,
          headlineSmall: headlineFont.headlineSmall,
          titleLarge: headlineFont.titleLarge,
          titleMedium: headlineFont.titleMedium,
          titleSmall: headlineFont.titleSmall,
          labelLarge: headlineFont.labelLarge,
          labelMedium: headlineFont.labelMedium,
          labelSmall: headlineFont.labelSmall,
          bodySmall: bodyFont.bodySmall,
          bodyMedium: bodyFont.bodyMedium,
          bodyLarge: bodyFont.bodyLarge,
        )
        .apply(
          // Default color tweaks can go here if needed
        );

    final appTheme = ThemeData(
      useMaterial3: true,
      textTheme: mergedTextTheme,
      primaryTextTheme: mergedTextTheme,
      typography: Typography.material2021(platform: defaultTargetPlatform),
    );

    return MaterialApp(
      title: 'e-Kanisa App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: SplashScreen(),
    );
  }
}
