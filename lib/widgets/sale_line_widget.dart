import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';

class SaleLineWidget extends StatelessWidget {
  final SaleLine line;
  final List<Product> products;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const SaleLineWidget({
    super.key,
    required this.line,
    required this.products,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Cantidad
          Expanded(
            flex: 1,
            child: TextField(
              controller: line.quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              onChanged: (_) => onChanged(),
            ),
          ),

          const SizedBox(width: 16),

          // Producto
          Expanded(
          flex: 2,
          child: Autocomplete<Product>(
            optionsBuilder: (TextEditingValue value) {
              if (value.text.isEmpty) {
                return const Iterable<Product>.empty();
              }
              return products.where((p) =>
                  p.name.toLowerCase().contains(value.text.toLowerCase()));
            },
            displayStringForOption: (p) => p.name,
            initialValue: line.product != null
                ? TextEditingValue(text: line.product!.name)
                : const TextEditingValue(),
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Selecciona un producto',
                ),
                onEditingComplete: onEditingComplete,
              );
            },
            onSelected: (p) {
              line.product = p;
              // también podrías actualizar el precio automáticamente aquí
              onChanged();
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final Product option = options.elementAt(index);
                        return ListTile(
                          title: Text('${option.name} (Stock: ${option.quantity})'),
                          subtitle: Text('\$${option.price.toStringAsFixed(0)}'),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),

          const SizedBox(width: 16),

          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}