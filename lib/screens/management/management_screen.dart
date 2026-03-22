import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/screens/management/widgets/action_panel_widget.dart';
import 'package:valinor_ludoteca_desktop/screens/management/widgets/cash_summary_widget.dart';
import 'package:valinor_ludoteca_desktop/screens/management/widgets/total_card_widget.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reporte de Cajas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const CashSummary(),

            const SizedBox(height: 20),

            const TotalCardWidget(),

            const SizedBox(height: 20),

            const ActionPanelWidget(),

            const SizedBox(height: 20),

            // 🔥 FUTURO: HISTORIAL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Historial de Movimientos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),
          ],
        )
      ),
    );
  }
}