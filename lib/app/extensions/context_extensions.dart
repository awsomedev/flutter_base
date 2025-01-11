import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Push a new route
  Future<T?> push<T>(Widget page) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Pop the current route
  void pop<T>([T? result]) {
    Navigator.pop(this, result);
  }

  // Push replacement
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Push and remove until
  Future<T?> pushAndRemoveUntil<T>(
      Widget page, bool Function(Route) predicate) {
    return Navigator.pushAndRemoveUntil<T>(
      this,
      MaterialPageRoute(builder: (context) => page),
      predicate,
    );
  }

  // Replace all routes with a new one
  Future<T?> pushAndRemoveAll<T>(Widget page) {
    return pushAndRemoveUntil<T>(page, (route) => false);
  }

  // Pop until a certain route
  void popUntil(bool Function(Route) predicate) {
    Navigator.popUntil(this, predicate);
  }

  // Check if can pop
  bool get canPop => Navigator.canPop(this);

  // Get MediaQuery shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Brightness get brightness => theme.brightness;
  bool get isDarkMode => brightness == Brightness.dark;

  // Snackbar helper
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
