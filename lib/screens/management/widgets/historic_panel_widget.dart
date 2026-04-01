import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/movements_provider.dart';

class HistoricPanelWidget extends StatefulWidget {
  const HistoricPanelWidget({super.key});

  @override
  State<HistoricPanelWidget> createState() => _HistoricPanelWidgetState();
}

class _HistoricPanelWidgetState extends State<HistoricPanelWidget> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovementsProvider>().cargarMovimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat("#,##0", "es_CO");
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER BONITO
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: Colors.deepPurple.shade600,
              ),
              const SizedBox(width: 8),
              const Text(
                "Historial de movimientos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Consumer<MovementsProvider>(
              builder: (context, provider, _) {
                final movimientos = provider.movimientos;

                if (movimientos.isEmpty) {
                  return const Center(child: Text("No hay movimientos"));
                }

                return ListView.separated(
                  itemCount: movimientos.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final mov = movimientos[index];

                    final tipo = mov['tipo'] ?? '';
                    final cuenta = mov['cuenta'] ?? '';
                    final cuentaDestino = mov['cuenta_destino'] ?? ''; // si es transferencia
                    final monto = mov['monto'] ?? 0;
                    final motivo = mov['motivo'] ?? '';
                    final fecha = mov['fecha'] ?? '';

                    Icon leadingIcon;
                    if (tipo == 'ingreso') {
                      leadingIcon = const Icon(Icons.arrow_downward, color: Colors.green);
                    } else if (tipo == 'egreso') {
                      leadingIcon = const Icon(Icons.arrow_upward, color: Colors.red);
                    } else if (tipo == 'transferencia') {
                      leadingIcon = const Icon(Icons.compare_arrows, color: Colors.blue); // doble flecha
                    } else {
                      leadingIcon = const Icon(Icons.help_outline);
                    }

                    String subtitleText;
                    if (tipo == 'transferencia') {
                      subtitleText = "$cuenta → $cuentaDestino • $motivo\n$fecha";
                    } else {
                      subtitleText = "$cuenta • $motivo\n$fecha";
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: leadingIcon,
                      title: Text(
                        "\$${currency.format(monto)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(subtitleText),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}