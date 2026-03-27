import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashCardWidget extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const CashCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat("#,##0", "es_CO");

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // 👈 mejor balance
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12), // 👈 más grande
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: color,
                size: 30, // 👈 ICONO MÁS GRANDE
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, // 👈 un poco más grande
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 73, 73, 73),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "\$${currencyFormat.format(value)}",
                    style: TextStyle(
                      fontSize: 22, // 👈 CLAVE: este es el protagonista
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}