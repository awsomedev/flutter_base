class Enquiry {
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
  final double? materialCost;
  final double? ongoingExpense;
  final bool? overDue;
  final int? currentProcess;
  final int? mainManagerId;
  final int? carpenterId;
  final List<int>? materialIds;
  final List<int>? completedProcesses;

  Enquiry({
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
    this.materialCost,
    this.ongoingExpense,
    this.overDue,
    this.currentProcess,
    this.mainManagerId,
    this.carpenterId,
    this.materialIds,
    this.completedProcesses,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
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
      materialCost: (json['material_cost'] as num?)?.toDouble(),
      ongoingExpense: (json['ongoing_expense'] as num?)?.toDouble(),
      overDue: json['over_due'] as bool?,
      currentProcess: json['current_process'] as int?,
      mainManagerId: json['main_manager_id'] as int?,
      carpenterId: json['carpenter_id'] as int?,
      materialIds: (json['material_ids'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList(),
      completedProcesses: (json['completed_processes'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'images': images?.map((image) => image.toJson()).toList(),
      'priority': priority,
      'status': status,
      'product_name': productName,
      'product_name_mal': productNameMal,
      'product_description': productDescription,
      'product_description_mal': productDescriptionMal,
      'product_length': productLength,
      'product_height': productHeight,
      'product_width': productWidth,
      'reference_image': referenceImage,
      'finish': finish,
      'event': event,
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'estimated_price': estimatedPrice,
      'customer_name': customerName,
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'address': address,
      'enquiry_status': enquiryStatus,
      'current_process_status': currentProcessStatus,
      'material_cost': materialCost,
      'ongoing_expense': ongoingExpense,
      'over_due': overDue,
      'current_process': currentProcess,
      'main_manager_id': mainManagerId,
      'carpenter_id': carpenterId,
      'material_ids': materialIds,
      'completed_processes': completedProcesses,
    };
  }
}

class EnquiryImage {
  final int? id;
  final String? image;

  EnquiryImage({this.id, this.image});

  factory EnquiryImage.fromJson(Map<String, dynamic> json) {
    return EnquiryImage(
      id: json['id'] as int?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
    };
  }
}
