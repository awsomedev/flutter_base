class DecorationEnquiryResponse {
  final List<DecorEnquiry> data;

  DecorationEnquiryResponse({required this.data});

  factory DecorationEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return DecorationEnquiryResponse(
      data: (json['data'] as List)
          .map((enquiryJson) => DecorEnquiry.fromJson(enquiryJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((enquiry) => enquiry.toJson()).toList(),
    };
  }
}

class DecorEnquiry {
  final int id;
  final String status;
  final String aboutEnquiry;
  final String? enquiryDescription;
  final String? completionTime;
  final String? cost;
  final DateTime? createdAt;
  final int organizationId;
  final int orderId;
  final int enquiryTypeId;
  final int enquiryUserId;
  final String? userName;
  final String? phone;
  final String? enquiryType;

  DecorEnquiry(
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
      this.userName,
      this.enquiryType,
      this.phone});

  factory DecorEnquiry.fromJson(Map<String, dynamic> json) {
    return DecorEnquiry(
        id: json['id'] as int,
        status: json['status'] as String,
        aboutEnquiry: json['about_enquiry'] as String,
        enquiryDescription: json['enquiry_description'] as String?,
        completionTime: json['completion_time']?.toString(),
        cost: json['cost'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        organizationId: json['organization_id'] as int,
        orderId: json['order_id'] as int,
        enquiryTypeId: json['enquiry_type_id'] as int,
        enquiryUserId: json['enquiry_user_id'] as int,
        userName: json['user_name'] as String?,
        enquiryType: json['enquiry_type'] as String?,
        phone: json['Phone'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'about_enquiry': aboutEnquiry,
      'enquiry_description': enquiryDescription,
      'completion_time': completionTime,
      'cost': cost,
      'created_at': createdAt?.toIso8601String(),
      'organization_id': organizationId,
      'order_id': orderId,
      'enquiry_type_id': enquiryTypeId,
      'enquiry_user_id': enquiryUserId,
    };
  }
}
