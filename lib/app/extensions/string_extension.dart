import 'package:madeira/app/services/service_base.dart';

extension StringExtension on String? {
  String get toImageUrl =>
      '${ServiceBase.baseUrl.replaceAll('api/', 'api')}$this';
  String get toUrl => '${ServiceBase.baseUrl.replaceAll('api/', 'api')}$this';
}
