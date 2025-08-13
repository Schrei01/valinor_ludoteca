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
          const Center(
            child: Text(
              'Inventario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Expanded( // Esto hace que la fila ocupe todo el alto disponible
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📦 FORMULARIO
                SizedBox(
                  width: 300, // Fijo para que no se estire
                  child: ProductForm(
                    nameController: _nameController,
                    quantityController: _quantityController,
                    priceController: _priceController,
                    purchasePriceController: _purchasePriceController,
                    onAddProduct: _addProduct,
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

class InventoryTitle extends StatelessWidget {
  const InventoryTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Inventario',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class ProductForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController purchasePriceController;
  final VoidCallback onAddProduct;

  const ProductForm({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    required this.purchasePriceController,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
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
          onPressed: onAddProduct,
          child: const Text('Agregar Producto'),
        ),
      ],
    );
  }
}

class ProductList extends StatelessWidget {
  final Future<List<Product>> productsFuture;
  final VoidCallback onDeleteConfirmed;

  const ProductList({
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
    return Expanded(
      child: FutureBuilder<List<Product>>(
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
                  'Precio venta: \$${p.price.toStringAsFixed(2)}  |  '
                  'Precio compra: \$${p.purchasePrice.toStringAsFixed(2)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await _showDeleteDialog(context, p.name);
                    if (confirm == true) {
                      await DatabaseHelper.instance.deleteProduct(p.id!);
                      onDeleteConfirmed(); // avisa para recargar
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
