import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:madeira/app/models/decoration_enquiry_detail_response.dart';
import 'package:madeira/app/models/decoration_enquiry_response.dart';
import 'package:madeira/app/models/decorations_response_model.dart';
import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/login_model.dart';
import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/product_category_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/product_model.dart';
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
import 'package:madeira/app/pages/sale/sale_order.dart';
import 'package:madeira/app/services/firebase_messaging_service.dart';
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
    final fcmToken = FirebaseMessagingService.fcmToken ??
        await FirebaseMessaging.instance.getToken();
    final response = await post(
      endpoint: 'users/login/',
      body: {
        'phone': phone,
        'password': password,
        'token': fcmToken,
      },
    );

    var result = LoginResponse.fromJson(response);
    if (result.access != null) {
      saveAuthToken(result.access!);
      saveUserId(result.user.id.toString());
      AdminTracker.saveAdmin(result.user.isAdmin);
      AdminTracker.saveEnqTaker(result.user.isEnqTaker);
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

  // Product Category APIs
  Future<List<ProductCategory>> getProductCategories() async {
    final response = await get(
      endpoint: 'product_categories/',
    );

    if (response is List) {
      return response.map((json) => ProductCategory.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<ProductCategory> createProductCategory(
      Map<String, dynamic> data) async {
    final response = await post(
      endpoint: 'product_categories/create/',
      body: data,
    );
    return ProductCategory.fromJson(response);
  }

  Future<ProductCategory> updateProductCategory(
      int id, Map<String, dynamic> data) async {
    final response = await put(
      endpoint: 'product_categories/$id/update/',
      body: data,
    );
    return ProductCategory.fromJson(response);
  }

  Future<void> deleteProductCategory(int id) async {
    await delete(
      endpoint: 'product_categories/$id/delete/',
    );
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
    print(data);

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
      method: 'PUT',
      files: {'material_image': images},
    );

    return MaterialModel.fromJson(response);
  }

  // Product APIs
  Future<List<ProductModel>> getProducts() async {
    final response = await get(
      endpoint: 'products/',
    );

    if (response is List) {
      return response.map((json) => ProductModel.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<ProductModel> createProduct(
      Map<String, dynamic> data, List<File> images) async {
    final response = await uploadFormData(
      endpoint: 'products/create/',
      fields: data,
      files: {'product_images': images},
    );
    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct(
      int id, Map<String, dynamic> data, List<File> images) async {
    final response = await uploadFormData(
      endpoint: 'products/$id/update/',
      fields: data,
      method: 'PUT',
      files: {'product_images': images},
    );
    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct(int id) async {
    await delete(
      endpoint: 'products/$id/delete/',
    );
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
      endpoint: 'orders/manager/$status/',
    );

    if (response is List) {
      return response.map((json) => Enquiry.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  Future<CarpenterRequestResponse> getCarpenterRequests() async {
    final carpenterId = await getUserId();
    final response = await get(endpoint: 'carpenter_requests/');
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
      endpoint: 'orders/manager/enquiry/',
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
      endpoint: 'process_details/list/',
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

  Future<void> pauseProcess(int orderId) async {
    print('pausing process $orderId');
    await put(
      endpoint: 'process_details/$orderId/pause/',
      body: {},
    );
  }

  Future<void> resumeProcess(int orderId) async {
    print('resuming process $orderId');
    await put(
      endpoint: 'process_details/$orderId/resume/',
      body: {},
    );
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

  Future<void> deleteProcessMaterial({
    required int processDetailsId,
    required int materialId,
  }) async {
    await post(
      endpoint: 'process_materials/delete/',
      body: {
        'process_details_id': processDetailsId,
        'material_id': materialId,
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
    final response = await get(
      endpoint: 'orders/manager/verification/list/',
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

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await post(
      endpoint: 'users/change_password/',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  //Decoration APIs
  Future<void> createDecoration(String enquiryName) async {
    await post(
      endpoint: 'enquiry_types/create/',
      body: {'enquiry_name': enquiryName},
    );
  }

  Future<List<DecorationResponse>> fetchDecorations() async {
    final response = await get(
      endpoint: 'enquiry_types',
    );
    if (response is List) {
      return response.map((json) => DecorationResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> updateDecoration(int decorationId, String enquiryName) async {
    await put(
      endpoint: 'enquiry_types/${decorationId}/update/',
      body: {'enquiry_name': enquiryName},
    );
  }

  Future<DecorationEnquiryResponse> fetchDecorationsEnquiries() async {
    final response = await get(
      endpoint: 'enquiries',
    );
    return DecorationEnquiryResponse.fromJson(response);
  }

  Future<void> acceptDecorationEnquiryRequest(int enquiryId) async {
    await put(
      endpoint: 'enquiries/$enquiryId/accept/',
      body: {},
    );
  }

  Future<DecorationEnquiryDetailResponse> getDecorEnquiryDetail(
      int enquiryId) async {
    final response = await get(endpoint: 'enquiries/$enquiryId/');
    return DecorationEnquiryDetailResponse.fromJson(response);
  }

  Future<void> updateEnquiryDetails(
      int enquiryId, Map<String, dynamic> data) async {
    await put(
      endpoint: 'enquiries/$enquiryId/update/',
      body: data,
    );
  }

  Future<void> CreateSaleOrder(Map<String, dynamic> data) async {
    await post(
      endpoint: 'sale/create/',
      body: data,
    );
  }

  Future<List<Sale>> fetchSales() async {
    final response = await get(
      endpoint: 'sale/',
    );

    if (response is List) {
      return response.map((json) => Sale.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> updateSaleStatusAndRating({
    required int id,
    required String status,
    required int rating,
  }) async {
    await put(
      endpoint: 'sale/$id/update/',
      body: {
        'delivery_status': status,
        'rating': rating,
      },
    );
  }
}
