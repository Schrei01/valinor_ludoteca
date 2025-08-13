import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class SaleLine {
  Product? product;
  final TextEditingController quantityController = TextEditingController();

  SaleLine({this.product});
}
