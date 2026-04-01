import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/movements_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/thousands_formatter.dart';

void showAddDialog(BuildContext context) {
    final TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar a Caja Mayor"),
          content: TextField(
            controller: montoController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsFormatter()],
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: "Monto a agregar",
              border: OutlineInputBorder(),
              prefixText: "\$ ",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async{
                final rawText = montoController.text.replaceAll('.', '');
                final monto = double.tryParse(rawText) ?? 0;
                final formatter = NumberFormat("#,##0", "es_CO");

                if (monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Por favor ingresa un monto válido"),
                    ),
                  );
                  return;
                }

                final cajaMayorProvider = context.read<CajaMayorProvider>();
                final movementsProvider = context.read<MovementsProvider>();

                await movementsProvider.agregarMovimiento(
                  tipo: "ingreso",
                  cuenta: "Caja mayor",
                  monto: monto,
                  motivo: "Agregado a Caja Mayor",
                );

                cajaMayorProvider.setTotalEnCajaMayor(
                  cajaMayorProvider.totalEnCajaMayor + monto,
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Se agregaron \$${formatter.format(monto)} a la Caja Mayor"),
                  ),
                );
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }