import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class ProductForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController purchasePriceController;
  final Future<void> Function(Product) onAddProduct; // 🔹 ahora recibe el producto
  final List<Product> existingProducts;

  const ProductForm({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    required this.purchasePriceController,
    required this.onAddProduct,
    required this.existingProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<Product>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Product>.empty();
            }
            return existingProducts.where((Product p) {
              return p.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
            });
          },
          displayStringForOption: (Product p) => p.name,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = nameController.text;
            controller.addListener(() {
              nameController.text = controller.text;
            });
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Nombre'),
            );
          },
          onSelected: (Product selected) {
            nameController.text = selected.name;
            priceController.text = selected.price.toStringAsFixed(2);
            purchasePriceController.text =
                selected.purchasePrice.toStringAsFixed(2);
          },
        ),
        TextField(
          controller: quantityController,
          decoration: const InputDecoration(labelText: 'Cantidad'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: priceController,
          decoration: const InputDecoration(labelText: 'Precio Venta'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextField(
          controller: purchasePriceController,
          decoration: const InputDecoration(labelText: 'Precio compra'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final quantity = int.tryParse(quantityController.text.trim());
            final price = double.tryParse(priceController.text.trim());
            final purchasePrice = double.tryParse(purchasePriceController.text.trim());

            if (name.isEmpty || quantity == null || price == null || purchasePrice == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor completa todos los campos correctamente')),
              );
              return;
            }

            final newProduct = Product(
              name: name,
              quantity: quantity,
              price: price,
              purchasePrice: purchasePrice,
            );

            await onAddProduct(newProduct);
          },

          child: const Text('Agregar Producto'),
        ),
      ],
    );
  }
}

