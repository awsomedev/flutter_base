import 'package:flutter/material.dart';
import 'package:madeira/app/services/services.dart';
import 'package:madeira/app/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Services.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
