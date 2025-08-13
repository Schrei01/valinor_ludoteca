import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import '../db/database_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late Future<List<Product>> _productsFuture;

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = DatabaseHelper.instance.getProducts();
  }

  void _addProduct() async {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim());

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
    await DatabaseHelper.instance.insertOrUpdateProduct(newProduct);

    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _purchasePriceController.clear();

    setState(() {
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Inventario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          // Form para agregar producto
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Precio Venta'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextField(
            controller: _purchasePriceController,
            decoration: const InputDecoration(labelText: 'Precio compra'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          ElevatedButton(
            onPressed: _addProduct,
            child: const Text('Agregar Producto'),
          ),

          const SizedBox(height: 20),

          // Lista de productos
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
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
                        'Cantidad: ${p.quantity}  |  Precio venta: \$${p.price.toStringAsFixed(2)}  |  Precio compra: \$${p.purchasePrice.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Confirmar antes de eliminar
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: Text('¿Eliminar "${p.name}" del inventario?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await DatabaseHelper.instance.deleteProduct(p.id!);
                            setState(() {
                              _loadProducts();
                            });
                          }
                        },
                      ),
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
