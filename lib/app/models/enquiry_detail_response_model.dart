import 'package:madeira/app/models/enquiry_model.dart';

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

class CarpenterEnquiryDetailData {
  final EnquiryDetailUser carpenterUser;
  final List<dynamic> carpenterData;

  CarpenterEnquiryDetailData({
    required this.carpenterUser,
    required this.carpenterData,
  });

  factory CarpenterEnquiryDetailData.fromJson(Map<String, dynamic> json) {
    return CarpenterEnquiryDetailData(
      carpenterUser: EnquiryDetailUser.fromJson(json['carpenter_user']),
      carpenterData: json['carpenter_data'] as List<dynamic>,
    );
  }
}

class EnquiryDetailResponse {
  final Map<String, dynamic> product;
  final Enquiry orderData;
  final EnquiryDetailUser mainManager;
  final List<EnquiryDetailMaterial> materials;
  final CarpenterEnquiryDetailData carpenterEnquiryData;
  final List<dynamic> completedProcessData;
  final Map<String, dynamic> currentProcess;
  final double completionPercentage;

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
      product: json['product'] as Map<String, dynamic>,
      orderData: Enquiry.fromJson(json['order_data']),
      mainManager: EnquiryDetailUser.fromJson(json['main_manager']),
      materials: (json['materials'] as List<dynamic>)
          .map((material) => EnquiryDetailMaterial.fromJson(material))
          .toList(),
      carpenterEnquiryData:
          CarpenterEnquiryDetailData.fromJson(json['carpenter_enquiry_data']),
      completedProcessData: json['completed_process_data'] as List<dynamic>,
      currentProcess: json['current_process'] as Map<String, dynamic>,
      completionPercentage: (json['completion_percentage'] as num).toDouble(),
    );
  }
}
