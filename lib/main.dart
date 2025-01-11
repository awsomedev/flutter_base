import 'package:flutter/material.dart';
import 'package:madeira/app/app.dart';

void main() async {
  await App.init();
  runApp(const App());
}
