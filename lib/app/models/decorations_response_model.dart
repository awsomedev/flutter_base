class DecorationResponse {
  final int id;
  final String enquiryName;

  DecorationResponse({
    required this.id,
    required this.enquiryName,
  });

  factory DecorationResponse.fromJson(Map<String, dynamic> json) {
    return DecorationResponse(
        id: json['id'] as int, enquiryName: json['enquiry_name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'enquiry_name': enquiryName};
  }
}
