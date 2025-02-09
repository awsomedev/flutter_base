import 'package:madeira/app/models/enquiry_model.dart';
import 'package:madeira/app/models/user_model.dart';

class ProcessDetailResponse {
  final ProcessDetailData data;

  ProcessDetailResponse({required this.data});

  factory ProcessDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProcessDetailResponse(
      data: ProcessDetailData.fromJson(json['data']),
    );
  }
}

class ProcessDetailData {
  final ProcessOrderData orderData;
  final User mainManager;
  final ProcessDetails processDetails;
  final User processManager;
  final List<User> workersData;
  final List<UsedMaterial> usedMaterials;

  ProcessDetailData({
    required this.orderData,
    required this.mainManager,
    required this.processDetails,
    required this.processManager,
    required this.workersData,
    required this.usedMaterials,
  });

  factory ProcessDetailData.fromJson(Map<String, dynamic> json) {
    return ProcessDetailData(
      orderData: ProcessOrderData.fromJson(json['order_data']),
      mainManager: User.fromJson(json['main_manager']),
      processDetails: ProcessDetails.fromJson(json['process_details']),
      processManager: User.fromJson(json['process_manager']),
      workersData: (json['workers_data'] as List<dynamic>)
          .map((worker) => User.fromJson(worker))
          .toList(),
      usedMaterials: json['used_materials'] != null
          ? (json['used_materials'] as List<dynamic>)
              .map((material) => UsedMaterial.fromJson(material))
              .toList()
          : [],
    );
  }
}

class ProcessOrderData {
  final int id;
  final List<EnquiryImage> images;
  final String priority;
  final String status;
  final String productName;
  final String productNameMal;
  final String productDescription;
  final String productDescriptionMal;
  final double productLength;
  final double productHeight;
  final double productWidth;
  final String finish;
  final String event;
  final DateTime? estimatedDeliveryDate;
  final String currentProcessStatus;
  final bool overDue;

  ProcessOrderData({
    required this.id,
    required this.images,
    required this.priority,
    required this.status,
    required this.productName,
    required this.productNameMal,
    required this.productDescription,
    required this.productDescriptionMal,
    required this.productLength,
    required this.productHeight,
    required this.productWidth,
    required this.finish,
    required this.event,
    this.estimatedDeliveryDate,
    required this.currentProcessStatus,
    required this.overDue,
  });

  factory ProcessOrderData.fromJson(Map<String, dynamic> json) {
    return ProcessOrderData(
      id: json['id'] as int,
      images: (json['images'] as List<dynamic>)
          .map((image) => EnquiryImage.fromJson(image))
          .toList(),
      priority: json['priority'] as String,
      status: json['status'] as String,
      productName: json['product_name'] as String,
      productNameMal: json['product_name_mal'] as String,
      productDescription: json['product_description'] as String,
      productDescriptionMal: json['product_description_mal'] as String,
      productLength: (json['product_length'] as num).toDouble(),
      productHeight: (json['product_height'] as num).toDouble(),
      productWidth: (json['product_width'] as num).toDouble(),
      finish: json['finish'] as String,
      event: json['event'] as String,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      currentProcessStatus: json['current_process_status'] as String,
      overDue: json['over_due'] as bool,
    );
  }
}

class ProcessDetails {
  final int id;
  final List<ProcessImage> images;
  final String processStatus;
  final DateTime? expectedCompletionDate;
  final DateTime? completionDate;
  final bool overDue;
  final DateTime? requestAcceptedDate;
  final int processId;

  ProcessDetails({
    required this.id,
    required this.images,
    required this.processStatus,
    this.expectedCompletionDate,
    this.completionDate,
    required this.overDue,
    this.requestAcceptedDate,
    required this.processId,
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
      overDue: json['over_due'] as bool,
      requestAcceptedDate: json['request_accepted_date'] != null
          ? DateTime.parse(json['request_accepted_date'])
          : null,
      processId: json['process_id'] as int,
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

class UsedMaterial {
  final Material material;
  final MaterialUsed materialUsed;

  UsedMaterial({
    required this.material,
    required this.materialUsed,
  });

  factory UsedMaterial.fromJson(Map<String, dynamic> json) {
    return UsedMaterial(
      material: Material.fromJson(json['material']),
      materialUsed: MaterialUsed.fromJson(json['material_used']),
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

class MaterialUsed {
  final int id;
  final int quantity;
  final double materialPrice;
  final double totalPrice;
  final int processDetailsId;
  final int materialId;

  MaterialUsed({
    required this.id,
    required this.quantity,
    required this.materialPrice,
    required this.totalPrice,
    required this.processDetailsId,
    required this.materialId,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) {
    return MaterialUsed(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      materialPrice: (json['material_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      processDetailsId: json['process_details_id'] as int,
      materialId: json['material_id'] as int,
    );
  }
}
