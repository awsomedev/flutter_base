import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? placeholder;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (AdminTracker.isAdmin) {
      return child;
    }
    return placeholder ?? const SizedBox.shrink();
  }
}

class AdminTracker {
  static bool isAdmin = false;
  static bool isEnqTaker = false;

  static Future<void> saveAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    AdminTracker.isAdmin = isAdmin;
    prefs.setBool('isAdmin', isAdmin);
  }

  static Future<void> saveEnqTaker(bool isEnqTaker) async {
    final prefs = await SharedPreferences.getInstance();
    AdminTracker.isEnqTaker = isEnqTaker;
    prefs.setBool('isEnqTaker', isEnqTaker);
  }

  static Future<bool> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    AdminTracker.isAdmin = prefs.getBool('isAdmin') ?? false;
    AdminTracker.isEnqTaker = prefs.getBool('isEnqTaker') ?? false;

    return AdminTracker.isAdmin;
  }

  static Future<void> clearAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isAdmin');
  }
}
