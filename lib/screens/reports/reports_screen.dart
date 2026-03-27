import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/widgets/report_pie_chart.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/widgets/totals_sections.dart';
import 'widgets/date_selector.dart';
import 'widgets/report_list.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsController>(
        builder: (context, controller, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reporte de Ventas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // 🔹 CONTENIDO PRINCIPAL EN GRID
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 🔥 clave
                    children: [
                      // 🟣 COLUMNA IZQUIERDA
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // LISTA
                            Expanded(
                              flex: 2,
                              child: _buildCard(
                                child: ReportList(controller: controller),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // GRÁFICA (más grande)
                            Expanded(
                              flex: 3,
                              child: _buildCard(
                                child: Center(
                                  child: ReportPieChart(controller: controller),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 🔵 COLUMNA DERECHA
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // FILTROS (solo lo necesario)
                            _buildCard(
                              child: _buildFilters(controller),
                            ),

                            const SizedBox(height: 16),

                            // TOTALES (ocupa el resto)
                            Expanded(
                              child: _buildCard(
                                child: TotalsSection(controller: controller),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),             
              ],
            ),
          );
        },
      );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFilters(ReportsController controller) {
    return Row(
      children: [
        Expanded(child: DateSelector(controller: controller)),

        const SizedBox(width: 16),

        ElevatedButton.icon(
          onPressed: controller.loadReport,
          icon: const Icon(Icons.search),
          label: const Text('Generar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}