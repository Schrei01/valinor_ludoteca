import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';

void showAddDialog(BuildContext context) {
    final TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar a Caja Mayor"),
          content: TextField(
            controller: montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Monto a agregar",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final monto = double.tryParse(montoController.text.trim()) ?? 0;

                if (monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Por favor ingresa un monto válido"),
                    ),
                  );
                  return;
                }

                final cajaMayorProvider = context.read<CajaMayorProvider>();
                cajaMayorProvider.setTotalEnCajaMayor(
                  cajaMayorProvider.totalEnCajaMayor + monto, // 👈 suma el valor
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Se agregaron \$${monto.toStringAsFixed(2)} a la Caja Mayor"),
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