import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalDisplay extends StatelessWidget {
  final double total;
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "es_CO");

  TotalDisplay({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Total: \$${_currencyFormat.format(total)}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}