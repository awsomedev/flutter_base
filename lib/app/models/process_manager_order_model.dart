import 'package:intl/intl.dart';
import 'package:madeira/app/models/process_model.dart';

class ProcessManagerOrderResponse {
  final List<ProcessManagerOrder> data;

  ProcessManagerOrderResponse({required this.data});

  factory ProcessManagerOrderResponse.fromJson(Map<String, dynamic> json) {
    return ProcessManagerOrderResponse(
      data: (json['data'] as List<dynamic>)
          .map((order) => ProcessManagerOrder.fromJson(order))
          .toList(),
    );
  }
}

class ProcessManagerOrder {
  final OrderData orderData;
  final Process process;
  final ProcessDetails processDetails;

  ProcessManagerOrder({
    required this.orderData,
    required this.process,
    required this.processDetails,
  });

  factory ProcessManagerOrder.fromJson(Map<String, dynamic> json) {
    return ProcessManagerOrder(
      orderData: OrderData.fromJson(json['order_data']),
      process: Process.fromJson(json['process']),
      processDetails: ProcessDetails.fromJson(json['process_details']),
    );
  }
}

class OrderData {
  final int? id;
  final String? priority;
  final String? status;
  final String? productName;
  final String? productNameMal;
  final String? productDescription;
  final String? productDescriptionMal;
  final DateTime? estimatedDeliveryDate;
  final String? currentProcessStatus;
  final bool? overDue;
  final int? currentProcess;

  OrderData({
    required this.id,
    required this.priority,
    required this.status,
    required this.productName,
    required this.productNameMal,
    required this.productDescription,
    required this.productDescriptionMal,
    required this.estimatedDeliveryDate,
    required this.currentProcessStatus,
    required this.overDue,
    required this.currentProcess,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] as int?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      productName: json['product_name'] as String?,
      productNameMal: json['product_name_mal'] as String?,
      productDescription: json['product_description'] as String?,
      productDescriptionMal: json['product_description_mal'] as String?,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      currentProcessStatus: json['current_process_status'] as String?,
      overDue: json['over_due'] as bool?,
      currentProcess: json['current_process'] as int?,
    );
  }

  String get formattedDeliveryDate {
    if (estimatedDeliveryDate == null) return 'No date set';
    return DateFormat('dd MMM yyyy').format(estimatedDeliveryDate!);
  }

  String get priorityText => priority?.toUpperCase() ?? '';

  String get statusText =>
      currentProcessStatus?.replaceAll('_', ' ').toUpperCase() ?? '';
}

class ProcessDetails {
  final int? id;
  final List<Map<String, dynamic>>? images;
  final String? processStatus;
  final DateTime? expectedCompletionDate;
  final DateTime? completionDate;
  final double? workersSalary;
  final double? materialPrice;
  final double? totalPrice;
  final String? image;
  final bool? overDue;
  final DateTime? requestAcceptedDate;
  final int? orderId;
  final int? processId;
  final int? mainManagerId;
  final int? processManagerId;
  final List<int>? processWorkersId;

  ProcessDetails({
    required this.id,
    required this.images,
    required this.processStatus,
    required this.expectedCompletionDate,
    this.completionDate,
    required this.workersSalary,
    required this.materialPrice,
    required this.totalPrice,
    this.image,
    required this.overDue,
    required this.requestAcceptedDate,
    required this.orderId,
    required this.processId,
    required this.mainManagerId,
    required this.processManagerId,
    required this.processWorkersId,
  });

  factory ProcessDetails.fromJson(Map<String, dynamic> json) {
    return ProcessDetails(
      id: json['id'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      processStatus: json['process_status'] as String,
      expectedCompletionDate: DateTime.parse(json['expected_completion_date']),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      workersSalary: (json['workers_salary'] as num).toDouble(),
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      image: json['image'] as String?,
      overDue: json['over_due'] as bool,
      requestAcceptedDate: json['request_accepted_date'] != null
          ? DateTime.parse(json['request_accepted_date'])
          : null,
      orderId: json['order_id'] as int,
      processId: json['process_id'] as int,
      mainManagerId: json['main_manager_id'] as int,
      processManagerId: json['process_manager_id'] as int,
      processWorkersId: (json['process_workers_id'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }
}
