import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:madeira/app/app_essentials/colors.dart';
import 'package:madeira/app/examples/audio_player_example.dart';
import 'package:madeira/app/pages/home_page.dart';
import 'package:madeira/app/pages/login_page.dart';
import 'package:madeira/app/pages/splash_screen.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/services/firebase_messaging_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Services.init();
    await FirebaseMessagingService().initialize();
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
      title: 'Madeira',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.light),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
