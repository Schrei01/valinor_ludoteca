import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/widgets/product_form_widget.dart';
import 'package:valinor_ludoteca_desktop/widgets/product_list_widget.dart';
import '../db/database_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

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

  Future<bool> _askPassword(BuildContext context) async {
    final controller = TextEditingController();
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Acceso restringido"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Ingresa la contraseña",
                ),
                obscureText: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text == "1990") {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  child: const Text("Aceptar"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _addProduct(Product newProduct) async {
  // 🔹 Validar cantidad negativa antes de llamar a la DB
  if (newProduct.quantity < 0) {
    final allowed = await _askPassword(context);
    if (!allowed) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad negativa no permitida')),
      );
      return; // no guardamos nada
    }
  }

  try {
    await DatabaseHelper.instance.insertOrUpdateProduct(newProduct);

    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _purchasePriceController.clear();

    setState(() {
      _loadProducts();
    });
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Inventario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📦 FORMULARIO
                SizedBox(
                  width: 300,
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final existingProducts = snapshot.data ?? [];

                      return ProductForm(
                        nameController: _nameController,
                        quantityController: _quantityController,
                        priceController: _priceController,
                        purchasePriceController: _purchasePriceController,
                        onAddProduct: _addProduct,
                        existingProducts: existingProducts,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // 📜 LISTA DE PRODUCTOS
                Expanded(
                  child: ProductList(
                    productsFuture: _productsFuture,
                    onDeleteConfirmed: _loadProducts,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


