import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';

class AdministracionScreen extends StatelessWidget {
  const AdministracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caja = context.watch<CashProvider>().totalEnCaja; // escucha los cambios
    final nequi = context.watch<NequiProvider>().totalEnNequi; // escucha Nequi
    final cajaMayor = 300000;
    final totalGeneral = caja + nequi + cajaMayor;
    final NumberFormat currencyFormat = NumberFormat("#,##0", "es_CO");

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // opcional para que cards ocupen todo el ancho
          children: [
            const Text(
              'Reporte de Cajas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Caja efectivo
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green, size: 40),
                title: const Text("Caja efectivo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  "\$${currencyFormat.format(caja)}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
            // Nequi
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.purple, size: 40),
                title: const Text("Nequi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  "\$${currencyFormat.format(nequi)}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ),
            ),
            // Caja mayor
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.savings, color: Colors.blue, size: 40),
                title: const Text("Caja mayor",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  "\$${currencyFormat.format(cajaMayor)}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Total general
            Card(
              color: Colors.blueGrey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ListTile(
                leading: const Icon(Icons.summarize, color: Colors.blue, size: 40),
                title: const Text("Total General",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "\$${currencyFormat.format(totalGeneral)}",
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center, // también puedes Alignment.centerLeft
              child: ElevatedButton(
                onPressed: () {
                  context.read<CashProvider>().discountByHosting();
                },
                child: const Text("Descuento host"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
