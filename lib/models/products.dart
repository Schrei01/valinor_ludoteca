class Product {
  final int? id;
  final String name;
  final int quantity;
  final double price;
  final double purchasePrice;
  final String? lote;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.purchasePrice,
    required this.lote,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'name': name,
      'quantity': quantity,
      'price': price,
      'purchasePrice': purchasePrice,
      'lote': lote,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      lote: map['lote'],
    );
  }

  // Agregar copyWith
  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
    double? purchasePrice,
    String? lote,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      lote: lote ?? this.lote,
    );
  }
}