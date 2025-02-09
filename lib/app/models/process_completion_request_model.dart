import 'package:madeira/app/models/process_model.dart';

class ProcessCompletionRequest {
  final int? id;
  final String? priority;
  final String? status;
  final String? productName;
  final String? productNameMal;
  final String? productDescription;
  final String? productDescriptionMal;
  final double? productLength;
  final double? productHeight;
  final double? productWidth;
  final String? referenceImage;
  final String? finish;
  final String? event;
  final String? estimatedDeliveryDate;
  final String? address;
  final String? enquiryStatus;
  final String? currentProcessStatus;
  final bool? overDue;
  final dynamic product;
  final int? currentProcess;

  ProcessCompletionRequest({
    this.id,
    this.priority,
    this.status,
    this.productName,
    this.productNameMal,
    this.productDescription,
    this.productDescriptionMal,
    this.productLength,
    this.productHeight,
    this.productWidth,
    this.referenceImage,
    this.finish,
    this.event,
    this.estimatedDeliveryDate,
    this.address,
    this.enquiryStatus,
    this.currentProcessStatus,
    this.overDue,
    this.product,
    this.currentProcess,
  });

  factory ProcessCompletionRequest.fromJson(Map<String, dynamic> json) {
    return ProcessCompletionRequest(
      id: json['id'],
      priority: json['priority'],
      status: json['status'],
      productName: json['product_name'],
      productNameMal: json['product_name_mal'],
      productDescription: json['product_description'],
      productDescriptionMal: json['product_description_mal'],
      productLength: json['product_length']?.toDouble(),
      productHeight: json['product_height']?.toDouble(),
      productWidth: json['product_width']?.toDouble(),
      referenceImage: json['reference_image'],
      finish: json['finish'],
      event: json['event'],
      estimatedDeliveryDate: json['estimated_delivery_date'],
      address: json['address'],
      enquiryStatus: json['enquiry_status'],
      currentProcessStatus: json['current_process_status'],
      overDue: json['over_due'],
      product: json['product'],
      currentProcess: json['current_process'],
    );
  }
}

class ProcessCompletionRequestVerification {
  final Map<String, dynamic>? product;
  final ProcessCompletionRequestOrderData orderData;
  final Process process;
  final ProcessCompletionRequestDetails processDetails;
  final List<MaterialUsed> materials;

  ProcessCompletionRequestVerification({
    this.product,
    required this.orderData,
    required this.process,
    required this.processDetails,
    required this.materials,
  });

  factory ProcessCompletionRequestVerification.fromJson(
      Map<String, dynamic> json) {
    return ProcessCompletionRequestVerification(
      product: json['product'] as Map<String, dynamic>?,
      orderData: ProcessCompletionRequestOrderData.fromJson(json['order_data']),
      process: Process.fromJson(json['process']),
      processDetails:
          ProcessCompletionRequestDetails.fromJson(json['process_details']),
      materials: json['materials'] != null
          ? (json['materials'] as List<dynamic>)
              .map((material) => MaterialUsed.fromJson(material))
              .toList()
          : [],
    );
  }
}

class ProcessCompletionRequestOrderData {
  final int id;
  final List<ProcessImage> images;
  final String priority;
  final String status;
  final String productName;
  final String? productNameMal;
  final String productDescription;
  final String? productDescriptionMal;
  final double productLength;
  final double productHeight;
  final double productWidth;
  final String? referenceImage;
  final String finish;
  final String event;
  final String? estimatedDeliveryDate;
  final String address;
  final String enquiryStatus;
  final String currentProcessStatus;
  final bool overDue;
  final dynamic product;
  final int currentProcess;
  final List<int> completedProcesses;

  ProcessCompletionRequestOrderData({
    required this.id,
    required this.images,
    required this.priority,
    required this.status,
    required this.productName,
    this.productNameMal,
    required this.productDescription,
    this.productDescriptionMal,
    required this.productLength,
    required this.productHeight,
    required this.productWidth,
    this.referenceImage,
    required this.finish,
    required this.event,
    this.estimatedDeliveryDate,
    required this.address,
    required this.enquiryStatus,
    required this.currentProcessStatus,
    required this.overDue,
    this.product,
    required this.currentProcess,
    required this.completedProcesses,
  });

  factory ProcessCompletionRequestOrderData.fromJson(
      Map<String, dynamic> json) {
    return ProcessCompletionRequestOrderData(
      id: json['id'] as int,
      images: (json['images'] as List<dynamic>)
          .map((image) => ProcessImage.fromJson(image))
          .toList(),
      priority: json['priority'] as String,
      status: json['status'] as String,
      productName: json['product_name'] as String,
      productNameMal: json['product_name_mal'] as String?,
      productDescription: json['product_description'] as String,
      productDescriptionMal: json['product_description_mal'] as String?,
      productLength: (json['product_length'] as num).toDouble(),
      productHeight: (json['product_height'] as num).toDouble(),
      productWidth: (json['product_width'] as num).toDouble(),
      referenceImage: json['reference_image'] as String?,
      finish: json['finish'] as String,
      event: json['event'] as String,
      estimatedDeliveryDate: json['estimated_delivery_date'] as String?,
      address: json['address'] as String,
      enquiryStatus: json['enquiry_status'] as String,
      currentProcessStatus: json['current_process_status'] as String,
      overDue: json['over_due'] as bool,
      product: json['product'],
      currentProcess: json['current_process'] as int,
      completedProcesses: (json['completed_processes'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }
}

class ProcessCompletionRequestDetails {
  final int id;
  final List<ProcessImage> images;
  final String processStatus;
  final String? expectedCompletionDate;
  final String? completionDate;
  final double workersSalary;
  final double materialPrice;
  final double totalPrice;
  final String? image;
  final bool overDue;
  final String? requestAcceptedDate;
  final int orderId;
  final int processId;
  final int mainManagerId;
  final int processManagerId;
  final List<int> processWorkersId;

  ProcessCompletionRequestDetails({
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
    this.requestAcceptedDate,
    required this.orderId,
    required this.processId,
    required this.mainManagerId,
    required this.processManagerId,
    required this.processWorkersId,
  });

  factory ProcessCompletionRequestDetails.fromJson(Map<String, dynamic> json) {
    return ProcessCompletionRequestDetails(
      id: json['id'] as int,
      images: (json['images'] as List<dynamic>)
          .map((image) => ProcessImage.fromJson(image))
          .toList(),
      processStatus: json['process_status'] as String,
      expectedCompletionDate: json['expected_completion_date'] as String?,
      completionDate: json['completion_date'] as String?,
      workersSalary: (json['workers_salary'] as num).toDouble(),
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      image: json['image'] as String?,
      overDue: json['over_due'] as bool,
      requestAcceptedDate: json['request_accepted_date'] as String?,
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
  final int id;
  final int quantity;
  final double materialPrice;
  final double totalPrice;
  final int processDetailsId;
  final int materialId;
  final Material material;

  MaterialUsed({
    required this.id,
    required this.quantity,
    required this.materialPrice,
    required this.totalPrice,
    required this.processDetailsId,
    required this.materialId,
    required this.material,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) {
    return MaterialUsed(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      processDetailsId: json['process_details_id'] as int,
      materialId: json['material_id'] as int,
      material: Material.fromJson(json['material']),
    );
  }
}

class Material {
  final int id;
  final List<String> materialImages;
  final String? code;
  final String name;
  final String nameMal;
  final String description;
  final String descriptionMal;
  final String colour;
  final String quality;
  final int quantity;
  final String durability;
  final String stockAvailability;
  final double price;
  final String? referenceImage;
  final double mrpInGst;
  final int category;

  Material({
    required this.id,
    required this.materialImages,
    this.code,
    required this.name,
    required this.nameMal,
    required this.description,
    required this.descriptionMal,
    required this.colour,
    required this.quality,
    required this.quantity,
    required this.durability,
    required this.stockAvailability,
    required this.price,
    this.referenceImage,
    required this.mrpInGst,
    required this.category,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int,
      materialImages: (json['material_images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      code: json['code'] as String?,
      name: json['name'] as String,
      nameMal: json['name_mal'] as String,
      description: json['description'] as String,
      descriptionMal: json['description_mal'] as String,
      colour: json['colour'] as String,
      quality: json['quality'] as String,
      quantity: json['quantity'] as int,
      durability: json['durability'] as String,
      stockAvailability: json['stock_availability'] as String,
      price: (json['price'] as num).toDouble(),
      referenceImage: json['reference_image'] as String?,
      mrpInGst: (json['mrp_in_gst'] as num).toDouble(),
      category: json['category'] as int,
    );
  }
}
