import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/services/product_service.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/widgets/product_form_widget.dart';
import 'package:valinor_ludoteca_desktop/widgets/product_list_widget.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late Future<List<Product>> _allProductsFuture;

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _loteController = TextEditingController();
  List<Product> _filteredProducts = [];

  // Lista completa de productos (para búsqueda)
  late List<Product> _allProducts;

  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Service
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();

    // Cargar productos disponibles (> 0)
    _loadProducts();

    // Cargar todos los productos (para búsqueda)
    _allProductsFuture = ProductService().getAll();

    // Listener de búsqueda
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

   /// 🔹 Cargar productos disponibles y todos los productos
  Future<void> _loadProducts() async {
    try {
      // Productos disponibles (>0)
      final available = await _productService.getAvailable();

      // Todos los productos (para búsqueda)
      final all = await _productService.getAll();

      setState(() {
        _filteredProducts = available;
        _allProducts = all;
      });
    } catch (e) {
      // Manejo de errores
      debugPrint("Error cargando productos: $e");
    }
  }

  void _filterProducts(String query) {
    final filtered = _allProducts.where((product) {
      final nameLower = product.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) && product.quantity > 0;
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
    // 🔹 Validar cantidad negativa antes de llamar al Service
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
      // Usamos el Service en lugar de DatabaseHelper
      final productService = ProductService();
      await productService.insertOrUpdate(newProduct);

      // Limpiar campos de entrada
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _purchasePriceController.clear();
      _loteController.clear();

      // Recargar productos (disponibles)
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
                          products: _filteredProducts, 
                          productService: _productService,
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


