class Costume {
  final int id;
  final String name;
  final String? description;
  final String size;
  final double price;
  final String? imagePath;
  final bool isAvailable;
  final int? categoryId;
  final int quantity;

  Costume({
    required this.id,
    required this.name,
    this.description,
    required this.size,
    required this.price,
    this.imagePath,
    required this.isAvailable,
    this.categoryId,
    this.quantity = 0,
  });

  factory Costume.fromJson(Map<String, dynamic> json) {
    return Costume(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      size: json['size'],
      price: double.parse(json['price'].toString()),
      imagePath: json['image_path'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      categoryId: json['category_id'],
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'size': size,
      'price': price,
      'image_path': imagePath,
      'is_available': isAvailable ? 1 : 0,
      'category_id': categoryId,
      'quantity': quantity,
    };
  }

  Costume copyWith({
    int? id,
    String? name,
    String? description,
    String? size,
    double? price,
    String? imagePath,
    bool? isAvailable,
    int? categoryId,
    int? quantity,
  }) {
    return Costume(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      size: size ?? this.size,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
    );
  }
}
