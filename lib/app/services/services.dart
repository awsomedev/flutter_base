import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/models/user_model.dart';
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

  Future<List<Category>> getCategories() async {
    final response = await get(
      endpoint: 'categories/',
    );

    if (response is List) {
      return response.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'categories/create/',
      body: data,
    );
    return Category.fromJson(response);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'categories/$id/update/',
      body: data,
    );
    return Category.fromJson(response);
  }

  Future<List<MaterialModel>> getMaterials() async {
    final response = await get(
      endpoint: 'materials/',
    );

    if (response is List) {
      return response.map((json) => MaterialModel.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<MaterialModel> createMaterial(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'materials/create/',
      body: data,
    );
    return MaterialModel.fromJson(response);
  }

  Future<void> deleteMaterial(int id) async {
    await delete(
      endpoint: 'materials/$id/delete/',
    );
  }

  Future<MaterialModel> updateMaterial(
      int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'materials/$id/update/',
      body: data,
    );
    return MaterialModel.fromJson(response);
  }

  Future<List<User>> getUsers() async {
    final response = await get(
      endpoint: 'users',
    );

    if (response is List) {
      return response.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<void> deleteUser(int id) async {
    await delete(
      endpoint: 'users/delete/$id/',
    );
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'create-user/',
      body: data,
    );
    return User.fromJson(response);
  }

  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'users/$id/update/',
      body: data,
    );
    return User.fromJson(response);
  }

  Future<List<Process>> getProcesses() async {
    final response = await get(
      endpoint: 'processes/',
    );

    if (response is List) {
      return response.map((json) => Process.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<Process> createProcess(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'processes/create/',
      body: data,
    );
    return Process.fromJson(response);
  }

  Future<Process> updateProcess(int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'processes/$id/update/',
      body: data,
    );
    return Process.fromJson(response);
  }

  Future<void> deleteProcess(int id) async {
    await delete(
      endpoint: 'processes/$id/delete/',
    );
  }

  Future<List<Enquiry>> getEnquiries() async {
    final response = await get(
      endpoint: 'orders/status/enquiry/',
    );

    if (response is List) {
      return response.map((json) => Enquiry.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<Map<String, dynamic>> getEnquiryCreationData() async {
    final response = await get(
      endpoint: 'orders/creation-data/',
    );
    return response;
  }

  Future<Enquiry> createEnquiry(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'orders/create/',
      body: data,
    );
    return Enquiry.fromJson(response);
  }

  Future<void> requestCarpenter(int enquiryId) async {
    await post(
      endpoint: 'orders/carpenter_request/$enquiryId/',
      body: {},
    );
  }

  Future<List<Enquiry>> getOrdersByStatus(String status) async {
    final response = await get(
      endpoint: 'orders/status/$status/',
    );

    if (response is List) {
      return response.map((json) => Enquiry.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }
}
