class EnquiryDetailMaterial {
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

  EnquiryDetailMaterial({
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

  factory EnquiryDetailMaterial.fromJson(Map<String, dynamic> json) {
    return EnquiryDetailMaterial(
      id: json['id'] as int,
      materialImages: (json['material_images'] as List<dynamic>).cast<String>(),
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

class EnquiryDetailUser {
  final String name;
  final String email;
  final DateTime? dateOfBirth;
  final String phone;
  final int age;
  final double salaryPerHr;

  EnquiryDetailUser({
    required this.name,
    required this.email,
    this.dateOfBirth,
    required this.phone,
    required this.age,
    required this.salaryPerHr,
  });

  factory EnquiryDetailUser.fromJson(Map<String, dynamic> json) {
    return EnquiryDetailUser(
      name: json['name'] as String,
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      phone: json['phone'] as String,
      age: json['age'] as int,
      salaryPerHr: (json['salary_per_hr'] as num).toDouble(),
    );
  }
}

class CarpenterData {
  final int? id;
  final int? orderId;
  final int? materialId;
  final double? materialLength;
  final double? materialHeight;
  final double? materialWidth;
  final String? status;
  final int? carpenterId;
  final double? materialCost;
  final Material? material;

  CarpenterData({
    this.id,
    this.orderId,
    this.materialId,
    this.materialLength,
    this.materialHeight,
    this.materialWidth,
    this.status,
    this.carpenterId,
    this.materialCost,
    this.material,
  });

  factory CarpenterData.fromJson(Map<String, dynamic> json) {
    return CarpenterData(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      materialId: json['material_id'] as int?,
      materialLength: (json['material_length'] as num?)?.toDouble(),
      materialHeight: (json['material_height'] as num?)?.toDouble(),
      materialWidth: (json['material_width'] as num?)?.toDouble(),
      status: json['status'] as String?,
      carpenterId: json['carpenter_id'] as int?,
      materialCost: (json['material_cost'] as num?)?.toDouble(),
      material:
          json['material'] != null ? Material.fromJson(json['material']) : null,
    );
  }
}

class CarpenterEnquiryDetailData {
  final EnquiryDetailUser? carpenterUser;
  final List<CarpenterData>? carpenterData;

  CarpenterEnquiryDetailData({
    required this.carpenterUser,
    required this.carpenterData,
  });

  factory CarpenterEnquiryDetailData.fromJson(Map<String, dynamic> json) {
    return CarpenterEnquiryDetailData(
      carpenterUser: json['carpenter_user'] != null
          ? EnquiryDetailUser.fromJson(json['carpenter_user'])
          : null,
      carpenterData: (json['carpenter_data'] as List<dynamic>?)
          ?.map((data) => CarpenterData.fromJson(data))
          .toList(),
    );
  }
}

class Product {
  final int? id;
  final List<MaterialImage>? materialImages;
  final String? code;
  final String? name;
  final String? nameMal;
  final String? description;
  final String? descriptionMal;
  final String? colour;
  final String? quality;
  final int? quantity;
  final String? durability;
  final String? stockAvailability;
  final double? price;
  final String? referenceImage;
  final double? mrpInGst;
  final int? category;

  Product({
    required this.id,
    required this.materialImages,
    required this.code,
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      materialImages: (json['material_images'] as List<dynamic>?)
          ?.map((image) => MaterialImage.fromJson(image))
          .toList(),
      code: json['code'] as String?,
      name: json['name'] as String?,
      nameMal: json['name_mal'] as String?,
      description: json['description'] as String?,
      descriptionMal: json['description_mal'] as String?,
      colour: json['colour'] as String?,
      quality: json['quality'] as String?,
      quantity: json['quantity'] as int?,
      durability: json['durability'] as String?,
      stockAvailability: json['stock_availability'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      referenceImage: json['reference_image'] as String?,
      mrpInGst: (json['mrp_in_gst'] as num?)?.toDouble(),
      category: json['category'] as int?,
    );
  }
}

class Material {
  final int? id;
  final List<String>? materialImages;
  final String? code;
  final String? name;
  final String? nameMal;
  final String? description;
  final String? descriptionMal;
  final String? colour;
  final String? quality;
  final int? quantity;
  final String? durability;
  final String? stockAvailability;
  final double? price;
  final String? referenceImage;
  final double? mrpInGst;
  final int? category;

  Material({
    this.id,
    this.materialImages,
    this.code,
    this.name,
    this.nameMal,
    this.description,
    this.descriptionMal,
    this.colour,
    this.quality,
    this.quantity,
    this.durability,
    this.stockAvailability,
    this.price,
    this.referenceImage,
    this.mrpInGst,
    this.category,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int?,
      materialImages:
          (json['material_images'] as List<dynamic>?)?.cast<String>(),
      code: json['code'] as String?,
      name: json['name'] as String?,
      nameMal: json['name_mal'] as String?,
      description: json['description'] as String?,
      descriptionMal: json['description_mal'] as String?,
      colour: json['colour'] as String?,
      quality: json['quality'] as String?,
      quantity: json['quantity'] as int?,
      durability: json['durability'] as String?,
      stockAvailability: json['stock_availability'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      referenceImage: json['reference_image'] as String?,
      mrpInGst: (json['mrp_in_gst'] as num?)?.toDouble(),
      category: json['category'] as int?,
    );
  }
}

class EnquiryImage {
  final int? id;
  final String? image;

  EnquiryImage({
    this.id,
    this.image,
  });

  factory EnquiryImage.fromJson(Map<String, dynamic> json) {
    return EnquiryImage(
      id: json['id'] as int?,
      image: json['image'] as String?,
    );
  }
}

class OrderData {
  final int? id;
  final List<EnquiryImage>? images;
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
  final DateTime? estimatedDeliveryDate;
  final double? estimatedPrice;
  final String? customerName;
  final String? contactNumber;
  final String? whatsappNumber;
  final String? email;
  final String? address;
  final String? enquiryStatus;
  final String? currentProcessStatus;
  final bool? overDue;
  final int? mainManagerId;
  final int? carpenterId;
  final List<int>? materialIds;
  final double? materialCost;
  final double? ongoingExpense;
  final int? currentProcess;
  final List<int>? completedProcesses;

  OrderData({
    this.id,
    this.images,
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
    this.estimatedPrice,
    this.customerName,
    this.contactNumber,
    this.whatsappNumber,
    this.email,
    this.address,
    this.enquiryStatus,
    this.currentProcessStatus,
    this.overDue,
    this.mainManagerId,
    this.carpenterId,
    this.materialIds,
    this.materialCost,
    this.ongoingExpense,
    this.currentProcess,
    this.completedProcesses,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] as int?,
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => EnquiryImage.fromJson(image))
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

class CompletedProcessData {
  final Process? completedProcess;
  final ProcessDetails? completedProcessDetails;
  final List<MaterialUsed>? materialsUsed;
  final List<User>? workersData;

  CompletedProcessData({
    required this.completedProcess,
    required this.completedProcessDetails,
    required this.materialsUsed,
    required this.workersData,
  });

  factory CompletedProcessData.fromJson(Map<String, dynamic> json) {
    return CompletedProcessData(
      completedProcess: json['completed_process'] != null
          ? Process.fromJson(json['completed_process'])
          : null,
      completedProcessDetails: json['completed_process_details'] != null
          ? ProcessDetails.fromJson(json['completed_process_details'])
          : null,
      materialsUsed: (json['materials_used'] as List<dynamic>?)
          ?.map((material) => MaterialUsed.fromJson(material))
          .toList(),
      workersData: (json['workers_data'] as List<dynamic>?)
          ?.map((worker) => User.fromJson(worker))
          .toList(),
    );
  }
}

class CurrentProcess {
  final Process? currentProcess;
  final ProcessDetails? currentProcessDetails;
  final List<MaterialUsed>? currentProcessMaterialsUsed;
  final List<User>? currentProcessWorkers;

  CurrentProcess({
    required this.currentProcess,
    required this.currentProcessDetails,
    required this.currentProcessMaterialsUsed,
    required this.currentProcessWorkers,
  });

  factory CurrentProcess.fromJson(Map<String, dynamic> json) {
    return CurrentProcess(
      currentProcess: json['current_process'] != null
          ? Process.fromJson(json['current_process'])
          : null,
      currentProcessDetails: json['current_process_details'] != null
          ? ProcessDetails.fromJson(json['current_process_details'])
          : null,
      currentProcessMaterialsUsed:
          (json['current_process_materials_used'] as List<dynamic>?)
              ?.map((material) => MaterialUsed.fromJson(material))
              .toList(),
      currentProcessWorkers: (json['current_process_workers'] as List<dynamic>?)
          ?.map((worker) => User.fromJson(worker))
          .toList(),
    );
  }
}

class EnquiryDetailResponse {
  final Product? product;
  final OrderData? orderData;
  final EnquiryDetailUser? mainManager;
  final List<EnquiryDetailMaterial>? materials;
  final CarpenterEnquiryDetailData? carpenterEnquiryData;
  final List<CompletedProcessData>? completedProcessData;
  final CurrentProcess? currentProcess;
  final double? completionPercentage;

  EnquiryDetailResponse({
    required this.product,
    required this.orderData,
    required this.mainManager,
    required this.materials,
    required this.carpenterEnquiryData,
    required this.completedProcessData,
    required this.currentProcess,
    required this.completionPercentage,
  });

  factory EnquiryDetailResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryDetailResponse(
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      orderData: json['order_data'] != null
          ? OrderData.fromJson(json['order_data'])
          : null,
      mainManager: json['main_manager'] != null
          ? EnquiryDetailUser.fromJson(json['main_manager'])
          : null,
      materials: (json['materials'] as List<dynamic>?)
          ?.map((material) => EnquiryDetailMaterial.fromJson(material))
          .toList(),
      carpenterEnquiryData: json['carpenter_enquiry_data'] != null
          ? CarpenterEnquiryDetailData.fromJson(json['carpenter_enquiry_data'])
          : null,
      completedProcessData: (json['completed_process_data'] as List<dynamic>?)
          ?.map((process) => CompletedProcessData.fromJson(process))
          .toList(),
      currentProcess: json['current_process'] != null
          ? CurrentProcess.fromJson(json['current_process'])
          : null,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
    );
  }
}

class MaterialImage {
  final int id;
  final String image;

  MaterialImage({
    required this.id,
    required this.image,
  });

  factory MaterialImage.fromJson(Map<String, dynamic> json) {
    return MaterialImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }
}

class Process {
  final int? id;
  final String? name;
  final String? nameMal;
  final String? description;
  final String? descriptionMal;

  Process({
    this.id,
    this.name,
    this.nameMal,
    this.description,
    this.descriptionMal,
  });

  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'] as int?,
      name: json['name'] as String?,
      nameMal: json['name_mal'] as String?,
      description: json['description'] as String?,
      descriptionMal: json['description_mal'] as String?,
    );
  }
}

class ProcessImage {
  final int id;
  final String image;

  ProcessImage({required this.id, required this.image});

  factory ProcessImage.fromJson(Map<String, dynamic> json) {
    return ProcessImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }
}

class ProcessDetails {
  final int? id;
  final List<ProcessImage>? images;
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
    this.id,
    this.images,
    this.processStatus,
    this.expectedCompletionDate,
    this.completionDate,
    this.workersSalary,
    this.materialPrice,
    this.totalPrice,
    this.image,
    this.overDue,
    this.requestAcceptedDate,
    this.orderId,
    this.processId,
    this.mainManagerId,
    this.processManagerId,
    this.processWorkersId,
  });

  factory ProcessDetails.fromJson(Map<String, dynamic> json) {
    return ProcessDetails(
      id: json['id'] as int?,
      images: json['images'] != null
          ? (json['images'] as List<dynamic>)
              .map((image) => ProcessImage.fromJson(image))
              .toList()
          : null,
      processStatus: json['process_status'] as String?,
      expectedCompletionDate: json['expected_completion_date'] != null
          ? DateTime.parse(json['expected_completion_date'])
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      workersSalary: (json['workers_salary'] as num?)?.toDouble(),
      materialPrice: (json['material_price'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      image: json['image'] as String?,
      overDue: json['over_due'] as bool?,
      requestAcceptedDate: json['request_accepted_date'] != null
          ? DateTime.parse(json['request_accepted_date'])
          : null,
      orderId: json['order_id'] as int?,
      processId: json['process_id'] as int?,
      mainManagerId: json['main_manager_id'] as int?,
      processManagerId: json['process_manager_id'] as int?,
      processWorkersId: (json['process_workers_id'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList(),
    );
  }
}

class MaterialUsed {
  final Material? materialDetails;
  final Material? currentMaterialDetails;
  final MaterialUsedInProcess? materialUsedInProcess;
  final MaterialUsedInProcess? currentMaterialUsedInProcess;

  MaterialUsed({
    this.materialDetails,
    this.currentMaterialDetails,
    this.materialUsedInProcess,
    this.currentMaterialUsedInProcess,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) {
    return MaterialUsed(
      materialDetails: json['completed_material_details'] != null
          ? Material.fromJson(json['completed_material_details'])
          : null,
      materialUsedInProcess: json['completed_material_used_in_process'] != null
          ? MaterialUsedInProcess.fromJson(
              json['completed_material_used_in_process'])
          : null,
      currentMaterialDetails: json['current_material_details'] != null
          ? Material.fromJson(json['current_material_details'])
          : null,
      currentMaterialUsedInProcess:
          json['current_material_used_in_process'] != null
              ? MaterialUsedInProcess.fromJson(
                  json['current_material_used_in_process'])
              : null,
    );
  }
}

class MaterialUsedInProcess {
  final int? id;
  final int? quantity;
  final double? materialPrice;
  final double? totalPrice;
  final int? processDetailsId;
  final int? materialId;

  MaterialUsedInProcess({
    this.id,
    this.quantity,
    this.materialPrice,
    this.totalPrice,
    this.processDetailsId,
    this.materialId,
  });

  factory MaterialUsedInProcess.fromJson(Map<String, dynamic> json) {
    return MaterialUsedInProcess(
      id: json['id'] as int?,
      quantity: json['quantity'] as int?,
      materialPrice: (json['material_price'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      processDetailsId: json['process_details_id'] as int?,
      materialId: json['material_id'] as int?,
    );
  }
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final int? age;
  final bool? isAdmin;
  final double? salaryPerHr;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.age,
    this.isAdmin,
    this.salaryPerHr,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      isAdmin: json['isAdmin'] as bool?,
      salaryPerHr: (json['salary_per_hr'] as num?)?.toDouble(),
    );
  }
}
