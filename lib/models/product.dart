class Product {
  final int id;
  final String title;
  final String category;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Без назви',
      category: json['category'] ?? 'Без категорії',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
