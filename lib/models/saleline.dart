import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class SaleLine {
  Product? product;
  String? paymentMethod;

  final TextEditingController quantityController = TextEditingController();

  SaleLine({
    this.product,
    this.paymentMethod,
  });

  int get quantity {
    return int.tryParse(quantityController.text) ?? 0;
  }

  double get total {
    final price = product?.price ?? 0;
    return quantity * price;
  }
}

