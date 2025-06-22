class DecorationEnquiryDetailResponse {
  final DecorationOrderData orderData;
  final DecorEnquiryData enquiryData;

  DecorationEnquiryDetailResponse({
    required this.orderData,
    required this.enquiryData,
  });

  factory DecorationEnquiryDetailResponse.fromJson(Map<String, dynamic> json) {
    return DecorationEnquiryDetailResponse(
      orderData: DecorationOrderData.fromJson(json['order_data']),
      enquiryData: DecorEnquiryData.fromJson(json['enquiry_data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_data': orderData.toJson(),
      'enquiry_data': enquiryData.toJson(),
    };
  }
}

class DecorationOrderData {
  final String productName;
  final String productNameMal;
  final String productDescription;
  final String productDescriptionMal;
  final List<DecorMaterial> materials;
  final double productLength;
  final double productHeight;
  final double productWidth;
  final String finish;
  final List<DecorImage> referenceImage;

  DecorationOrderData({
    required this.productName,
    required this.productNameMal,
    required this.productDescription,
    required this.productDescriptionMal,
    required this.materials,
    required this.productLength,
    required this.productHeight,
    required this.productWidth,
    required this.finish,
    required this.referenceImage,
    // required this.audioList,
  });

  factory DecorationOrderData.fromJson(Map<String, dynamic> json) {
    return DecorationOrderData(
      productName: json['product_name'] as String,
      productNameMal: json['product_name_mal'] as String,
      productDescription: json['product_description'] as String,
      productDescriptionMal: json['product_description_mal'] as String,
      materials: (json['materials'] as List)
          .map((material) => DecorMaterial.fromJson(material))
          .toList(),
      productLength: json['product_length'].toDouble(),
      productHeight: json['product_height'].toDouble(),
      productWidth: json['product_width'].toDouble(),
      finish: json['finish'] as String,
      referenceImage: (json['reference_image'] as List<dynamic>)
          .map((image) => DecorImage.fromJson(image))
          .toList(),
      // audioList: json['audio_list'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product_name_mal': productNameMal,
      'product_description': productDescription,
      'product_description_mal': productDescriptionMal,
      'materials': materials.map((material) => material.toJson()).toList(),
      'product_length': productLength,
      'product_height': productHeight,
      'product_width': productWidth,
      'finish': finish,
      'reference_image':
          referenceImage.map((image) => image.toString()).toList(),
      // 'audio_list': audioList,
    };
  }
}

class DecorMaterial {
  final String name;

  DecorMaterial({required this.name});

  factory DecorMaterial.fromJson(Map<String, dynamic> json) {
    return DecorMaterial(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class DecorEnquiryData {
  final int id;
  final String status;
  final String aboutEnquiry;
  final String? enquiryDescription;
  final String? completionTime;
  final double? cost;
  final DateTime createdAt;
  final int organizationId;
  final int orderId;
  final int enquiryTypeId;
  final int enquiryUserId;
  final String enquiryType;

  DecorEnquiryData(
      {required this.id,
      required this.status,
      required this.aboutEnquiry,
      this.enquiryDescription,
      this.completionTime,
      this.cost,
      required this.createdAt,
      required this.organizationId,
      required this.orderId,
      required this.enquiryTypeId,
      required this.enquiryUserId,
      required this.enquiryType});

  factory DecorEnquiryData.fromJson(Map<String, dynamic> json) {
    return DecorEnquiryData(
        id: json['id'] as int,
        status: json['status'] as String,
        aboutEnquiry: json['about_enquiry'] as String,
        enquiryDescription: json['enquiry_description'] as String?,
        completionTime: json['completion_time'] as String?,
        cost: json['cost']?.toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
        organizationId: json['organization_id'] as int,
        orderId: json['order_id'] as int,
        enquiryTypeId: json['enquiry_type_id'] as int,
        enquiryUserId: json['enquiry_user_id'] as int,
        enquiryType: json['enquiry_type'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'about_enquiry': aboutEnquiry,
      'enquiry_description': enquiryDescription,
      'completion_time': completionTime,
      'cost': cost,
      'created_at': createdAt.toIso8601String(),
      'organization_id': organizationId,
      'order_id': orderId,
      'enquiry_type_id': enquiryTypeId,
      'enquiry_user_id': enquiryUserId,
      'enquiry_type': enquiryType
    };
  }
}

class DecorImage {
  final String image;

  DecorImage({
    required this.image,
  });

  factory DecorImage.fromJson(String image) {
    return DecorImage(
      image: image,
    );
  }
}
