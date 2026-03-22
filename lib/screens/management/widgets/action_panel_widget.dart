import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/add_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/expense_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/tranfer_dialog.dart';

class ActionPanelWidget extends StatelessWidget {
  const ActionPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showTransferDialog(context),
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text("Transferir"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showExpenseDialog(context),
                  icon: const Icon(Icons.remove),
                  label: const Text("Descontar"),
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
          ),
        ),
      ],
    );
  }
}