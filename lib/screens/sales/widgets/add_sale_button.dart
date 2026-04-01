import 'package:flutter/material.dart';

class AddSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Agregar venta'),
    );
  }
}