import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';

class TotalCardWidget extends StatelessWidget {
  const TotalCardWidget({super.key});

   @override
  Widget build(BuildContext context) {
    final caja = context.watch<CashProvider>().totalEnCaja;
    final nequi = context.watch<NequiProvider>().totalEnNequi;
    final cajaMayor = context.watch<CajaMayorProvider>().totalEnCajaMayor;

    final totalGeneral = caja + nequi + cajaMayor;

    final format = NumberFormat("#,##0", "es_CO");

    return Card(
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${format.format(totalGeneral)}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}