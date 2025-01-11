import 'package:base/app/services/service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  static final Services _instance = Services._internal();
  late final ServiceBase base;

  factory Services() {
    return _instance;
  }

  Services._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    base = ServiceBase(prefs);
  }

  Future<dynamic> load() async {
    return base.get(endpoint: '/users/${base.userId}');
  }
}
