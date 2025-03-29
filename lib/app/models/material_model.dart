class MaterialModel {
  final int id;
  final String name;
  final String description;
  final String colour;
  final String quality;
  final String durability;
  final String stockAvailability;
  final int? category;
  final double price;
  final int? quantity;

  MaterialModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colour,
    required this.quality,
    required this.durability,
    required this.stockAvailability,
    required this.category,
    required this.price,
    required this.quantity,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      colour: json['colour'] as String,
      quality: json['quality'] as String,
      durability: json['durability'] as String,
      stockAvailability: json['stock_availability'] as String,
      category: json['category_id'] as int?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int?,
    );
  }
}
