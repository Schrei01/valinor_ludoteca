class Product {
  final int? id;
  final String name;
  final int quantity;
  final double price; // precio venta
  final double purchasePrice; // precio compra

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'purchasePrice': purchasePrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
    );
  }

}
