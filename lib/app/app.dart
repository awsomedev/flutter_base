import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/pages/splash_screen.dart';
import 'package:madeira/app/services/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Services.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _buildTheme(brightness) {
      var baseTheme = ThemeData(brightness: brightness);

      return baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        primaryColor: AppColors.primary,
      );
    }

    return MaterialApp(
      title: 'Your App Name',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
