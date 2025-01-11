import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/services/service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services extends ServiceBase {
  static Services? _instance;

  factory Services() {
    if (_instance == null) {
      throw Exception('Services not initialized. Call Services.init() first.');
    }
    return _instance!;
  }

  Services._internal(SharedPreferences prefs) : super(prefs);

  static Future<void> init() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = Services._internal(prefs);
    }
  }

  // Auth APIs
  Future<LoginResponse> login({
    required String phone,
    required String password,
  }) async {
    final response = await post(
      endpoint: 'users/login/',
      body: {
        'phone': phone,
        'password': password,
      },
    );

    var result = LoginResponse.fromJson(response);
    if (result.access != null) {
      saveAuthToken(result.access!);
    }
    return result;
  }
}
