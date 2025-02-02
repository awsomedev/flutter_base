class RequestDetail {
  final int orderId;
  final String priority;
  final List<EnquiryImage> images;
  final String productName;
  final String productNameMal;
  final String productDescription;
  final String productDescriptionMal;
  final double productLength;
  final double productHeight;
  final double productWidth;
  final List<MaterialWithEnquiry> materials;
  final String finish;
  final String event;
  final String status;

  RequestDetail({
    required this.orderId,
    required this.priority,
    required this.images,
    required this.productName,
    required this.productNameMal,
    required this.productDescription,
    required this.productDescriptionMal,
    required this.productLength,
    required this.productHeight,
    required this.productWidth,
    required this.materials,
    required this.finish,
    required this.event,
    required this.status,
  });

  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    return RequestDetail(
      orderId: json['order_id'] as int,
      priority: json['priority'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => EnquiryImage.fromJson(image))
          .toList(),
      productName: json['product_name'] as String,
      productNameMal: json['product_name_mal'] as String,
      productDescription: json['product_description'] as String,
      productDescriptionMal: json['product_description_mal'] as String,
      productLength: json['product_length'] as double,
      productHeight: json['product_height'] as double,
      productWidth: json['product_width'] as double,
      materials: (json['materials'] as List<dynamic>)
          .map((material) => MaterialWithEnquiry.fromJson(material))
          .toList(),
      finish: json['finish'] as String,
      event: json['event'] as String,
      status: json['status'] as String,
    );
  }
}

class MaterialWithEnquiry {
  final int id;
  final String name;
  final String nameMal;
  final String description;
  final String descriptionMal;
  final String colour;
  final String quality;
  final String durability;
  final EnquiryData enquiryData;

  MaterialWithEnquiry({
    required this.id,
    required this.name,
    required this.nameMal,
    required this.description,
    required this.descriptionMal,
    required this.colour,
    required this.quality,
    required this.durability,
    required this.enquiryData,
  });

  factory MaterialWithEnquiry.fromJson(Map<String, dynamic> json) {
    return MaterialWithEnquiry(
      id: json['id'] as int,
      name: json['name'] as String,
      nameMal: json['name_mal'] as String,
      description: json['description'] as String,
      descriptionMal: json['description_mal'] as String,
      colour: json['colour'] as String,
      quality: json['quality'] as String,
      durability: json['durability'] as String,
      enquiryData: EnquiryData.fromJson(json['enquiry_data']),
    );
  }
}

class EnquiryData {
  final int id;
  final int orderId;
  final int materialId;
  final double? materialLength;
  final double? materialHeight;
  final double? materialWidth;
  final String status;
  final int carpenterId;
  final double? materialCost;

  EnquiryData({
    required this.id,
    required this.orderId,
    required this.materialId,
    required this.materialLength,
    required this.materialHeight,
    required this.materialWidth,
    required this.status,
    required this.carpenterId,
    this.materialCost,
  });

  factory EnquiryData.fromJson(Map<String, dynamic> json) {
    return EnquiryData(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      materialId: json['material_id'] as int,
      materialLength: json['material_length'] as double?,
      materialHeight: json['material_height'] as double?,
      materialWidth: json['material_width'] as double?,
      status: json['status'] as String,
      carpenterId: json['carpenter_id'] as int,
      materialCost: json['material_cost'] as double?,
    );
  }
}

class EnquiryImage {
  final int id;
  final String image;

  EnquiryImage({
    required this.id,
    required this.image,
  });

  factory EnquiryImage.fromJson(Map<String, dynamic> json) {
    return EnquiryImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }
}
