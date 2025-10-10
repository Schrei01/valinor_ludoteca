import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';

class AdministracionScreen extends StatelessWidget {
  const AdministracionScreen({super.key});

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
            //Deudas
             Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: Color.fromARGB(255, 240, 9, 66), size: 40),
                title: const Text("Deudas",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  "\$${currencyFormat.format(deudas)}",
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
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // los centra horizontalmente
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showTransferDialog(context);
                    },
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text("Transferir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12), // espacio entre botones
                  ElevatedButton.icon(
                    onPressed: () {
                      _showDiscontDialog(context);
                    },
                    icon: const Icon(Icons.remove_circle_outline), // ícono de descontar
                    label: const Text("Descontar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
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

  Future<void> _showDiscontDialog(BuildContext context) async {
    final TextEditingController montoController = TextEditingController();
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
                decoration: const InputDecoration(labelText: "Monto"),
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
                final monto = double.tryParse(montoController.text) ?? 0;
                if (cuentaSeleccionada == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, completa todos los campos")),
                  );
                  return;
                }

                // 🔹 Lógica para descontar del provider correspondiente
                switch (cuentaSeleccionada) {
                  case "Caja":
                    context.read<CashProvider>().setTotalEnCaja(
                        context.read<CashProvider>().totalEnCaja - monto);
                    break;
                  case "Nequi":
                    context.read<NequiProvider>().setTotalEnNequi(
                        context.read<NequiProvider>().totalEnNequi - monto);
                    break;
                  case "Caja mayor":
                    context.read<CajaMayorProvider>().setTotalEnCajaMayor(
                        context.read<CajaMayorProvider>().totalEnCajaMayor - monto);
                    break;
                  case "Deudas":
                    context.read<DeudasProvider>().setTotalEnDeudas(
                        context.read<DeudasProvider>().totalEnDeudas - monto);
                    break;
                }

                Navigator.pop(context); // cerrar diálogo
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}
