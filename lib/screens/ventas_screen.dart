import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import '../db/database_helper.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Product> _products = [];

  bool _loading = true;
  final List<SaleLine> _saleLines = [];


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

    // ignore: use_build_context_synchronously
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
            // Lista de líneas de venta
            ..._saleLines.asMap().entries.map((entry) {
              int index = entry.key;
              SaleLine line = entry.value;

              return SaleLineWidget(
                line: line,
                products: _products,
                onChanged: () => setState(() {}),
                onRemove: _saleLines.length > 1
                    ? () {
                        setState(() {
                          _saleLines.removeAt(index);
                        });
                      }
                    : null,
              );
            }),

            const SizedBox(height: 12),

            // Botón agregar
            AddSaleButton(
              onPressed: () {
                setState(() {
                  _saleLines.add(SaleLine());
                });
              },
            ),

            const SizedBox(height: 20),
            // Total
            // Botón + Total en la misma fila
            Row(
              children: [
                // Botón al lado izquierdo
                RegisterSaleButton(onPressed: _registerSale),

                const SizedBox(width: 16), // espacio entre botón y total

                // Total a la derecha
                Expanded(
                  child: TotalDisplay(total: _totalRegistro),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Botón registrar
          ],
        ),
      );
    }
}

class TotalDisplay extends StatelessWidget {
  final double total;

  const TotalDisplay({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Total: \$${total.toStringAsFixed(0)}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class AddSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Agregar venta'),
    );
  }
}

class RegisterSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: const Text(
        'Registrar Venta',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

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

