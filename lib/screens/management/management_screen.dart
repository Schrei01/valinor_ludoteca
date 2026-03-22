import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/add_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/expense_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/tranfer_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/widgets/cash_card_widget.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caja = context.watch<CashProvider>().totalEnCaja; // escucha los cambios
    final nequi = context.watch<NequiProvider>().totalEnNequi; // escucha Nequi
    final cajaMayor = context.watch<CajaMayorProvider>().totalEnCajaMayor;
    final deudas = context.watch<DeudasProvider>().totalEnDeudas;
    final totalGeneral = caja + nequi + cajaMayor;
    final NumberFormat currencyFormat = NumberFormat("#,##0", "es_CO");

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

            // 🔥 GRID DE CAJAS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 4,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CashCardWidget(
                  title: "Caja",
                  value: caja,
                  color: Colors.green,
                ),
                CashCardWidget(
                  title: "Nequi",
                  value: nequi,
                  color: Colors.purple,
                ),
                CashCardWidget(
                  title: "Caja Mayor",
                  value: cajaMayor,
                  color: Colors.blue,
                ),
                CashCardWidget(
                  title: "Deudas",
                  value: deudas,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 TOTAL GENERAL DESTACADO
            Card(
              color: Colors.blueGrey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Total General",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${currencyFormat.format(totalGeneral)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 BOTONES GRANDES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showTransferDialog(context),
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text("Transferir"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showExpenseDialog(context),
                      icon: const Icon(Icons.remove),
                      label: const Text("Descontar"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => showAddDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("Agregar a Caja Mayor"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),

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