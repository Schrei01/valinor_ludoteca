import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class ProductList extends StatelessWidget {
  final Future<List<Product>> productsFuture;
  final VoidCallback onDeleteConfirmed;
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "es_CO");

  ProductList({
    super.key,
    required this.productsFuture,
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
    return FutureBuilder<List<Product>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos'));
        }

        final products = snapshot.data!;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return ListTile(
              title: Text(p.name),
              subtitle: Text(
                'Cantidad: ${p.quantity}  |  '
                'Precio venta: \$${_currencyFormat.format(p.price)}  |  '
                'Precio compra: \$${_currencyFormat.format(p.purchasePrice)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await _showDeleteDialog(context, p.name);
                  if (confirm == true) {
                    await DatabaseHelper.instance.deleteProduct(p.id!);
                    onDeleteConfirmed();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}