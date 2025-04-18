import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:madeira/app/extensions/context_extensions.dart';
import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/models/user_static.dart';
import 'package:madeira/app/pages/home_page.dart';
import 'package:madeira/app/pages/login_page.dart';
import 'package:madeira/app/services/service_base.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      await AdminTracker.getAdmin();
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('user');

      if (user != null) {
        UserStatic.setUser(UserModel.fromJson(jsonDecode(user)));
        context.pushReplacement(() => const HomePage());
      } else {
        context.pushReplacement(() => const LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/splash.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
