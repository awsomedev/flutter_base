class CarpenterRequest {
  final int? orderId;
  final String? productName;
  final String? productNameMal;
  final String? productDescription;
  final String? productDescriptionMal;
  final String? status;

  CarpenterRequest({
    this.orderId,
    this.productName,
    this.productNameMal,
    this.productDescription,
    this.productDescriptionMal,
    this.status,
  });

  factory CarpenterRequest.fromJson(Map<String, dynamic> json) {
    return CarpenterRequest(
      orderId: json['order_id'] as int?,
      productName: json['product_name'] as String?,
      productNameMal: json['product_name_mal'] as String?,
      productDescription: json['product_description'] as String?,
      productDescriptionMal: json['product_description_mal'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_name': productName,
      'product_name_mal': productNameMal,
      'product_description': productDescription,
      'product_description_mal': productDescriptionMal,
      'status': status,
    };
  }
}

class CarpenterRequestResponse {
  final List<CarpenterRequest> orderData;

  CarpenterRequestResponse({required this.orderData});

  factory CarpenterRequestResponse.fromJson(Map<String, dynamic> json) {
    return CarpenterRequestResponse(
      orderData: (json['order_data'] as List<dynamic>)
          .map((order) => CarpenterRequest.fromJson(order))
          .toList(),
    );
  }
}
