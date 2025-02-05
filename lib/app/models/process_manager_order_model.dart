import 'package:intl/intl.dart';

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
  final int id;
  final String priority;
  final String status;
  final String productName;
  final String productNameMal;
  final String productDescription;
  final String productDescriptionMal;
  final DateTime? estimatedDeliveryDate;
  final String currentProcessStatus;
  final bool overDue;
  final int currentProcess;

  ProcessManagerOrder({
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

  factory ProcessManagerOrder.fromJson(Map<String, dynamic> json) {
    return ProcessManagerOrder(
      id: json['id'] as int,
      priority: json['priority'] as String,
      status: json['status'] as String,
      productName: json['product_name'] as String,
      productNameMal: json['product_name_mal'] as String,
      productDescription: json['product_description'] as String,
      productDescriptionMal: json['product_description_mal'] as String,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      currentProcessStatus: json['current_process_status'] as String,
      overDue: json['over_due'] as bool,
      currentProcess: json['current_process'] as int,
    );
  }

  String get formattedDeliveryDate {
    if (estimatedDeliveryDate == null) return 'No date set';
    return DateFormat('dd MMM yyyy').format(estimatedDeliveryDate!);
  }

  String get priorityText => priority.toUpperCase();

  String get statusText =>
      currentProcessStatus.replaceAll('_', ' ').toUpperCase();
}
