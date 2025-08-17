import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class SaleLine {
  Product? product;
  int quantity; // cantidad numérica

  final TextEditingController quantityController = TextEditingController();

  SaleLine({this.product, this.quantity = 0});
}

