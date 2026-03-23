import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/widgets/totals_sections.dart';
import 'widgets/date_selector.dart';
import 'widgets/report_list.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsController(),
      child: Consumer<ReportsController>(
        builder: (context, controller, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Reporte de Ventas',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                DateSelector(controller: controller),
                const SizedBox(height: 20),

                ReportList(controller: controller),

                TotalsSection(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}