class Sale {
  final int id;
  final String productName;
  final String price;
  final String deliveryStatus;
  final String clientName;
  final String clientPhone;
  final String clientWhatsapp;
  final String clientAddress;
  final int rating;
  final String totalPrice;
  final int quantity;
  final String createdBy;
  final String additionalCost;
  final String createdAt;

  Sale({
    required this.id,
    required this.productName,
    required this.price,
    required this.deliveryStatus,
    required this.clientName,
    required this.clientPhone,
    required this.clientWhatsapp,
    required this.clientAddress,
    required this.rating,
    required this.totalPrice,
    required this.quantity,
    required this.createdBy,
    required this.additionalCost,
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    final dynamic rawRating = json['rating'];
    final dynamic rawQuantity = json['quantity'];

    int parsedRating;
    if (rawRating == null) {
      parsedRating = 0;
    } else if (rawRating is int) {
      parsedRating = rawRating;
    } else if (rawRating is String) {
      parsedRating = int.tryParse(rawRating) ?? 0;
    } else {
      parsedRating = 0;
    }

    int parsedQuantity;
    if (rawQuantity == null) {
      parsedQuantity = 0;
    } else if (rawQuantity is int) {
      parsedQuantity = rawQuantity;
    } else if (rawQuantity is String) {
      parsedQuantity = int.tryParse(rawQuantity) ?? 0;
    } else {
      parsedQuantity = 0;
    }

    return Sale(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      productName: json['product_name'] ?? 'No Name',
      price: json['price']?.toString() ?? '0.00',
      deliveryStatus: json['delivery_status'] ?? 'unknown',
      clientName: json['client_name'] ?? 'Unknown',
      clientPhone: json['client_phone']?.toString() ?? '',
      clientWhatsapp: json['client_whatsapp']?.toString() ?? '',
      clientAddress: json['client_address']?.toString() ?? '',
      rating: parsedRating,
      totalPrice: json['total_price']?.toString() ?? '0.00',
      quantity: parsedQuantity,
      createdBy: json['created_by']?.toString() ?? 'Unknown',
      additionalCost: json['additional_cost']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
