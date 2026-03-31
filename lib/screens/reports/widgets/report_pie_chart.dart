import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';

class ReportPieChart extends StatelessWidget {
  final ReportsController controller;

  const ReportPieChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.totalGeneral == 0 && controller.egresos == 0) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              "No hay datos para graficar",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final ganancias = (controller.totalGeneral - controller.egresos)
        .clamp(0, double.infinity)
        .toDouble();

    final data = <String, double>{
      'Ventas': controller.totalGeneral.toDouble(),
      'Egresos': controller.egresos.toDouble(),
      'Ganancia': ganancias,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                size: 20,
                color: Colors.deepPurple.shade600,
              ),
              const SizedBox(width: 8),
              const Text(
                "Ventas vs Egresos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(data),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 1,
                  child: _buildLegend(data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _buildSections(Map<String, double> data) {
  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  final currency = NumberFormat("#,##0", "es_CO");

  int index = 0;

  return data.entries.map((entry) {
    final value = entry.value;

    final section = PieChartSectionData(
      color: colors[index],
      value: value,
      title: value > 0
          ? "\$${currency.format(value)}"
          : '',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    index++;
    return section;
  }).toList();
}

Widget _buildLegend(Map<String, double> data) {
  final total = data.values.fold(0.0, (a, b) => a + b);

  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  final currency = NumberFormat("#,##0", "es_CO");

  int index = 0;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: data.entries.map((entry) {
      final value = entry.value;
      final percentage = total > 0 ? (value / total * 100) : 0;
      final color = colors[index];

      index++;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${entry.key}\n\$${currency.format(value)} • ${percentage.toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}