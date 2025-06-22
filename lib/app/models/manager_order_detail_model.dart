import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/user_model.dart';
import 'package:madeira/app/models/material_model.dart';

class ManagerOrderDetail {
  final OrderData orderData;
  final User mainManager;
  final List<MaterialModel> materials;
  final CarpenterEnquiryData carpenterEnquiryData;
  final List<CompletedProcessData> completedProcessData;
  final CurrentProcess? currentProcess;

  ManagerOrderDetail({
    required this.orderData,
    required this.mainManager,
    required this.materials,
    required this.carpenterEnquiryData,
    required this.completedProcessData,
    this.currentProcess,
  });

  factory ManagerOrderDetail.fromJson(Map<String, dynamic> json) {
    return ManagerOrderDetail(
      orderData: OrderData.fromJson(json['order_data']),
      mainManager: User.fromJson(json['main_manager']),
      materials: (json['materials'] as List<dynamic>)
          .map((material) => MaterialModel.fromJson(material))
          .toList(),
      carpenterEnquiryData:
          CarpenterEnquiryData.fromJson(json['carpenter_enquiry_data']),
      completedProcessData: (json['completed_process_data'] as List<dynamic>)
          .map((process) => CompletedProcessData.fromJson(process))
          .toList(),
      currentProcess: json['current_process'] != null
          ? CurrentProcess.fromJson(json['current_process'])
          : null,
    );
  }
}

class ServerAudioManager {
  final int id;
  final String audio;

  ServerAudioManager({required this.id, required this.audio});

  factory ServerAudioManager.fromJson(Map<String, dynamic> json) {
    return ServerAudioManager(id: json['id'], audio: json['audio']);
  }
}

class OrderData extends Enquiry {
  final double? materialCost;
  final double? ongoingExpense;
  final int? currentProcess;
  final List<int>? completedProcesses;
  final List<ServerAudioManager>? audio;

  OrderData({
    required super.id,
    super.images,
    super.priority,
    super.status,
    super.productName,
    super.productNameMal,
    super.productDescription,
    super.productDescriptionMal,
    super.productLength,
    super.productHeight,
    super.productWidth,
    super.referenceImage,
    super.finish,
    super.event,
    super.estimatedDeliveryDate,
    super.estimatedPrice,
    super.customerName,
    super.contactNumber,
    super.whatsappNumber,
    super.email,
    super.address,
    super.enquiryStatus,
    super.currentProcessStatus,
    super.overDue,
    super.mainManagerId,
    super.carpenterId,
    super.materialIds,
    this.materialCost,
    this.ongoingExpense,
    this.currentProcess,
    this.completedProcesses,
    this.audio,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] as int,
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => EnquiryImage.fromJson(image))
          .toList(),
      audio: (json['audios'] as List<dynamic>?)
          ?.map((audio) => ServerAudioManager.fromJson(audio))
          .toList(),
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      productName: json['product_name'] as String?,
      productNameMal: json['product_name_mal'] as String?,
      productDescription: json['product_description'] as String?,
      productDescriptionMal: json['product_description_mal'] as String?,
      productLength: (json['product_length'] as num?)?.toDouble(),
      productHeight: (json['product_height'] as num?)?.toDouble(),
      productWidth: (json['product_width'] as num?)?.toDouble(),
      referenceImage: json['reference_image'] as String?,
      finish: json['finish'] as String?,
      event: json['event'] as String?,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      estimatedPrice: json['estimated_price'] != null
          ? double.parse(json['estimated_price'].toString())
          : null,
      customerName: json['customer_name'] as String?,
      contactNumber: json['contact_number'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      enquiryStatus: json['enquiry_status'] as String?,
      currentProcessStatus: json['current_process_status'] as String?,
      overDue: json['over_due'] as bool?,
      mainManagerId: json['main_manager_id'] as int?,
      carpenterId: json['carpenter_id'] as int?,
      materialIds: (json['material_ids'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList(),
      materialCost: (json['material_cost'] as num?)?.toDouble(),
      ongoingExpense: (json['ongoing_expense'] as num?)?.toDouble(),
      currentProcess: json['current_process'] as int?,
      completedProcesses: (json['completed_processes'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList(),
    );
  }
}

class CarpenterEnquiryData {
  final User carpenterUser;
  final List<CarpenterData> carpenterData;

  CarpenterEnquiryData({
    required this.carpenterUser,
    required this.carpenterData,
  });

  factory CarpenterEnquiryData.fromJson(Map<String, dynamic> json) {
    return CarpenterEnquiryData(
      carpenterUser: User.fromJson(json['carpenter_user']),
      carpenterData: (json['carpenter_data'] as List<dynamic>)
          .map((data) => CarpenterData.fromJson(data))
          .toList(),
    );
  }
}

class CarpenterData {
  final int id;
  final int orderId;
  final int materialId;
  final double materialLength;
  final double materialHeight;
  final double materialWidth;
  final String status;
  final int carpenterId;
  final double? materialCost;
  final MaterialModel? material;

  CarpenterData({
    required this.id,
    required this.orderId,
    required this.materialId,
    required this.materialLength,
    required this.materialHeight,
    required this.materialWidth,
    required this.status,
    required this.carpenterId,
    this.materialCost,
    this.material,
  });

  factory CarpenterData.fromJson(Map<String, dynamic> json) {
    return CarpenterData(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      materialId: json['material_id'] as int,
      materialLength: json['material_length'] == null
          ? 0
          : (json['material_length'] as num).toDouble(),
      materialHeight: json['material_height'] == null
          ? 0
          : (json['material_height'] as num).toDouble(),
      materialWidth: json['material_width'] == null
          ? 0
          : (json['material_width'] as num).toDouble(),
      status: json['status'] as String,
      carpenterId: json['carpenter_id'] as int,
      materialCost: json['material_cost'] == null
          ? 0
          : double.parse(json['material_cost'].toString()),
      material: json['material'] != null
          ? MaterialModel.fromJson(json['material'])
          : null,
    );
  }
}

class OrderProcess {
  final int id;
  final String name;
  final String nameMal;
  final String description;
  final String descriptionMal;

  OrderProcess({
    required this.id,
    required this.name,
    required this.nameMal,
    required this.description,
    required this.descriptionMal,
  });

  factory OrderProcess.fromJson(Map<String, dynamic> json) {
    return OrderProcess(
      id: json['id'] as int,
      name: json['name'] as String,
      nameMal: json['name_mal'] as String,
      description: json['description'] as String,
      descriptionMal: json['description_mal'] as String,
    );
  }
}

class CompletedProcessData {
  final OrderProcess completedProcess;
  final ProcessDetails completedProcessDetails;
  final List<MaterialUsed> materialsUsed;
  final List<User> workersData;

  CompletedProcessData({
    required this.completedProcess,
    required this.completedProcessDetails,
    required this.materialsUsed,
    required this.workersData,
  });

  factory CompletedProcessData.fromJson(Map<String, dynamic> json) {
    return CompletedProcessData(
      completedProcess: OrderProcess.fromJson(json['completed_process']),
      completedProcessDetails:
          ProcessDetails.fromJson(json['completed_process_details']),
      materialsUsed: (json['materials_used'] as List<dynamic>)
          .map((material) => MaterialUsed.fromJson(material))
          .toList(),
      workersData: (json['workers_data'] as List<dynamic>)
          .map((worker) => User.fromJson(worker))
          .toList(),
    );
  }
}

class ProcessDetails {
  final int id;
  final List<ProcessImage> images;
  final String processStatus;
  final DateTime? expectedCompletionDate;
  final DateTime? completionDate;
  final double workersSalary;
  final double materialPrice;
  final double totalPrice;
  final String? image;
  final bool overDue;
  final DateTime? requestAcceptedDate;
  final int orderId;
  final int processId;
  final int mainManagerId;
  final int processManagerId;
  final List<int> processWorkersId;

  ProcessDetails({
    required this.id,
    required this.images,
    required this.processStatus,
    this.expectedCompletionDate,
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
      images: (json['images'] as List<dynamic>)
          .map((image) => ProcessImage.fromJson(image))
          .toList(),
      processStatus: json['process_status'] as String,
      expectedCompletionDate: json['expected_completion_date'] != null
          ? DateTime.parse(json['expected_completion_date'])
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      workersSalary: (json['workers_salary'] as num).toDouble(),
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      image: json['image'] as String?,
      overDue: json['over_due'] as bool,
      requestAcceptedDate: json['request_accepted_date'] == null
          ? null
          : DateTime.parse(json['request_accepted_date']),
      orderId: json['order_id'] as int,
      processId: json['process_id'] as int,
      mainManagerId: json['main_manager_id'] as int,
      processManagerId: json['process_manager_id'] as int,
      processWorkersId: (json['process_workers_id'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
    );
  }
}

class ProcessImage {
  final int id;
  final String image;

  ProcessImage({
    required this.id,
    required this.image,
  });

  factory ProcessImage.fromJson(Map<String, dynamic> json) {
    return ProcessImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }
}

class MaterialUsed {
  final MaterialModel materialDetails;
  final MaterialUsedInProcess materialUsedInProcess;

  MaterialUsed({
    required this.materialDetails,
    required this.materialUsedInProcess,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) {
    return MaterialUsed(
      materialDetails: MaterialModel.fromJson(
          json['completed_material_details'] ??
              json['current_material_details']),
      materialUsedInProcess: MaterialUsedInProcess.fromJson(
          json['completed_material_used_in_process'] ??
              json['current_material_used_in_process']),
    );
  }
}

class MaterialUsedInProcess {
  final int id;
  final int quantity;
  final double materialPrice;
  final double totalPrice;
  final int processDetailsId;
  final int materialId;

  MaterialUsedInProcess({
    required this.id,
    required this.quantity,
    required this.materialPrice,
    required this.totalPrice,
    required this.processDetailsId,
    required this.materialId,
  });

  factory MaterialUsedInProcess.fromJson(Map<String, dynamic> json) {
    return MaterialUsedInProcess(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      processDetailsId: json['process_details_id'] as int,
      materialId: json['material_id'] as int,
    );
  }
}

class CurrentProcess {
  final OrderProcess? currentProcess;
  final ProcessDetails? currentProcessDetails;
  final List<MaterialUsed>? currentProcessMaterialsUsed;
  final List<User>? currentProcessWorkers;

  CurrentProcess({
    required this.currentProcess,
    required this.currentProcessDetails,
    required this.currentProcessMaterialsUsed,
    required this.currentProcessWorkers,
  });

  factory CurrentProcess.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CurrentProcess(
        currentProcess: null,
        currentProcessDetails: null,
        currentProcessMaterialsUsed: [],
        currentProcessWorkers: [],
      );
    }
    return CurrentProcess(
      currentProcess: json['current_process'] == null
          ? null
          : OrderProcess.fromJson(json['current_process']),
      currentProcessDetails: json['current_process_details'] == null
          ? null
          : ProcessDetails.fromJson(json['current_process_details']),
      currentProcessMaterialsUsed:
          json['current_process_materials_used'] == null
              ? []
              : (json['current_process_materials_used'] as List<dynamic>)
                  .map((material) => MaterialUsed.fromJson(material))
                  .toList(),
      currentProcessWorkers: json['current_process_workers'] == null
          ? []
          : (json['current_process_workers'] as List<dynamic>)
              .map((worker) => User.fromJson(worker))
              .toList(),
    );
  }
}
