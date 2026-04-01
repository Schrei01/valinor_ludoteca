import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/add_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/expense_dialog.dart';
import 'package:valinor_ludoteca_desktop/screens/management/dialogs/tranfer_dialog.dart';

class ActionPanelWidget extends StatelessWidget {
  const ActionPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            context,
            label: "Transferir",
            icon: Icons.compare_arrows,
            color: Colors.blue,
            onPressed: () => showTransferDialog(context),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context,
            label: "Descontar",
            icon: Icons.remove,
            color: Colors.red,
            onPressed: () => showExpenseDialog(context),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context,
            label: "Agregar a Caja Mayor",
            icon: Icons.add,
            color: Colors.green,
            onPressed: () => showAddDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          foregroundColor: WidgetStateProperty.all(Colors.white),

          // 👇 Quita el overlay gris y usa uno acorde al color
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return color.withValues(alpha: 0.85);
            }
            if (states.contains(WidgetState.pressed)) {
              return color.withValues(alpha: 0.7);
            }
            return null;
          }),

          // 👇 Elevación para que se sienta clickeable
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 2;
            if (states.contains(WidgetState.hovered)) return 6;
            return 4;
          }),

          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14),
          ),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}