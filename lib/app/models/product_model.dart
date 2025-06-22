enum StockAvailability {
  inStock('in_stock', 'In Stock'),
  lowStock('low_stock', 'Low Stock'),
  outOfStock('out_of_stock', 'Out of Stock');

  const StockAvailability(this.value, this.displayName);

  final String value;
  final String displayName;

  static StockAvailability fromValue(String value) {
    return StockAvailability.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StockAvailability.inStock,
    );
  }
}

class ProductModel {
  final int id;
  final String? name;
  final String? nameMal;
  final String? description;
  final String? descriptionMal;
  final String? colour;
  final String? quality;
  final String? durability;
  final String? stockAvailability;
  final int? categoryId;
  final double price;
  final int? quantity;
  final String? code;
  final List<ProductImage> images;
  final String? referenceImage;
  final double mrpInGst;
  final int organizationId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.colour,
    required this.quality,
    required this.durability,
    required this.stockAvailability,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.images,
    required this.code,
    required this.descriptionMal,
    required this.nameMal,
    this.referenceImage,
    required this.mrpInGst,
    required this.organizationId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      code: json['code'] as String?,
      name: json['name'] as String?,
      nameMal: json['name_mal'] as String?,
      description: json['description'] as String?,
      colour: json['colour'] as String?,
      quality: json['quality'] as String?,
      durability: json['durability'] as String?,
      stockAvailability: json['stock_availability'] as String?,
      categoryId: json['category_id'] as int?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int?,
      descriptionMal: json['description_mal'] as String?,
      images: (json['product_images'] as List?)
              ?.map((image) => ProductImage.fromJson(image))
              .toList() ??
          [],
      referenceImage: json['reference_image'] as String?,
      mrpInGst: (json['mrp_in_gst'] as num).toDouble(),
      organizationId: json['organization_id'] as int,
    );
  }
}

class ProductImage {
  final int id;
  final String image;

  ProductImage({
    required this.id,
    required this.image,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      image: json['image'] as String,
    );
  }
}
