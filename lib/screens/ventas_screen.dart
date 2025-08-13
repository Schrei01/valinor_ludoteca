import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import '../db/database_helper.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Product> _products = [];

  bool _loading = true;
  List<SaleLine> _saleLines = [];


  @override
  void initState() {
    super.initState();
    _loadProducts();
    _saleLines.add(SaleLine());
  }


  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getAvailableProducts();
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  double get _totalRegistro {
    double total = 0;
    for (var line in _saleLines) {
      final quantity = int.tryParse(line.quantityController.text) ?? 0;
      final price = line.product?.price ?? 0;
      total += quantity * price;
    }
    return total;
  }


  void _registerSale() async {
    bool hasError = false;

    for (var line in _saleLines) {
      final quantity = int.tryParse(line.quantityController.text.trim());
      final product = line.product;

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un producto en todas las líneas')),
        );
        hasError = true;
        break;
      }

      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cantidad inválida en alguna línea')),
        );
        hasError = true;
        break;
      }

      if (quantity > product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cantidad mayor al stock disponible en ${product.name}')),
        );
        hasError = true;
        break;
      }
    }

    if (hasError) return;

    final now = DateTime.now().toIso8601String();

    for (var line in _saleLines) {
      final quantity = int.parse(line.quantityController.text.trim());
      final product = line.product!;

      await DatabaseHelper.instance.insertSale(product.id!, quantity, now);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ventas registradas correctamente')),
    );

    // Limpiar todo después de registrar
    for (var line in _saleLines) {
      line.quantityController.clear();
      line.product = null;
    }

    setState(() {});

    await _loadProducts();
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._saleLines.asMap().entries.map((entry) {
            int index = entry.key;
            SaleLine line = entry.value;

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
                      onChanged: (_) => setState(() {}), // recalcula el total
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Producto
                  Expanded(
                    flex: 2,
                    child: DropdownButton<Product>(
                      isExpanded: true,
                      hint: const Text('Selecciona un producto'),
                      value: line.product,
                      items: _products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} - \$${p.price.toStringAsFixed(0)}'),
                        );
                      }).toList(),
                      onChanged: (p) {
                        setState(() {
                          line.product = p;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  if (_saleLines.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _saleLines.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _saleLines.add(SaleLine());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar venta'),
          ),

          const SizedBox(height: 20),

          // TOTAL
          Text(
            'Total: \$${_totalRegistro.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _registerSale,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'Registrar Venta',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}
