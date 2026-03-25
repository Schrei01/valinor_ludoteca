import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';

class ReportList extends StatelessWidget {
  final ReportsController controller;

  const ReportList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat("#,##0", "es_CO");

    if (controller.loading) {
      return const CircularProgressIndicator();
    }

    if (controller.reportData.isEmpty) {
      return const Text('No hay datos para el rango seleccionado');
    }

    return ListView.builder(
      itemCount: controller.reportData.length,
      itemBuilder: (context, index) {
        final item = controller.reportData[index];

        return ListTile(
          title: Text(item['name']),
          subtitle: Text('Cantidad vendida: ${item['total_quantity']}'),
          trailing: Text(
            'Total: \$${currency.format(item['total_sales'])}',
          ),
        );
      },
    );
  }
}