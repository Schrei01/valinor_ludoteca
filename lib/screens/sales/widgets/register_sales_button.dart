import 'package:flutter/material.dart';

class RegisterSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: const Text(
        'Registrar Venta',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}