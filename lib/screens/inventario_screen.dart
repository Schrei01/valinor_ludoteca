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
  late Future<List<Product>> _allProductsFuture;

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _loteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts(); // productos con cantidad > 0
    _allProductsFuture = DatabaseHelper.instance.getAllProducts(); 
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  Future<List<Product>> _loadProducts() async {
    final products = await DatabaseHelper.instance.getProducts(); // 👈 solo los > 0

    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });

    return products;
  }

  void _filterProducts(String query) {
    final filtered = _allProducts.where((product) {
      final nameLower = product.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();

    setState(() => _filteredProducts = filtered);
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
    _loteController.clear();

    await _loadProducts();
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
                    future: _allProductsFuture,
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
                        loteController: _loteController,
                        onAddProduct: _addProduct,
                        existingProducts: existingProducts,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // 📜 LISTA + BUSCADOR
                Expanded(
                  child: Column(
                    children: [
                      // 🔍 BUSCADOR
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 📋 LISTA DE PRODUCTOS FILTRADOS
                      Expanded(
                        child: ProductList(
                          products: _filteredProducts, // 👈 ahora usa la lista filtrada
                          onDeleteConfirmed: _loadProducts,
                        ),
                      ),
                    ],
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


