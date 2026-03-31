import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/db/services/product_service.dart';
import '../models/products.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final ProductService productService;
  final VoidCallback onDeleteConfirmed;
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "es_CO");

  ProductList({
    super.key,
    required this.products,
    required this.productService,
    required this.onDeleteConfirmed,
  });

  Future<bool?> _showDeleteDialog(BuildContext context, String productName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "$productName" del inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No hay productos'));
    }

    final sortedProducts = [...products]..sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return ListView.builder(
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final p = sortedProducts[index];
        return ListTile(
          title: Text(p.name),
          subtitle: Text(
            'Cantidad: ${p.quantity}  |  '
            'Precio venta: \$${_currencyFormat.format(p.price)}  |  '
            'Precio compra: \$${_currencyFormat.format(p.purchasePrice)} | '
            'Lote: ${p.lote}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await _showDeleteDialog(context, p.name);
              if (confirm == true) {
                try {
                  // 🔹 Usar ProductService en lugar de DatabaseHelper
                  await productService.delete(p.id!);

                  // 🔹 Callback al padre para actualizar lista
                  onDeleteConfirmed();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error eliminando producto: $e')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}