import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';


class GraphicsPanelWidget extends StatelessWidget {
  const GraphicsPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cash = context.watch<CashProvider>().totalEnCaja;
    final nequi = context.watch<NequiProvider>().totalEnNequi;
    final cajaMayor = context.watch<CajaMayorProvider>().totalEnCajaMayor;
    final deudas = context.watch<DeudasProvider>().totalEnDeudas;

    final data = {
      'Caja': cash,
      'Nequi': nequi,
      'Caja Mayor': cajaMayor,
      'Deudas': deudas,
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
          // HEADER
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                size: 20,
                color: Colors.deepPurple.shade600,
              ),
              const SizedBox(width: 8),
              const Text(
                "Distribución",
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
                // 📊 GRÁFICA
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

                // 📋 LEYENDA
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

  List<PieChartSectionData> _buildSections(Map<String, double> data) {
    final colors = [
      Colors.green,
      Colors.purple,
      Colors.blue,
      Colors.red,
    ];

    final currency = NumberFormat("#,##0", "es_CO");

    int index = 0;

    return data.entries.map((entry) {
      final section = PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: entry.value > 0
            ? "\$${currency.format(entry.value)}"
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
      Colors.green,
      Colors.purple,
      Colors.blue,
      Colors.red,
    ];

    final currency = NumberFormat("#,##0", "es_CO");

    int index = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.entries.map((entry) {
        final value = entry.value;
        final percentage = total > 0 ? (value / total * 100) : 0;
        final color = colors[index % colors.length];

        index++;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // 🎨 Color
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(width: 8),

              // 📊 Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "\$${currency.format(value)} • ${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}