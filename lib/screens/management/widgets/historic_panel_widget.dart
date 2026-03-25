import 'package:flutter/material.dart';
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
                    final monto = mov['monto'] ?? 0;
                    final motivo = mov['motivo'] ?? '';
                    final fecha = mov['fecha'] ?? '';

                    final isIngreso = tipo == 'ingreso';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isIngreso
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isIngreso ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        "\$${monto.toString()}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("$cuenta • $motivo\n$fecha"),
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