import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';

class TotalsSection extends StatelessWidget {
  final ReportsController controller;

  const TotalsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat("#,##0", "es_CO");

    Widget row(String title, double value, {Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              "\$${currency.format(value)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          row("Caja inicio", controller.cajaInicio),
          row("Nequi inicio", controller.nequiInicio),

          const SizedBox(height: 10),

          row("Ingresos Caja", controller.ingresosCaja, color: Colors.green),
          row("Ingresos Nequi", controller.ingresosNequi, color: Colors.green),

          const SizedBox(height: 10),

          row("Ventas", controller.totalGeneral, color: Colors.blue),

          row("Egresos", controller.egresos, color: Colors.red),
        ],
      ),
    );
  }
}