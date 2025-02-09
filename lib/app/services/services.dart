import 'dart:io';

import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/models/user_model.dart' as user_model;
import 'package:madeira/app/models/carpenter_request_model.dart';
import 'package:madeira/app/models/request_detail_model.dart';
import 'package:madeira/app/models/manager_order_detail_model.dart';
import 'package:madeira/app/models/process_manager_order_model.dart';
import 'package:madeira/app/models/process_detail_model.dart';
import 'package:madeira/app/models/enquiry_detail_response_model.dart'
    as detail_model;
import 'package:madeira/app/models/process_completion_request_model.dart';
import 'package:madeira/app/services/service_base.dart';
import 'package:madeira/app/widgets/admin_only_widget.dart';
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
      saveUserId(result.user.id.toString());
      AdminTracker.saveAdmin(result.user.isAdmin);
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

  Future<MaterialModel> createMaterial(
      Map<String, dynamic> data, List<File> images) async {
    final response = await uploadFormData(
      endpoint: 'materials/create/',
      fields: data,
      files: {'material_image': images},
    );
    return MaterialModel.fromJson(response);
  }

  Future<void> deleteMaterial(int id) async {
    await delete(
      endpoint: 'materials/$id/delete/',
    );
  }

  Future<MaterialModel> updateMaterial(
      int id, Map<String, dynamic> data, List<File> images) async {
    final response = await uploadFormData(
      endpoint: 'materials/$id/update/',
      fields: data,
      files: {'material_image': images},
    );
    return MaterialModel.fromJson(response);
  }

  Future<List<user_model.User>> getUsers() async {
    final response = await get(endpoint: 'users/');
    if (response is List) {
      return response.map((json) => user_model.User.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<void> deleteUser(int id) async {
    await delete(
      endpoint: 'users/delete/$id/',
    );
  }

  Future<user_model.User> createUser(Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'create-user/',
      body: data,
    );
    return user_model.User.fromJson(response);
  }

  Future<user_model.User> updateUser(int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'users/$id/update/',
      body: data,
    );
    return user_model.User.fromJson(response);
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

  Future<Enquiry> createEnquiry(
      Map<String, dynamic> data, Map<String, List<File>>? files) async {
    final response = await uploadFormData(
      endpoint: 'orders/create/',
      fields: data,
      files: files,
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

  Future<List<Enquiry>> getManagerOrdersByStatus(
      int managerId, String status) async {
    final response = await get(
      endpoint: 'orders/manager/$managerId/$status/',
    );

    if (response is List) {
      return response.map((json) => Enquiry.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<CarpenterRequestResponse> getCarpenterRequests() async {
    final carpenterId = await getUserId();
    final response = await get(endpoint: 'carpenter_requests/$carpenterId/');
    return CarpenterRequestResponse.fromJson(response);
  }

  Future<void> acceptCarpenterRequest(int orderId) async {
    await put(
      endpoint: 'carpenter_requests/$orderId/accept/',
      body: {},
    );
  }

  Future<RequestDetail> getRequestDetail(int orderId) async {
    final response = await get(endpoint: 'carpenter_requests/$orderId/view/');
    return RequestDetail.fromJson(response['data']);
  }

  Future<void> updateRequestDimensions(List<Map<String, dynamic>> data) async {
    await put(
      endpoint: 'carpenter_requests/update/',
      body: {
        'data': data,
      },
    );
  }

  Future<void> finishRequest(int orderId) async {
    await put(
      endpoint: 'carpenter_requests/$orderId/respond/',
      body: {},
    );
  }

  Future<void> addToProcess({
    required int orderId,
    required int processId,
    required int processManagerId,
    required List<int> processWorkersId,
    required String expectedCompletionDate,
  }) async {
    await post(
      endpoint: 'orders/manager/add_to_process/',
      body: {
        'order_id': orderId,
        'process_id': processId,
        'process_manager_id': processManagerId,
        'process_workers_id': processWorkersId,
        'expected_completion_date': expectedCompletionDate,
      },
    );
  }

  Future<List<Enquiry>> getManagerEnquiries(int managerId) async {
    final response = await get(
      endpoint: 'orders/manager/$managerId/enquiry/',
    );

    if (response is List) {
      return response.map((json) => Enquiry.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<ManagerOrderDetail> getManagerOrderDetail(int orderId) async {
    final response = await get(endpoint: 'orders/manager/$orderId/');
    return ManagerOrderDetail.fromJson(response);
  }

  Future<ProcessManagerOrderResponse> getProcessManagerOrders(
      int processManagerId) async {
    final response = await get(
      endpoint: 'process_details/$processManagerId/list/',
    );
    return ProcessManagerOrderResponse.fromJson(response);
  }

  Future<void> acceptProcessOrder(int orderId) async {
    await put(
      endpoint: 'process_details/$orderId/accept/',
      body: {},
    );
  }

  Future<ProcessDetailResponse> getProcessDetail(int processId) async {
    final response = await get(
      endpoint: 'process_details/$processId/view/',
    );
    return ProcessDetailResponse.fromJson(response);
  }

  Future<void> createProcessMaterial({
    required int processDetailsId,
    required int materialId,
    required int quantity,
  }) async {
    await post(
      endpoint: 'process_materials/create/',
      body: {
        'process_details_id': processDetailsId,
        'material_id': materialId,
        'quantity': quantity,
      },
    );
  }

  Future<void> sendProcessVerificationImages(
      int processId, List<File> images) async {
    final Map<String, List<File>> files = {
      'image': images,
    };
    await uploadFormData(
      endpoint: 'process_details/add_to_process_verification/$processId/',
      method: 'PUT',
      files: files,
    );
  }

  Future<detail_model.EnquiryDetailResponse> getEnquiryDetails(
      int enquiryId) async {
    final response = await get(
      endpoint: 'orders/$enquiryId/',
    );
    return detail_model.EnquiryDetailResponse.fromJson(response);
  }

  Future<List<ProcessCompletionRequest>> getProcessCompletionRequests() async {
    final userId = await getUserId();
    final response = await get(
      endpoint: 'orders/manager/$userId/verification/list/',
    );

    if (response is List) {
      return response
          .map((json) => ProcessCompletionRequest.fromJson(json))
          .toList();
    } else {
      return [];
    }
  }

  Future<ProcessCompletionRequestVerification>
      getProcessCompletionRequestVerification(int orderId) async {
    final response = await get(
      endpoint: 'orders/manager/$orderId/verification/view/',
    );
    return ProcessCompletionRequestVerification.fromJson(response['data']);
  }

  Future<void> acceptProcessVerification(int orderId) async {
    await put(
      endpoint: 'orders/manager/$orderId/verification/accept/',
      body: {},
    );
  }

  Future<void> rejectProcessVerification(int orderId) async {
    await put(
      endpoint: 'orders/manager/$orderId/verification/reject/',
      body: {},
    );
  }

  Future<void> finishOrder(int orderId) async {
    await put(
      endpoint: 'orders/$orderId/completed/',
      body: {},
    );
  }
}
