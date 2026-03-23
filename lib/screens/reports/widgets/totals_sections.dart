import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';

class TotalsSection extends StatelessWidget {
  final ReportsController controller;

  const TotalsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat("#,##0", "es_CO");

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Total general: \$${currency.format(controller.totalGeneral)}',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Total ganancias: \$${currency.format(controller.totalGanancias)}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green),
        ),
      ],
    );
  }
}