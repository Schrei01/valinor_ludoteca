import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/movements_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/thousands_formatter.dart';

Future<void> showExpenseDialog(BuildContext context) async {
  final TextEditingController montoController = TextEditingController();
  String? motivoSeleccionado;

  final motivos = [
    "Arriendo",
    "Agua",
    "Energía",
    "Comestibles",
    "Tienda",
    "Host",
    "Implementos",
    "Aseo",
  ];
  String? cuentaSeleccionada;

  // Opciones disponibles
  final cuentas = ["Caja", "Nequi", "Caja mayor", "Deudas"];

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Descontar monto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Seleccionar cuenta
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Cuenta a descontar"),
              items: cuentas
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => cuentaSeleccionada = value,
            ),
            const SizedBox(height: 10),

            // 🔹 Monto
            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: "Monto",
                prefixText: "\$ ",
              ),
            ),
            const SizedBox(height: 10),

            // 🔥 NUEVO: Motivo
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Motivo",
                border: OutlineInputBorder(),
              ),
              items: motivos
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) => motivoSeleccionado = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
            final rawText = montoController.text.replaceAll('.', '');
            final monto = double.tryParse(rawText) ?? 0;
            
            if (cuentaSeleccionada == null || monto <= 0 || motivoSeleccionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Por favor, completa todos los campos")),
              );
              return;
            }
            // 🔥 CAPTURAR PROVIDERS ANTES DEL AWAIT
            final cashProvider = context.read<CashProvider>();
            final nequiProvider = context.read<NequiProvider>();
            final cajaMayorProvider = context.read<CajaMayorProvider>();
            final deudasProvider = context.read<DeudasProvider>();
            final movementsProvider = context.read<MovementsProvider>();

            await movementsProvider.agregarMovimiento(
              tipo: "egreso",
              cuenta: cuentaSeleccionada!,
              monto: monto,
              motivo: motivoSeleccionado!,
            );

            // 🔥 USAR PROVIDERS (NO context)
            switch (cuentaSeleccionada) {
              case "Caja":
                cashProvider.setTotalEnCaja(cashProvider.totalEnCaja - monto);
                break;
              case "Nequi":
                nequiProvider.setTotalEnNequi(nequiProvider.totalEnNequi - monto);
                break;
              case "Caja mayor":
                cajaMayorProvider.setTotalEnCajaMayor(
                    cajaMayorProvider.totalEnCajaMayor - monto);
                break;
              case "Deudas":
                deudasProvider.setTotalEnDeudas(
                    deudasProvider.totalEnDeudas - monto);
                break;
            }

            if (!context.mounted) return;
            Navigator.pop(context);
          },
            child: const Text("Aceptar"),
          ),
        ],
      );
    },
  );
}