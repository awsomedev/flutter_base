import 'package:madeira/app/services/service_base.dart';

extension StringExtension on String? {
  String get toImageUrl => this ?? '';
  String get toUrl => this ?? '';
}
