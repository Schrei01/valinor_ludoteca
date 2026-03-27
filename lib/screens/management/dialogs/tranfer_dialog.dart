import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';

void showTransferDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    String? sourceAccount;
    String? destinationAccount;

    final List<String> accounts = [
      'Caja',
      'Nequi',
      'Caja Mayor',
      'Deudas',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Transferir entre cuentas"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cuenta origen'),
                items: accounts.map((account) {
                  return DropdownMenuItem(value: account, child: Text(account));
                }).toList(),
                onChanged: (value) => sourceAccount = value,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cuenta destino'),
                items: accounts.map((account) {
                  return DropdownMenuItem(value: account, child: Text(account));
                }).toList(),
                onChanged: (value) => destinationAccount = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (sourceAccount == null ||
                    destinationAccount == null ||
                    sourceAccount == destinationAccount ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Verifica los datos ingresados")),
                  );
                  return;
                }

                _transfer(context, sourceAccount!, destinationAccount!, amount);
                Navigator.pop(context);
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _transfer(
    BuildContext context,
    String from,
    String to,
    double amount,
  ) {
    final cashProvider = context.read<CashProvider>();
    final nequiProvider = context.read<NequiProvider>();
    final mayorProvider = context.read<CajaMayorProvider>();
    final deudasProvider = context.read<DeudasProvider>();

    // 🔹 Mapa para acceder fácilmente
    final Map<String, dynamic> accounts = {
      'Caja': cashProvider,
      'Nequi': nequiProvider,
      'Caja Mayor': mayorProvider,
      'Deudas': deudasProvider,
    };

    // Verificar que ambas cuentas existan
    if (!accounts.containsKey(from) || !accounts.containsKey(to)) return;

    // 🔹 Obtener saldos actuales
    double fromTotal = _getTotal(from, context);
    double toTotal = _getTotal(to, context);

    if (fromTotal < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saldo insuficiente en la cuenta origen")),
      );
      return;
    }

    // 🔹 Actualizar saldos
    _setTotal(from, fromTotal - amount, context);
    _setTotal(to, toTotal + amount, context);
  }

  double _getTotal(String account, BuildContext context) {
    switch (account) {
      case 'Caja':
        return context.read<CashProvider>().totalEnCaja;
      case 'Nequi':
        return context.read<NequiProvider>().totalEnNequi;
      case 'Caja Mayor':
        return context.read<CajaMayorProvider>().totalEnCajaMayor;
      case 'Deudas':
        return context.read<DeudasProvider>().totalEnDeudas;
      default:
        return 0;
    }
  }

  void _setTotal(String account, double newValue, BuildContext context) {
    switch (account) {
      case 'Caja':
        context.read<CashProvider>().setTotalEnCaja(newValue);
        break;
      case 'Nequi':
        context.read<NequiProvider>().setTotalEnNequi(newValue);
        break;
      case 'Caja Mayor':
        context.read<CajaMayorProvider>().setTotalEnCajaMayor(newValue);
        break;
      case 'Deudas':
        context.read<DeudasProvider>().setTotalEnDeudas(newValue);
        break;
    }
  }