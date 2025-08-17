import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/widgets/sale_line_widget.dart';
import '../db/database_helper.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Product> _products = [];
  final List<Account> _accounts = [Account()];

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

  double _calculateTotal(List<SaleLine> saleLines) {
    double total = 0;
    for (final line in saleLines) {
      final q = int.tryParse(line.quantityController.text.trim()) ?? 0;
      final p = line.product?.price ?? 0.0;
      total += q * p;
    }
    return total;
  }

  void _registerSaleForAccount(Account account) async {
    bool hasError = false;

    for (var line in account.saleLines) {
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

    for (var line in account.saleLines) {
      final quantity = int.parse(line.quantityController.text.trim());
      final product = line.product!;

      await DatabaseHelper.instance.insertSale(product.id!, quantity, now);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ventas registradas correctamente en cuenta ${_accounts.indexOf(account) + 1}')),
    );

    // Limpiar la cuenta después de registrar
    for (var line in account.saleLines) {
      line.quantityController.clear();
      line.product = null;
    }

    account.total = 0;

    setState(() {});

    await _loadProducts();
  }
  

  @override
  Widget build(BuildContext context) {
    final accountsProvider = Provider.of<AccountsProvider>(context);
    final accounts = accountsProvider.accounts;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Render de cada cuenta
              ...accounts.asMap().entries.map((entry) {
                final index = entry.key;
                final account = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cuenta ${index + 1}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                accountsProvider.removeAccount(index);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Lista de líneas de venta
                        ...account.saleLines.asMap().entries.map((saleEntry) {
                          int saleIndex = saleEntry.key;
                          SaleLine line = saleEntry.value;

                          return SaleLineWidget(
                            line: line,
                            products: _products,
                            onChanged: () {
                              accountsProvider.updateTotal(index);
                            },
                            onRemove: account.saleLines.length > 1
                                ? () {
                                    accountsProvider.removeSaleLine(index, saleIndex);
                                  }
                                : null,
                          );
                        }),

                        const SizedBox(height: 12),

                        // Botón para agregar venta
                        AddSaleButton(
                          onPressed: () {
                            accountsProvider.addSaleLine(index);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Total + botón registrar
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TotalDisplay(total: account.total),
                              ),
                            ),
                            const SizedBox(width: 16),
                            RegisterSaleButton(
                              onPressed: () =>
                                  _registerSaleForAccount(account),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          accountsProvider.addAccount();
        },
        icon: const Icon(Icons.add),
        label: const Text("Nueva cuenta"),
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



class Account {
  List<SaleLine> saleLines;
  double total;

  Account({
    List<SaleLine>? saleLines,
    this.total = 0,
  }) : saleLines = saleLines ?? [SaleLine()];
}



